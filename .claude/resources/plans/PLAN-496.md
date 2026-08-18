# [PLAN-496] 트랜잭션 경계 기준 수립과 적용

> 이슈: #496
> 브랜치: refactor/496-transaction-boundary

## 목표

"무엇이 함께 롤백되어야 하는가"를 판정하는 기준을 세우고, 그 기준으로 현재 코드를 재분류해 경계를 다시 긋는다. `readOnly` 유실과 커넥션 점유는 기준을 세우면 따라오는 결과이지 목적이 아니다.

레슨 제출 흐름은 성격이 다른 세 가지를 한 요청, 한 트랜잭션에 묶고 있다.

1. **풀이 결과 제출** — 사용자가 만든 사실
2. **풀이에 따른 보상** — 리그 점수, XP, 미션, 기록
3. **제출 후 화면에 필요한 정보 조회** — 리그명, 레벨, 유닛 요약

기준을 적용하면 3번이 1번과 같은 트랜잭션에 있을 이유가 없다는 결론이 나온다. 리그를 조회하지 못해서 이미 저장된 풀이 결과가 롤백되는 것은 어떤 기준으로도 정당화되지 않는다. 이 계획은 3번을 별도 조회 API로 분리해 그 결론을 구조로 못박는다.

## 배경: 기준은 새로 만드는 게 아니라 이미 내린 판정을 명문화하는 것이다

이 코드베이스는 리그 점수, 미션, 피드, 알림을 `@TransactionalEventListener(AFTER_COMMIT)` + `RetryEventPublisher` 재시도 큐로 이미 분리해 뒀다. 팀은 이미 "이건 실패해도 사실 기록은 유효하고 나중에 보정할 수 있다"고 판정한 상태다. 문제는 그 판정이 문서에 없어서, 나머지가 왜 동기인지에 대한 근거도 남아 있지 않다는 것이다.

## 설계 변경 기록: 왜 "경계 뒤로 이동"에서 "응답 분리"로 바뀌었나

최초 계획은 `getUserLeagueName`을 쓰기 경계 **뒤**로 옮겨 응답에 보상 반영 후 리그명이 담기게 하는 안이었다. 이 안은 두 가지가 부족했다.

- **성공한 제출에 500이 나간다.** 커밋 이후에 조회가 실패하면 데이터는 남지만 클라이언트는 실패 응답을 받는다. 성공과 실패를 구분할 수 없으니 재제출로 중복 기록이 쌓인다. 롤백은 막았지만 "리그 조회 실패가 제출을 무효로 만든다"는 문제는 사용자 층위에 그대로 남는다.
- **일회성 읽기라 보정이 안 된다.** 보상이 재시도 큐로 넘어가면 그 응답의 리그명은 영원히 낡은 값이다. 조회 API로 분리하면 멱등이라 재조회로 자연 수렴한다.

근거는 응답 DTO다. `LessonSubmissionSaveResponse`의 세 필드 중 **제출 기록에 의존하는 것이 하나도 없다.**

| 필드 | 실제 성격 |
|---|---|
| `leagueName` | 유저의 현재 리그명 |
| `UserLevelResponse(currentLevel, nextLevel, xp)` | 절대값. 이번 제출의 증가분이 아니다 |
| `UnitSummaryResponse(unitId, title, description)` | 정적 콘텐츠 메타 |

즉 이 응답은 "제출 결과"가 아니라 **"제출 후 현재 상태"** 다. 쓰기 응답에 실릴 것이 아니라 조회로 받아야 한다.

### 조회 키는 `lessonId`가 아니라 `lessonSubmissionId`다

중간 검토에서 "`lessonId`만 있으면 되니 제출 식별자는 필요 없다"고 판단했으나 이는 틀렸다. `V29__convert_lesson_submission_to_history.sql`이 **"유저+레슨당 1행 덮어쓰기에서 제출마다 새 행을 쌓는 이력 구조로 전환"** 했다(`try_count` 컬럼 제거, 시도 횟수는 행 개수로 집계). 같은 레슨을 여러 번 풀면 `lesson_submission` 행이 여러 개 쌓이므로 **`lessonId`는 "어떤 제출인지"를 특정하지 못한다.**

따라서 제출 API는 생성된 `lessonSubmissionId`를 반환하고, 결과 조회는 그 식별자를 키로 받는다. 이렇게 하면

- 클라이언트가 자기가 방금 만든 제출을 정확히 지목할 수 있다
- 조회 시 소유권 검증(내 제출인가)이 가능해진다
- 나중에 "이번 제출로 얻은 XP", "이번 제출의 정답률" 같은 **제출 단위 값**을 결과 화면에 추가할 수 있다. `lessonId` 기준이었다면 영원히 불가능하다

## 수립할 기준

판정 질문은 하나다.

> **A는 커밋됐는데 B가 실패한 상태를 사용자가 보게 돼도 괜찮은가?**
> 안 괜찮으면 같은 트랜잭션. 괜찮고 나중에 보정할 수 있으면 이벤트.

여기서 두 계층이 나온다.

| 계층 | 정의 | 처리 |
|---|---|---|
| 1. 사실 기록 | 사용자의 한 행위가 만든 사실과, 그것이 없으면 모순이 되는 파생 상태 | 같은 트랜잭션 |
| 2. 보정 가능한 파생 | 보상, 통지, 집계. 실패해도 사실은 유효하고 재시도로 메울 수 있다 | `AFTER_COMMIT` 이벤트 + 재시도 큐 |

여기에 응답 규칙이 붙는다. 이 규칙이 세 번째 계층을 만들지 않기 위한 장치다.

- **쓰기 API의 응답에는 그 쓰기로 확정된 사실만 담는다. "현재 상태"는 조회 API로 분리한다**
  최초 계획에는 "3. 응답에 실리는 상태"라는 계층이 있었다. 그러나 그것은 도메인이 만든 계층이 아니라 **API 모양이 만든 계층**이었다. 응답에 값을 실었기 때문에 그 값을 만드는 쓰기가 트랜잭션에 끌려 들어온 것이지, 함께 롤백되어야 해서가 아니다. 응답에서 빼면 계층이 사라진다.
- **쓰기 응답에 담는 "확정된 사실"의 기본형은 생성된 리소스의 식별자다**

부수 규칙 두 가지.

- 경계 밖으로 나갈 수 있는 것은 사전 검증 조회다. 쓰기는 경계 밖으로 나가지 않는다
- 단일 서비스 위임뿐인 Facade 메서드에는 경계를 만들지 않는다. 서비스가 이미 갖고 있다. 조회 메서드도 예외가 아니다

## 기준을 어길 수 없는 제약

- `spring.jpa.open-in-view: false` (`application.yml:20`, `application-dev.yml:18`, `application-prod.yml:18`). 경계 밖에는 영속성 컨텍스트가 없다. **따라서 Facade 경계 유지 여부의 판정 기준은 "조회냐 쓰기냐"가 아니라 "엔티티를 경계 밖으로 반환해 조립하느냐" 그리고 "여러 조회를 하나의 스냅샷으로 묶어야 하느냐"다**
- 리스너가 전부 `AFTER_COMMIT`이고 `fallbackExecution`이 없다. 경계 없이 발행한 이벤트는 예외 없이 폐기된다. 즉 **이벤트 발행은 반드시 경계 안에서** 일어나야 한다
- `@EnableAsync`(`AsyncConfig`)는 있으나 `@Async`가 붙은 메서드가 없다. `AFTER_COMMIT` 리스너는 커밋 직후 **동기** 실행되고, `TransactionTemplate.execute()`는 리스너 실행까지 끝낸 뒤 반환한다

## 보상의 실제 성질

계층 2를 "원자적"이라고 적으면 안 된다. 현재 보상은 각각 **독립적으로 커밋되고 독립적으로 재시도된다.**

- 리그 점수: `UserLeaguePointService.addLeaguePoints`가 `REQUIRES_NEW`. 호출한 쪽이 롤백돼도 남는다
- 미션, 일일 학습 기록: 각자 자기 트랜잭션. 리스너가 예외를 삼키고 재시도 큐에 적재
- 피드: Redis 재시도 큐를 거쳐 별도 요청으로 처리

하나가 실패해도 나머지는 진행된다. 기준 문서에는 "보상은 각각 독립적으로 재시도 가능하다"로 적는다.

## 레슨 제출에 기준을 적용한 결과

| 대상 | 계층 | 근거 |
|---|---|---|
| 레슨 제출 기록, 문제 제출 기록 | 1 | 레슨은 제출됐는데 문제 응답이 없으면 정답률의 근거가 사라진다 |
| 오답 노트 | 1 | "틀린 문제는 오답 노트에 자동으로 올라간다"가 정책이라, 빠지면 정책 위반 상태가 사용자에게 그대로 보인다 |
| XP, 레벨 | 1 | 제출 사실에서 파생된 학습 상태다. 연속 학습일과 같은 성격이다. **최초 계획은 "응답에 실려 나가므로" 계층 2로 뒀으나, 응답에서 빠진 뒤에도 계층 1로 남는다** |
| 연속 학습일 | 1 | 제출 사실에서 파생된 학습 상태다. 어긋나면 메인 화면이 틀린 값을 보여준다 |
| 리그 점수, 미션, 피드, 알림, 일일 기록 | 2 | 이미 이벤트와 재시도 큐로 분리되어 있다 |
| 리그명, 레벨값, 유닛 요약 **조회** | — | 쓰기가 아니다. 응답 규칙에 따라 조회 API로 분리한다 |

분리 후에는 최초 계획이 "모순"이라 불렀던 것(계층 2인 리그 점수의 결과가 계층 3처럼 응답에 실림)이 **해소되는 게 아니라 소멸한다.** 조회 시점이 커밋 이후이므로 동기 리스너가 반영한 값을 읽고, 재시도 큐로 넘어간 경우에도 재조회로 수렴한다.

## 선행 조건

**클라이언트 협의가 필요하다.** `POST /api/v1/lessons/results`의 응답이 결과 화면 데이터에서 `lessonSubmissionId` 하나로 바뀌고, 화면 데이터는 별도 요청으로 나뉜다. 협의 없이 서버만 배포하면 결과 화면이 깨진다.

## 영향 범위

### 신규 파일
- `src/main/java/gravit/code/lesson/dto/response/LessonResultResponse.java` — 결과 화면 조회 응답. 기존 `LessonSubmissionSaveResponse`의 세 필드를 그대로 옮긴다

경계는 `TransactionTemplate`으로 만들고 새 빈은 만들지 않는다.

### 수정 파일
- `.claude/rules/code-convention/facade.md` — 원자성 판정 기준, 2계층 분류, 응답 규칙, 제약 추가
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — `LESSON_SUBMISSION_NOT_FOUND` 추가
- `src/main/java/gravit/code/lesson/dto/response/LessonSubmissionSaveResponse.java` — `lessonSubmissionId` 한 필드로 축소
- `src/main/java/gravit/code/lesson/repository/LessonSubmissionRepository.java` — 소유권 검증 겸 `lessonId` 조회 메서드 추가
- `src/main/java/gravit/code/lesson/service/LessonSubmissionCommandService.java` — 저장 후 생성된 id 반환
- `src/main/java/gravit/code/lesson/service/LessonSubmissionQueryService.java` — 제출 소유권 검증 조회 추가
- `src/main/java/gravit/code/user/service/UserService.java` — `getUserLevel` 추가
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` — `saveLessonSubmission` 경계 축소, `getLessonResult` 신설
- `src/main/java/gravit/code/lesson/controller/LessonController.java` — `POST /results` 응답 변경, `GET /results/{lessonSubmissionId}` 추가
- `src/main/java/gravit/code/lesson/controller/LessonControllerDocs.java` — 위 두 엔드포인트 문서 갱신 및 추가
- `src/main/java/gravit/code/problem/facade/ProblemFacade.java` — `saveProblemSubmission`의 사전 검증 조회를 경계 밖으로
- `.claude/spec/service-policy/learning.md` — 제출과 결과 조회가 분리된다는 규칙 추가
- `src/test/java/gravit/code/lesson/facade/LessonFacadeUnitTest.java` — `TransactionTemplate` 스텁, 응답 변경 반영, 호출 순서 검증, `getLessonResult` 테스트
- `src/test/java/gravit/code/lesson/facade/LessonFacadeIntegrationTest.java` — 이벤트 전달, 원자성, 보상 반영 후 조회 회귀 테스트 추가

## 구현 계획

### 1. Entity / Flyway
DB 변경 없음. `lesson_submission`은 V29에서 이미 이력 구조이고 `id`가 IDENTITY PK다.

### 2. Repository

`LessonSubmissionRepository`에 소유권 검증과 `lessonId` 조회를 한 번에 하는 메서드를 추가한다.

```java
@Query("""
    SELECT ls.lessonId
    FROM LessonSubmission ls
    WHERE ls.id = :lessonSubmissionId AND ls.userId = :userId
""")
Optional<Long> findLessonIdByIdAndUserId(
        @Param("lessonSubmissionId") long lessonSubmissionId,
        @Param("userId") long userId
);
```

엔티티가 아니라 스칼라를 반환하므로 경계 밖으로 엔티티가 새지 않는다. 결과가 비면 "없는 제출"과 "남의 제출"을 구분하지 않고 같은 예외로 처리한다.

### 3. 컨벤션 문서: `.claude/rules/code-convention/facade.md`

`## 트랜잭션 경계` 절을 추가하고 위 "수립할 기준"의 판정 질문, 2계층 표, 응답 규칙, 부수 규칙 2개, 제약 3개, "보상의 실제 성질"을 옮긴다. 경계를 `TransactionTemplate`으로 만드는 이유(전용 빈을 만들면 프록시 경계를 얻으려고 계층 결합을 만들게 된다)를 함께 남긴다.

Facade 경계 유지 판정은 "조회 메서드인가"가 아니라 아래 둘 중 하나라도 해당하는가로 적는다.

- 엔티티를 경계 밖으로 반환해 조립하는가 (`open-in-view: false`이므로 경계가 없으면 깨진다)
- 여러 조회를 하나의 스냅샷으로 읽어야 하는가

### 4. DTO

**`LessonSubmissionSaveResponse`** — 한 필드로 축소한다.

```java
@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 풀이 결과 저장 Response")
public record LessonSubmissionSaveResponse(

        @Schema(
                description = "생성된 레슨 제출 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long lessonSubmissionId
) {
    public static LessonSubmissionSaveResponse create(long lessonSubmissionId) {
        return LessonSubmissionSaveResponse.builder()
                .lessonSubmissionId(lessonSubmissionId)
                .build();
    }
}
```

`InquiryController.submitInquiry`는 식별자를 `ResponseEntity<Long>`로 그대로 반환하는 선례가 있으나, DTO로 감싸는 쪽을 택한다. Swagger 스키마에 필드명이 드러나고, 나중에 제출 단위 값이 추가돼도 응답 스펙이 깨지지 않는다.

**`LessonResultResponse`** — 신규. 기존 `LessonSubmissionSaveResponse`의 세 필드(`leagueName`, `userLevelResponse`, `unitSummaryResponse`)와 `@Schema`를 그대로 옮기고 설명만 "레슨 결과 화면 Response"로 바꾼다. 필드가 동일하므로 클라이언트의 파싱 코드는 재사용된다.

### 5. Service

#### 5-1. `LessonSubmissionCommandService.saveLessonSubmission` — 반환 타입 변경

```java
@Transactional
public long saveLessonSubmission(
    long userId,
    LessonSubmissionSaveRequest request
) {
    LessonSubmission lessonSubmission = LessonSubmission.create(
            request.learningTime(),
            request.accuracy(),
            request.lessonId(),
            userId
    );

    return lessonSubmissionRepository.save(lessonSubmission).getId();
}
```

`@GeneratedValue(strategy = IDENTITY)`라 `save` 시점에 INSERT가 실행되고 id가 채워진다.

#### 5-2. `LessonSubmissionQueryService.getSubmittedLessonId` — 신설

```java
@Transactional(readOnly = true)
public long getSubmittedLessonId(
        long userId,
        long lessonSubmissionId
) {
    return lessonSubmissionRepository.findLessonIdByIdAndUserId(lessonSubmissionId, userId)
            .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_SUBMISSION_NOT_FOUND));
}
```

#### 5-3. `UserService.getUserLevel` — 신설

`getLessonResult`는 XP를 올리지 않고 현재 레벨만 읽어야 하는데 그런 메서드가 없다. 기존 조회 메서드로 대체할 수 없다.

- `updateUserLevelByLessonSubmission` — 쓰기다
- `findById` → `UserResponse(userId, profileImgNumber, nickname, providerId)` — 레벨과 XP가 없다
- `getUser` → `User` 엔티티. 경계 밖으로 엔티티를 내보내게 되므로 쓰지 않는다

```java
@Transactional(readOnly = true)
public UserLevelResponse getUserLevel(long userId) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

    return UserLevelResponse.create(user.getLevel().getLevel(), user.getLevel().getXp());
}
```

`User.level`은 `@Embedded UserLevel`이므로 지연 로딩 문제가 없고, 기존 `updateUserLevelAndXp`가 응답을 만드는 방식과 같은 값이 나온다. `UserLevelResponse.create`가 `nextLevel`을 `Level.fromLevel(level).next()`로 채우므로 별도 계산은 필요 없다.

#### 5-4. `ProblemSubmissionCommandService.validateProblemSubmissions`

변경 없음. `problemRepository`만 읽는 순수 검증(`@Transactional(readOnly = true)`)이라 경계 밖 호출로 바뀌어도 동작이 같다. 이름은 `CommandService`지만 계층 분류상 사전 검증 조회다. 클래스 이동은 호출부 파급이 있어 이번 범위에서 하지 않고, 검토 결과만 이슈 체크리스트에 기록한다.

### 6. 예외

`CustomErrorCode`의 Lesson 그룹에 추가한다.

```java
LESSON_SUBMISSION_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_4042", "레슨 풀이 제출 이력 조회에 실패하였습니다."),
```

**주의**: `LessonControllerDocs`가 이미 `LESSON_4042` "레슨 풀이 제출 이력 조회에 실패하였습니다."를 문서에 적어 두었으나 `CustomErrorCode`에는 해당 상수가 없다. 문서에만 존재하는 유령 응답이다. 이번에 실제 코드를 추가하면서 정합을 맞춘다.

### 7. Facade

`TransactionTemplate`은 Spring Boot의 `TransactionAutoConfiguration`이 `TransactionManager` 후보가 하나일 때 자동 등록한다. 커스텀 `PlatformTransactionManager` 정의가 없어 조건을 만족하며, 이미 `SeasonBatchServiceTest` 등 테스트 3곳이 `@Autowired TransactionTemplate`으로 주입받고 있어 실증되어 있다. 별도 설정 클래스를 만들지 말고 주입만 한다.

#### 7-1. `LessonFacade.saveLessonSubmission`

`@Transactional`을 제거하고 아래 구조로 바꾼다.

```java
public LessonSubmissionSaveResponse saveLessonSubmission(
        long userId,
        LearningSubmissionSaveRequest request
) {
    LessonSubmissionSaveRequest lessonRequest = request.lessonSubmissionSaveRequest();
    List<ProblemSubmissionSaveRequest> problemRequests = request.problemSubmissionSaveRequests();

    LearningIdsDto learningIds = lessonQueryService.getLearningIdsByLessonId(lessonRequest.lessonId());
    problemSubmissionCommandService.validateProblemSubmissions(problemRequests);
    boolean isFirstTry = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lessonRequest.lessonId());

    Long lessonSubmissionId = transactionTemplate.execute(status -> {
        long submissionId = lessonSubmissionCommandService.saveLessonSubmission(userId, lessonRequest);

        List<Long> wrongAnsweredProblemIds = problemSubmissionCommandService.saveProblemSubmissions(userId, problemRequests);
        wrongAnsweredNoteService.saveWrongAnsweredNotes(userId, wrongAnsweredProblemIds);

        userService.updateUserLevelByLessonSubmission(userId, lessonRequest, isFirstTry);
        ConsecutiveSolvedDto consecutiveSolved = learningCommandService.updateLearningStatus(userId, learningIds.chapterId());

        if (isFirstTry) {
            publisher.publishEvent(new LessonCompletedEvent(
                    userId,
                    learningIds.lessonId(),
                    learningIds.chapterId(),
                    POINT_PER_LESSON,
                    lessonRequest.accuracy(),
                    lessonRequest.learningTime(),
                    consecutiveSolved.before(),
                    consecutiveSolved.after()
            ));
        }

        return submissionId;
    });

    return LessonSubmissionSaveResponse.create(lessonSubmissionId);
}
```

응답 조립 구간이 사라졌다. 남은 것은 사전 검증 조회 3건과 함께 커밋되어야 하는 쓰기 5건뿐이고, 두 구간의 경계가 코드에서 그대로 읽힌다. 경계 밖으로 나가는 값은 생성된 식별자 하나다.

`updateUserLevelByLessonSubmission`의 반환값은 더 이상 쓰지 않지만 서비스 시그니처는 바꾸지 않는다. 다른 호출부 파급을 이번 범위에서 만들지 않기 위해서다.

#### 7-2. `LessonFacade.getLessonResult` — 신설

```java
@Transactional(readOnly = true)
public LessonResultResponse getLessonResult(
        long userId,
        long lessonSubmissionId
) {
    long lessonId = lessonSubmissionQueryService.getSubmittedLessonId(userId, lessonSubmissionId);

    String leagueName = userLeagueService.getUserLeagueName(userId);
    UserLevelResponse userLevelResponse = userService.getUserLevel(userId);
    UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByLessonId(lessonId);

    return LessonResultResponse.create(leagueName, userLevelResponse, unitSummaryResponse);
}
```

- `@Transactional(readOnly = true)`를 유지하는 근거는 "조회 Facade라서"가 아니라 **네 조회를 하나의 스냅샷으로 읽어야 하기 때문**이다. 리그명과 레벨이 서로 다른 시점의 값이면 결과 화면이 어긋난다. 커넥션도 1회만 잡는다
- `lessonSubmissionId`는 소유권 검증과 `lessonId` 확보에 쓴다. `leagueName`과 `userLevelResponse`는 여전히 **조회 시점의 현재 값**이다. 제출 단위 값이 아니다
- 이 메서드가 실패해도 제출은 이미 커밋되어 있다. 클라이언트는 같은 요청을 다시 보내면 되고 중복 제출 위험이 없다. **이것이 이번 작업이 노린 결과다**

#### 7-3. `ProblemFacade.saveProblemSubmission`

`validateProblemSubmissions`(사전 검증 조회)를 경계 밖으로 빼고, 문제 제출 저장과 오답 노트 저장만 경계 안에 남긴다.

`validateProblemSubmissions`는 엔티티가 아니라 프로젝션(`ProblemTypeDto`)을 읽으므로 뒤이은 `saveProblemSubmissions`와 1차 캐시를 공유해 얻는 이득이 없다. 경계를 나눠도 **쿼리 수는 그대로다.**

### 8. Controller

```java
@PostMapping("/results")
public ResponseEntity<LessonSubmissionSaveResponse> saveLessonSubmission(
        @AuthenticationPrincipal LoginUser loginUser,
        @Valid @RequestBody LearningSubmissionSaveRequest request
){
    return ResponseEntity.status(HttpStatus.CREATED).body(lessonFacade.saveLessonSubmission(loginUser.getId(), request));
}

@GetMapping("/results/{lessonSubmissionId}")
public ResponseEntity<LessonResultResponse> getLessonResult(
        @AuthenticationPrincipal LoginUser loginUser,
        @PathVariable("lessonSubmissionId") Long lessonSubmissionId
){
    return ResponseEntity.status(HttpStatus.OK).body(lessonFacade.getLessonResult(loginUser.getId(), lessonSubmissionId));
}
```

- 상태 코드를 200에서 **201 CREATED**로 바꾼다. 생성된 리소스의 식별자를 반환하게 됐으므로 201이 맞고, `InquiryController.submitInquiry`가 `HttpStatus.CREATED` + 식별자 반환으로 같은 선례를 만들어 뒀다
- `GET /results/{lessonSubmissionId}`는 첫 세그먼트가 리터럴 `results`라 기존 `GET /{unitId}`와 충돌하지 않는다
- 컨트롤러가 Facade를 여러 번 호출하는 구조는 여전히 채택하지 않는다. 조합 책임이 컨트롤러로 올라가고 "무엇이 원자적인가"가 호출 순서에 흩어진다. 이번 분리는 호출 순서 조합이 아니라 **요청 자체를 나누는 것**이라 성격이 다르다

### 9. API 문서: `LessonControllerDocs`

- `saveLessonSubmission`: 201 응답으로 바꾸고 스키마를 `LessonSubmissionSaveResponse`로 갱신한다. **`유저 리그 조회 실패(U_L_4041)`와 `유닛 조회 실패(UNIT_4041)` 응답을 제거한다.** 이 두 실패는 더 이상 제출 경로에서 발생하지 않는다 — 문서에서 사라지는 것이 이번 작업의 성과를 그대로 드러낸다. `LESSON_4042`도 제출 경로에서는 발생하지 않으므로 함께 제거한다
- `getLessonResult`: 신설. 200과 함께 `LESSON_4042`(제출 이력 없음 또는 타인의 제출), `U_L_4041`, `UNIT_4041`, `USER_4041`을 붙인다
- 작성 규칙은 `.claude/spec/api-docs-convention.md`를 따른다

### 10. 서비스 정책: `.claude/spec/service-policy/learning.md`

다음 규칙을 추가한다.

- 레슨 제출 API는 생성된 제출 아이디만 응답한다. 결과 화면에 필요한 리그명, 레벨, 유닛 요약은 그 아이디로 별도 조회한다
- 결과 조회는 본인의 제출만 가능하다. 없는 제출이거나 타인의 제출이면 같은 예외로 응답한다
- 결과 화면의 레벨과 XP는 제출 트랜잭션에서 함께 커밋되므로 이번 제출이 항상 반영되어 있다
- 결과 화면의 리그명은 **조회 시점의 현재 값**이다. 리그 점수 지급이 재시도 큐로 넘어간 경우 아직 반영 전 리그명이 보일 수 있고, 재조회하면 수렴한다

사용자에게 보이는 값의 의미가 바뀌므로 `service-policy/README.md`의 갱신 규칙에 따라 같은 작업에서 반영한다. 티어 구간과 산식은 `league-season.md`에 이미 있으므로 옮겨 적지 않는다.

## 결정 사항

- [x] **경계를 만드는 수단** — **`TransactionTemplate` 확정**. 전용 `@Facade` 빈 안은 철회한다. 조합이 필요해서가 아니라 프록시 경계를 얻으려고 만드는 빈이라 계층 결합을 만들 값어치가 없다
- [x] **응답에 실리는 상태의 처리** — **조회 API 분리 확정**. `getUserLeagueName`을 경계 뒤로 옮기는 안은 철회한다. 커밋 후 조회 실패 시 성공한 제출에 500이 나가는 문제가 남고, 일회성 읽기라 재시도 큐 케이스가 보정되지 않는다
- [x] **조회 키** — **`lessonSubmissionId` 확정**. V29 이후 `lesson_submission`이 이력 구조라 `lessonId`로는 특정 제출을 지목할 수 없다. 소유권 검증과 향후 제출 단위 값 확장도 식별자가 있어야 가능하다
- [x] **XP, 레벨의 계층** — **계층 1 유지**. 응답에서 빠졌지만 제출 사실에서 파생된 학습 상태라는 성격은 그대로다. 연속 학습일과 동급으로 본다. 이벤트로 내리지 않는다
- [x] **`POST /results` 상태 코드** — **201 CREATED**. 근거는 8번

## 범위에서 제외

- **`SocialFacade` 전체** (`follow`, `hideFeed`, `getFeed`, `congratulateFeed`, `publishFeed`) — 담당 범위가 아니라 이번 작업에서 다루지 않는다. 검토 과정에서 확인한 사항은 인계 사항으로만 남긴다
  - `follow`, `hideFeed`, `getFeed`는 단일 서비스 위임이고 위임 대상이 자기 경계를 가지므로 Facade의 `@Transactional`이 중복이다
  - `publishFeed`는 경계를 축소하려 해도 닉네임 조회가 `if (!followerIds.isEmpty())` 안에 있고 `followerIds`가 경계 안에서 산출돼, 앞으로 빼면 불필요한 쿼리가 늘고 알림까지 빼면 쓰기가 경계 밖으로 나간다. 단순 축소가 성립하지 않는다
  - `congratulateFeed`의 알림 발송은 기준상 계층 2라 이벤트로 내리는 게 맞다
- **`UserFacade.getMainPage`** — 조회 전용인데 쓰기 `@Transactional`이다. #415에서 위젯별 API로 분리되며 `@Deprecated(forRemoval = true)`가 붙어 제거 예정이라 손대지 않는다
- **리스너 내부의 트랜잭션 경계**

## 예상되는 성능 방향

이슈가 밝힌 대로 커넥션 점유는 목적이 아니지만, 측정 결과를 해석할 기준이 필요하므로 예상을 적어 둔다.

- **쓰기 트랜잭션 점유 시간: 감소.** `saveLessonSubmission`이 조회 5 + 쓰기 5에서 쓰기 5로 줄어든다
- **요청당 커넥션 획득 횟수: 증가.** `saveLessonSubmission` 1회 → 4회(사전 검증 3 + 쓰기 1). 결과 조회 API가 1회를 더 쓰지만 별도 요청이다
- **총 쿼리 수: 1건 증가.** 결과 조회에서 제출 소유권 검증 쿼리가 새로 붙는다. 나머지는 경계만 나뉜다
- **HTTP 라운드트립: 1회 증가.** 제출 후 결과 화면 전환이 이미 있으므로 체감 영향은 작을 것으로 본다

측정에서 이 방향과 다른 결과가 나오면 원인을 확인한다.

## 검증

- 대상 테스트
  - `LessonFacadeIntegrationTest` (추가): 경계 축소 후 `LessonCompletedEvent`의 `AFTER_COMMIT` 리스너가 실제로 실행되는지. `@RecordApplicationEvents`는 발행 여부만 보므로 **리그 점수와 미션 진행도를 직접 조회해** 단언한다. 발행만 검증하면 이번 리팩토링의 핵심 위험을 못 잡는다. `TCSpringBootTest`는 클래스 레벨 `@Transactional` 없이 `DatabaseCleaner`로 정리하므로 커밋이 실제로 일어나 이 검증이 성립한다
  - `LessonFacadeIntegrationTest` (추가): 티어 승급이 일어나는 점수 경계에서 제출한 뒤 반환된 아이디로 `getLessonResult`를 호출하면 `leagueName`이 **승급 후** 값인지
  - ~~`LessonFacadeIntegrationTest` (추가): 경계 안 쓰기 중 하나가 실패하면 5건이 모두 롤백되는지 (`@MockitoSpyBean`으로 실패 주입)~~ **제외** - 검증 깊이를 얕게 유지하기로 해 이번 범위에서 뺐다. 후속 보강 대상
  - `LessonFacadeIntegrationTest` (추가): **유저 리그가 없는 상태에서 제출하면 제출은 커밋되고 아이디가 반환되며, `getLessonResult`만 `USER_LEAGUE_NOT_FOUND`로 실패하는지.** 이번 설계 변경의 핵심 회귀 방어다
  - `LessonFacadeIntegrationTest` (추가): 같은 레슨을 두 번 제출하면 **서로 다른 아이디**가 반환되고, 각 아이디로 조회했을 때 모두 성공하는지. 조회 키를 `lessonSubmissionId`로 정한 근거의 회귀 방어
  - `LessonFacadeIntegrationTest` (추가): 타인의 `lessonSubmissionId`로 조회하면 `LESSON_SUBMISSION_NOT_FOUND`인지
  - ~~`LessonFacadeIntegrationTest`: 재제출(`isFirstTry == false`) 시 보상 미지급 유지~~ **제외** - 위와 같은 사유
  - `LessonFacadeUnitTest`: `TransactionTemplate` 스텁 주입(콜백을 즉시 실행하도록), 사전 조회 3건이 쓰기 이전에 일어나는지 `InOrder`로 검증. 기존 테스트 2건은 `saveLessonSubmission`의 응답 필드를 단언하고 있으므로 아이디 반환과 이벤트 발행 여부 단언으로 바꾼다
  - `LessonFacadeUnitTest` (추가): `getLessonResult`가 네 서비스를 조합해 응답을 만드는지
  - `ProblemFacade` 관련 기존 테스트 회귀
- `./gradlew test` 전체 통과
- 이슈 체크리스트의 커넥션 점유 시간 비교 측정은 `optimize-performance` 스킬로 별도 수행한다

## Deviation Log

- **2026-08-18 · 설계 방향 전환**: `getUserLeagueName`을 쓰기 경계 뒤로 옮기는 안에서, 결과 조회를 별도 API로 분리하는 안으로 변경. 계기는 응답 DTO 검토 — `LessonSubmissionSaveResponse`의 세 필드 모두 제출 기록에 의존하지 않고 "제출 후 현재 상태"였다. 최초 안은 커밋 후 조회 실패 시 성공한 제출에 500을 반환하는 문제와, 재시도 큐 케이스가 일회성 읽기로 보정되지 않는 문제가 남았다. 이에 따라 3계층을 2계층 + 응답 규칙으로 재정의하고, XP·레벨을 계층 2에서 계층 1로 재분류했다
- **2026-08-18 · 조회 키 정정**: 중간 검토에서 "`lessonId`만 있으면 되니 제출 식별자는 불필요"로 판단했으나 철회. V29가 `lesson_submission`을 제출마다 행을 쌓는 이력 구조로 전환했으므로 `lessonId`로는 특정 제출을 지목할 수 없다. 제출 API가 `lessonSubmissionId`를 반환하고 조회가 그 키를 받는 구조로 확정. 소유권 검증과 향후 제출 단위 값 확장도 이 구조라야 가능하다
- **2026-08-18 · 범위 축소**: `SocialFacade` 전체를 제외. 담당 범위가 아니다. 검토 결과는 "범위에서 제외" 절에 인계 사항으로만 남긴다

### 구현 중 편차 (trivial)

- `src/test/java/gravit/code/lesson/facade/LessonFacadeUnitTest.java`: `SaveLessonSubmission` 중첩 클래스에 `TransactionTemplate` 콜백 즉시 실행 스텁(`@BeforeEach`)을 넣고, 경계 뒤로 빠져 더 이상 호출되지 않는 `getUnitSummaryByLessonId`·`getUserLeagueName` 스텁 12줄을 제거했으며, 응답 단언을 `lessonSubmissionId`로 교체 — 이유: 시그니처 변경으로 컴파일이 깨지고 Mockito strict stub이 미사용 스텁을 실패로 처리한다. 계획서 "검증" 절의 신규 회귀 테스트는 `write-test`로 별도 추가했다(아래)
- `src/main/java/gravit/code/lesson/controller/LessonControllerDocs.java`: 제출 API의 `PROBLEM_4041` 응답 설명을 "문제 풀이 제출 이력 조회 실패"에서 "문제 조회 실패"로 정정 — 이유: 해당 경로에서 실제로 던지는 것은 `validateProblemSubmissions`의 `PROBLEM_NOT_FOUND`("문제 조회에 실패하였습니다.")다. 기존 문서의 설명이 코드와 어긋나 있었다
- `src/test/java/gravit/code/lesson/facade/LessonFacadeIntegrationTest.java`: `GetLessonResult` 중첩 클래스로 회귀 테스트 3건 추가(보상 반영 후 리그명 조회, 동일 레슨 재제출 시 아이디 분리, 타인 제출 조회 차단) — 이유: 계획서 "검증" 절 항목 중 핵심만 얕게 검증하기로 했다. 롤백 주입(`@MockitoSpyBean`) 기반 원자성 테스트와 재제출 보상 미지급 테스트는 검증 깊이를 얕게 유지하라는 지시에 따라 제외했다
- `src/main/java/gravit/code/learning/dto/request/LearningSubmissionSaveRequest.java`: 작업 중 IDE에서 `LessonSubmissionSaveRequest`로 리네임된 것을 원복 — 이유: 계획 범위 밖 변경이고, `gravit.code.lesson.dto.request.LessonSubmissionSaveRequest`와 단순명이 충돌해 레코드 내부에서 FQN을 써야 했다
