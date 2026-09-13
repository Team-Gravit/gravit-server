# [PLAN-536] 레슨 제출 응답에 레벨업, 승급 여부 추가

> 이슈: #536
> 브랜치: feat/536-lesson-submission-level-up-promotion

## 목표
레슨을 처음 제출해 레벨업이나 리그 승급이 일어나면 클라이언트가 결과 모달을 띄울 수 있도록, `POST /api/v1/lessons/results` 응답에 `isLevelUp`, `isLeaguePromoted` boolean 필드를 추가한다.

## 배치 기준
- **레벨업은 제출 트랜잭션 안에서 판정한다.** XP 지급(`UserService.updateUserLevelByLessonSubmission`)이 제출과 같은 트랜잭션에서 커밋되고, 이미 `oldLevel`, `newLevel`을 비교하고 있다(`UserService:147-153`). 반환값만 바꾸면 된다
- **승급은 A안으로 판정한다.** 첫 제출일 때만 경계 밖에서 제출 전 리그 `sortOrder`를 조회해 두고, `transactionTemplate.execute()`가 반환된 뒤 다시 조회해 비교한다. `execute()`는 `AFTER_COMMIT` 리스너(`UserLeagueEventListener` → `addLeaguePoints`, `REQUIRES_NEW`)가 끝난 뒤에 반환하므로(`facade.md` 제약), 사후 조회 시점에는 리그 점수 지급이 커밋돼 있다. 기존 통합 테스트 `제출_직후_조회하면_리그_보상이_반영된_리그명을_반환한다`도 같은 전제로 통과하고 있다
- **"승급"의 정의는 `UserLeaguePointService`와 같게 둔다.** `sortOrder`가 커졌을 때만 승급으로 본다(`UserLeaguePointService:38-39`). 비교는 리그 도메인 지식이므로 Facade가 아니라 `UserLeagueService`에 둔다
- **미션 완료 보상 XP로 인한 레벨업은 포함하지 않는다.** 레벨업 판정은 레슨 XP 지급에서만 한다
- **리그에 참여하지 않은 유저도 제출은 정상 처리한다.** 기존 `getLeagueSortOrder`는 `USER_LEAGUE_NOT_FOUND`를 던지므로 쓸 수 없다. 온보딩 리그 생성이 재시도 큐로 넘어간 유저의 제출이 실패하면 안 된다. `Optional`을 반환하는 조회를 새로 두고, 리그가 없으면 `isLeaguePromoted`는 false다
- **재제출이면 리그를 조회하지 않는다.** 재제출은 `LessonCompletedEvent`를 발행하지 않아 리그 점수가 오르지 않는다. 사전 조회 자체를 건너뛰어 쿼리 2회를 아끼고, "재제출은 false"를 동시성과 상관없이 보장한다
- **제출 전 리그 조회는 경계 밖에 둔다.** `facade.md`가 경계 밖에 허용하는 것은 "사전 검증 조회"이고, 이 조회는 검증이 아니다. 다만 같은 메서드의 `checkFirstLessonSubmission`도 검증이 아닌 사전 조회로 이미 경계 밖에 있고, 경계 안으로 옮기면 조회 결과를 콜백 밖으로 꺼내기 위해 내부 DTO에 필드를 하나 더 실어야 한다. 규칙이 지키려는 "쓰기는 경계 밖으로 나가지 않는다"는 그대로 유지된다. 이 배치도 아래 "규칙 예외"에 함께 기록한다
- **`updateUserLevelByLessonSubmission`은 `boolean`을 반환한다.** 이 메서드의 반환값(`UserLevelResponse`)은 #496 이후 프로덕션 호출부(`LessonFacade:100`)에서 쓰지 않고 버려진다. 내부 DTO로 level, xp를 계속 들고 다닐 이유가 없다. `UserLevelResponse` 클래스 자체는 `getUserLevel`과 `LessonResultResponse`가 계속 쓰므로 그대로 둔다
- **`execute()` 콜백은 제출 아이디와 레벨업 여부를 함께 돌려줘야 한다.** `lesson/dto/internal/LessonSubmissionSavedDto`로 전달한다(`dto.md` Internal 규칙). 승급 여부는 콜백이 끝난 뒤에 계산하므로 콜백 안에서 응답 DTO를 만들 수 없다
- 호출부 확인: `TestScenarioController:89`는 `saveLessonSubmission` 반환값을 쓰지 않으므로 수정하지 않는다. `SocialFacade:48`의 `getLeagueSortOrder` 사용도 그대로 둔다

## 규칙 예외 (이 계획서에만 기록)

`facade.md` 응답 규칙은 "쓰기 API 응답에는 그 쓰기로 확정된 사실만 담아라. 현재 상태는 조회 API로 분리하라"이다.

- `isLevelUp`은 규칙 안에 있다. 제출 트랜잭션이 커밋한 XP 지급 결과다
- **`isLeaguePromoted`는 규칙의 예외다.** 리그 점수는 커밋 뒤 별도 트랜잭션(`REQUIRES_NEW`)에서 지급되고, 실패하면 재시도 큐로 넘어간다. 응답 값은 이번 쓰기로 확정된 사실이 아니라, 커밋 직후 관측한 리그 상태를 제출 전 상태와 비교한 결과다
- 예외를 허용하는 이유: 클라이언트가 결과 모달을 띄우려면 제출 응답 시점에 승급 여부가 필요하다. 반대로 리그 지급을 트랜잭션에 편입(C안)하면 "응답에 필요해서 경계를 끌어들이는" 더 무거운 위반이 되고, #496 결정도 뒤집게 된다
- **제출 전 리그 조회를 경계 밖에 두는 것도 예외로 기록한다.** `facade.md`의 부수 규칙은 경계 밖에 "사전 검증 조회"만 허용한다. 이 조회는 검증이 아니지만 `checkFirstLessonSubmission`과 같은 성격의 사전 조회이고 쓰기가 아니므로 경계 밖에 둔다
- `facade.md`는 수정하지 않는다

A안이 감수하는 한계는 아래와 같다.

| 상황 | 결과 |
|---|---|
| 리그 점수 지급이 실패해 재시도 큐로 넘어감 | 나중에 재시도로 승급돼도 응답은 false. 모달은 뜨지 않고 `TIER_PROMOTION` 피드는 재시도 경로에서 발행됨 |
| 누군가 `UserLeagueEventListener`에 `@Async`를 붙임 | 사후 조회가 지급 전 상태를 읽어 항상 false로 조용히 회귀함. 통합 테스트로 고정한다 |
| 같은 유저가 서로 다른 레슨을 동시에 첫 제출 | 다른 제출이 일으킨 승급이 섞여 두 응답이 모두 true일 수 있음 |
| 사전 조회와 사후 조회 사이에 다른 유저가 이 유저의 피드를 축하함 | 축하 LP 5점(`SocialFacade.congratulateFeed:107`)으로 승급해도 레슨 제출 응답이 true. 두 조회 사이 간격이 제출 트랜잭션과 리스너 실행 시간뿐이라 발생 확률은 낮음 |
| 커밋 뒤 사후 조회(`checkLeaguePromoted`)가 DB 오류로 실패 | 예외를 로그로 남기고 `isLeaguePromoted` false로 성공 응답. 승급했더라도 모달은 뜨지 않음 (PR #538 리뷰 반영, Deviation Log 참고) |
| 사전 조회와 사후 조회 사이에 시즌이 전환됨(소프트 리셋) | 티어가 내려가 false |
| 첫 제출의 조회 비용 | 리그 `sortOrder` 단건 조회 2회 추가 |

## 영향 범위

### 신규 파일
- `src/main/java/gravit/code/lesson/dto/internal/LessonSubmissionSavedDto.java` - `execute()` 콜백이 제출 아이디와 레벨업 여부를 함께 반환하기 위한 내부 DTO

### 수정 파일
- `src/main/java/gravit/code/lesson/dto/response/LessonSubmissionSaveResponse.java` - `isLevelUp`, `isLeaguePromoted` 필드 추가, `create` 시그니처 변경
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` - `saveLessonSubmission`에 리그 사전·사후 조회와 레벨업 결과 전달 추가
- `src/main/java/gravit/code/user/service/UserService.java` - `updateUserLevelByLessonSubmission`, `updateUserLevelAndXp`의 반환 타입을 `boolean`(레벨업 여부)으로 변경
- `src/main/java/gravit/code/userLeague/service/UserLeagueService.java` - `findLeagueSortOrder`, `checkLeaguePromoted` 추가
- `src/main/java/gravit/code/lesson/controller/LessonControllerDocs.java` - 레슨 결과 저장 오퍼레이션 description 갱신
- `.claude/spec/service-policy/learning.md` - 제출 응답 내용과 레벨업·승급 판정 기준 반영 (정책 변경)
- `src/test/java/gravit/code/lesson/facade/LessonFacadeUnitTest.java` - 컴파일 유지를 위한 최소 수정. `updateUserLevelByLessonSubmission` 스텁 6곳의 반환값을 `UserLevelResponse.create(...)`에서 `boolean`으로 바꾸고 `UserLevelResponse` import 제거. 새 단위 테스트는 추가하지 않는다(`test-convention.md`)
- `src/test/java/gravit/code/user/service/UserServiceIntegrationTest.java` - `UpdateUserLevelByLessonSubmission`의 기존 테스트 2개가 `result.xp()`를 써서 컴파일이 깨짐. 검증 섹션 시나리오로 교체하고, 이 두 테스트에서만 쓰는 `UserLevelResponse` import(19행)를 제거
- `src/test/java/gravit/code/lesson/facade/LessonFacadeIntegrationTest.java` - `SaveLessonSubmission`에 레벨업, 승급 시나리오 추가. `GetLessonResult` 안의 유저, 리그, 제출 픽스처를 바깥 클래스로 이동
- `src/test/java/gravit/code/userLeague/service/UserLeagueServiceIntegrationTest.java` - `findLeagueSortOrder`, `checkLeaguePromoted` 시나리오 추가

## 구현 계획

### 1. Entity / Flyway
변경 없음.

### 2. Repository
변경 없음. 기존 `UserLeagueRepository.findLeagueSortOrderByUserId(Long userId)`를 그대로 쓴다.

### 3. Service

`UserService.java`

```java
@Transactional
public boolean updateUserLevelByLessonSubmission(
        long userId,
        LessonSubmissionSaveRequest request,
        boolean isFirstTry
){
    boolean isLevelUp;

    if(isFirstTry){
        isLevelUp = updateUserLevelAndXp(userId, POINT_PER_LESSON, request.accuracy());
    }else{
        isLevelUp = updateUserLevelAndXp(userId, 0, request.accuracy());
    }
    return isLevelUp;
}
```

```java
private boolean updateUserLevelAndXp(
        long userId,
        int xp,
        int accuracy
) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

    int oldLevel = user.getLevel().getLevel();
    user.getLevel().updateXp((int) Math.round(xp * accuracy * 0.01));
    int newLevel = user.getLevel().getLevel();

    boolean isLevelUp = newLevel > oldLevel;
    if (isLevelUp) {
        publisher.publishEvent(new LevelUpFeedEvent(userId, newLevel));
    }

    return isLevelUp;
}
```

- 분기 구조와 XP 산식은 바꾸지 않는다. 반환 타입만 바꾼다
- `UserLevelResponse` import는 `getUserLevel`이 계속 쓰므로 유지한다

`UserLeagueService.java` - `getLeagueSortOrder` 아래에 추가

```java
@Transactional(readOnly = true)
public Optional<Integer> findLeagueSortOrder(long userId) {
    return userLeagueRepository.findLeagueSortOrderByUserId(userId);
}

@Transactional(readOnly = true)
public boolean checkLeaguePromoted(
        long userId,
        int sortOrderBefore
) {
    return userLeagueRepository.findLeagueSortOrderByUserId(userId)
            .map(sortOrder -> sortOrder > sortOrderBefore)
            .orElse(false);
}
```

- 이름에 `get` 대신 `find`를 쓴다. 같은 파라미터의 `getLeagueSortOrder(long)`(예외를 던짐)가 이미 있어 오버로드할 수 없고, `Optional` 반환은 `find`가 드러낸다
- `checkLeaguePromoted`는 `checkFirstLessonSubmission`, `checkBookmarkedProblemExists`처럼 boolean 판정 메서드의 `check` 접두사를 따른다

### 4. Facade

필요 - `lesson`, `user`, `userLeague` 등 여러 도메인 Service를 조합한다(기존 `LessonFacade`).

`LessonFacade.saveLessonSubmission` 전체 흐름

```java
public LessonSubmissionSaveResponse saveLessonSubmission(
        long userId,
        LearningSubmissionSaveRequest request
){
    LessonSubmissionSaveRequest lessonSubmissionSaveRequest = request.lessonSubmissionSaveRequest();
    List<ProblemSubmissionSaveRequest> problemSubmissionSaveRequests = request.problemSubmissionSaveRequests();

    LearningIdsDto learningIdsDto = lessonQueryService.getLearningIdsByLessonId(lessonSubmissionSaveRequest.lessonId());
    problemSubmissionCommandService.validateProblemSubmissions(problemSubmissionSaveRequests);
    boolean isFirstTry = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lessonSubmissionSaveRequest.lessonId());

    Optional<Integer> leagueSortOrderBeforeSubmission = isFirstTry
            ? userLeagueService.findLeagueSortOrder(userId)
            : Optional.empty();

    LessonSubmissionSavedDto saved = transactionTemplate.execute(status -> {
        long submissionId = lessonSubmissionCommandService.saveLessonSubmission(userId, lessonSubmissionSaveRequest);

        List<Long> wrongAnsweredProblemIds = problemSubmissionCommandService.saveProblemSubmissions(userId, problemSubmissionSaveRequests);
        wrongAnsweredNoteService.saveWrongAnsweredNotes(userId, wrongAnsweredProblemIds);

        boolean isLevelUp = userService.updateUserLevelByLessonSubmission(userId, lessonSubmissionSaveRequest, isFirstTry);
        ConsecutiveSolvedDto consecutiveSolvedDto = learningCommandService.updateLearningStatus(userId, learningIdsDto.chapterId());

        if(isFirstTry){
            publisher.publishEvent(new LessonCompletedEvent(
                    // 기존 인자 그대로
            ));
        }

        return new LessonSubmissionSavedDto(submissionId, isLevelUp);
    });

    boolean isLeaguePromoted = leagueSortOrderBeforeSubmission
            .map(sortOrderBefore -> userLeagueService.checkLeaguePromoted(userId, sortOrderBefore))
            .orElse(false);

    return LessonSubmissionSaveResponse.create(
            saved.lessonSubmissionId(),
            saved.isLevelUp(),
            isLeaguePromoted
    );
}
```

- 사전 조회는 `isFirstTry` 판정 바로 뒤, 경계 밖에 둔다. 검증 조회는 아니지만 `checkFirstLessonSubmission`과 같은 성격의 사전 조회라 같은 자리에 둔다(배치 기준, 규칙 예외 참고)
- 사후 조회는 반드시 `execute()` 반환 뒤에 둔다. 콜백 안에서 조회하면 `AFTER_COMMIT` 리스너가 돌기 전이라 항상 false가 된다
- `execute()` 안의 기존 쓰기 순서와 이벤트 발행 위치는 바꾸지 않는다
- import 추가: `java.util.Optional`, `gravit.code.lesson.dto.internal.LessonSubmissionSavedDto`. `UserLevelResponse` import는 `getLessonResult`가 계속 쓰므로 유지한다

### 5. DTO

`lesson/dto/internal/LessonSubmissionSavedDto.java` (신규)

```java
public record LessonSubmissionSavedDto(
        long lessonSubmissionId,

        boolean isLevelUp
) {
}
```

- 정적 팩토리 없이 표준 생성자로 만든다. `common.md`는 정적 팩토리를 Entity와 Response DTO에만 요구한다. `ConsecutiveSolvedDto`, `LearningIdsDto`는 `of`를 선언하고 있지만 메인 코드에서 호출하는 곳이 없고, 실제 생성은 `new`(`Learning:64`)와 JPQL 생성자(`LessonRepository:23`)로 한다
- `@Schema`는 붙이지 않는다

`lesson/dto/response/LessonSubmissionSaveResponse.java`

```java
@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 풀이 결과 저장 Response")
public record LessonSubmissionSaveResponse(

        @Schema(
                description = "생성된 레슨 제출 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long lessonSubmissionId,

        @Schema(
                description = "이번 제출의 레슨 XP로 레벨업했는지 여부. 미션 완료 보상 XP로 인한 레벨업은 포함하지 않으며, 재제출은 항상 false",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean isLevelUp,

        @Schema(
                description = "이번 제출의 리그 점수로 리그가 승급했는지 여부. 리그 점수 지급이 재시도 큐로 넘어갔거나 리그에 참여하지 않았으면 false이며, 재제출은 항상 false",
                example = "false",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean isLeaguePromoted
) {
    public static LessonSubmissionSaveResponse create(
            long lessonSubmissionId,
            boolean isLevelUp,
            boolean isLeaguePromoted
    ){
        return LessonSubmissionSaveResponse.builder()
                .lessonSubmissionId(lessonSubmissionId)
                .isLevelUp(isLevelUp)
                .isLeaguePromoted(isLeaguePromoted)
                .build();
    }
}
```

- JSON 키는 `isLevelUp`, `isLeaguePromoted`다. 같은 패키지 record인 `LessonSummaryResponse.isSolved`가 같은 방식으로 `isSolved` 키로 나가고 있다

### 6. Controller

`POST /api/v1/lessons/results → LessonController.saveLessonSubmission` - 컨트롤러 코드는 변경 없음.

`LessonControllerDocs.saveLessonSubmission`의 `@Operation` description

```java
@Operation(summary = "레슨 결과 저장", description = "레슨 완료 후 문제 풀이 결과를 저장하고 사용자 레벨을 업데이트합니다.<br>" +
        "생성된 레슨 제출 아이디와 이번 제출로 인한 레벨업 여부, 리그 승급 여부를 반환하며, 결과 화면 정보는 <strong>레슨 결과 조회</strong> API로 받습니다.<br>" +
        "레벨업 여부는 레슨 XP 기준이며, 미션 완료 보상 XP로 인한 레벨업은 포함하지 않습니다.<br>" +
        "리그 점수 지급이 재시도 큐로 넘어간 경우 승급했더라도 <strong>isLeaguePromoted</strong>는 false입니다.<br>" +
        "재제출은 보상이 없으므로 두 값 모두 false입니다.<br>" +
        "🔐 <strong>Jwt 필요</strong><br>")
```

- `@ApiResponses`는 바꾸지 않는다. 201 응답 스키마가 `LessonSubmissionSaveResponse`를 참조하므로 필드 설명은 DTO `@Schema`로 반영된다

### 7. 서비스 정책

`.claude/spec/service-policy/learning.md`

- 14행 교체
  - 기존: `레슨 제출 API는 생성된 제출 아이디만 응답한다. 결과 화면에 필요한 리그명, 레벨, 유닛 요약은 그 아이디로 별도 조회한다`
  - 변경: `레슨 제출 API는 생성된 제출 아이디와 함께, 이번 제출로 레벨업했는지와 리그가 승급했는지를 응답한다. 결과 화면에 필요한 리그명, 레벨, 유닛 요약은 그 아이디로 별도 조회한다`
- 14행 바로 아래에 추가
  - `레벨업 여부는 이번 제출의 레슨 XP 지급으로 레벨이 올랐는지만 본다. 같은 제출로 미션이 완료되어 받은 보상 XP로 레벨이 오른 경우는 포함하지 않는다`
  - `리그 승급 여부는 제출 직전 티어와 리그 점수 지급이 끝난 뒤의 티어를 비교해 판정한다. 리그 점수 지급이 재시도 큐로 넘어가면 나중에 승급이 반영되더라도 응답은 false다`
  - `리그에 참여하지 않은 사용자도 레슨 제출은 정상 처리되고, 리그 승급 여부는 false다`
  - `재제출은 보상이 없으므로 레벨업 여부와 리그 승급 여부가 모두 false다`

## 결정 필요 (Decisions needed)
- [x] 리그 승급 판정 방식 - A. 커밋 후 재조회 비교 / B. 트랜잭션 안에서 예측 / C. 리그 지급을 트랜잭션에 편입 → **A**
- [x] 미션 완료 보상 XP로 인한 레벨업 포함 여부 - 포함 / 미포함 → **미포함**
- [x] 쓰기 응답 규칙 예외 기록 위치 - `facade.md`에 예외 추가 / PLAN에만 기록 → **PLAN에만 기록**
- [x] 응답 필드 이름 - `isLevelUp` / `levelUp` → **`isLevelUp`, `isLeaguePromoted`**

## 검증

**대상 테스트** (`@TCSpringBootTest`)

`LessonFacadeIntegrationTest` > `SaveLessonSubmission`

| 시나리오 | 기대 |
|---|---|
| 첫 제출로 레벨 구간을 넘음 (XP 90, 정답률 100 → 110) | `isLevelUp` true |
| 첫 제출로 리그 구간을 넘음 (브론즈 LP 90, 정답률 100 → 110, 실버) | `isLeaguePromoted` true. 리그 리스너가 `execute()` 반환 전에 동기로 반영된다는 전제를 고정한다 |
| 첫 제출이지만 레벨·리그 구간을 넘지 않음 | 두 값 모두 false |
| 재제출 (기존 제출 이력을 먼저 저장하고, XP·LP는 경계 직전) | 두 값 모두 false |
| 리그에 참여하지 않은 유저의 첫 제출 | 예외 없이 제출이 저장되고 `isLeaguePromoted` false |
| 제출 저장 뒤 승급 여부 조회 실패 (`checkLeaguePromoted`가 커넥션 획득 실패를 던짐) | 예외 없이 제출이 저장되고 `isLeaguePromoted` false |

- 미션 XP로 인한 레벨업은 테스트로 고정하지 않는다. 한계를 테스트로 묶으면 나중에 포함하기로 했을 때 개선이 회귀처럼 보이고, 결정 내용은 `learning.md`에 남는다

- 리그와 유저 픽스처(`유저()`, `브론즈로_리그에_참여시킨다`, `정답_제출`)는 지금 `GetLessonResult` 안에 있다. `SaveLessonSubmission`에서도 쓰려면 바깥 클래스로 올려야 한다

`UserServiceIntegrationTest` > `UpdateUserLevelByLessonSubmission`

| 시나리오 | 기대 |
|---|---|
| 첫 시도로 레벨 구간을 넘음 (XP 90, 정답률 100) | true, 저장된 레벨 2 |
| 첫 시도지만 구간 안 (XP 0, 정답률 100) | false, 저장된 XP 20 |
| 재시도 (XP 90, 정답률 100) | false, 저장된 XP 90 유지 |
| 존재하지 않는 유저 | `RestApiException` / `USER_NOT_FOUND` (기존 유지) |

`UserLeagueServiceIntegrationTest`

| 시나리오 | 기대 |
|---|---|
| `findLeagueSortOrder` - 리그 참여 유저 | 현재 리그 `sortOrder` |
| `findLeagueSortOrder` - 리그 미참여 유저 | `Optional.empty()` |
| `checkLeaguePromoted` - 현재 `sortOrder`가 기준보다 큼 | true |
| `checkLeaguePromoted` - 같음 | false |
| `checkLeaguePromoted` - 리그 미참여 유저 | false |

**빌드 확인**: `LessonFacadeUnitTest`는 반환 타입 변경으로 컴파일만 맞춘다. `./gradlew test`로 전체 통과를 확인한다.

## 범위 밖 (후속 작업)
- `MissionService.awardMissionXp`가 `LevelUpFeedEvent`를 발행하지 않아, 미션 XP로 레벨업하면 소셜 피드가 빠진다
- 팔로우 미션 완료처럼 레슨 제출 밖에서 일어나는 레벨업은 이 응답으로 알릴 수 없다
- `UserLeagueRepository.findLeagueSortOrderByUserId`가 `repository.md`의 텍스트 블록 `@Query` 형식을 따르지 않는다. 이번 작업은 호출만 하고 형식은 건드리지 않는다
- `league-season.md:9`의 "리그 점수는 레슨 첫 제출에서만 오른다"가 코드와 어긋난다. 피드 축하를 받으면 `SocialFacade.congratulateFeed:107`이 LP 5점을 지급한다

## Deviation Log
- `LessonSubmissionSaveResponse.java`: `isLevelUp`, `isLeaguePromoted`에 `@JsonProperty("isLevelUp")`, `@JsonProperty("isLeaguePromoted")` 추가 — 이유: 5. DTO의 근거("`LessonSummaryResponse.isSolved`가 같은 방식으로 `isSolved` 키로 나간다")가 사실과 다름. `isSolved`는 `@JsonProperty("isSolved")`로 키를 고정하고 있고, `UserResponse`, `MissionDetailResponse`, `ProblemResponse` 등 다른 응답 DTO의 `isXxx` 필드도 같은 방식임. 결정된 필드 이름을 확실히 고정하기 위해 기존 방식을 따름
- `UserServiceIntegrationTest.java`, `LessonFacadeIntegrationTest.java`, `UserLeagueServiceIntegrationTest.java`: 구현 단계에서 수정하지 않음 — 이유: 검증 섹션 시나리오 작성은 테스트 작성이라 implement 범위 밖. `write-test`에서 작성. 그 전까지 `UserServiceIntegrationTest:322,336`이 반환 타입 변경으로 컴파일되지 않음
- `LessonFacade.java`: 커밋 뒤 사후 조회 실패를 `RuntimeException`으로 잡아 로그를 남기고 `isLeaguePromoted` false로 응답 — 이유: PR #538 리뷰 반영. 원래는 드문 경우라 한계로 뒀으나, 이 PR이 커밋된 제출을 500으로 응답하는 경로를 새로 만들고, 클라이언트가 POST를 다시 보내면 중복 제출이 쌓임. false는 이미 "승급을 관측하지 못함"의 의미라 조회 실패도 같은 값으로 응답. 커넥션 획득 실패는 `@Transactional` 프록시가 트랜잭션을 시작하는 단계에서 나므로 서비스가 아닌 Facade에서 잡음. 사전 조회는 커밋 전이라 그대로 둠
