# [PLAN-475] 레슨 풀이 저장의 검증, 저장 책임 분리

> 이슈: #475
> 브랜치: refactor/475-lesson-submission-save

## 목표

`POST /api/v1/lessons/results` 흐름에서 검증이 쓰기보다 먼저 실행되도록 순서를 바로잡고,
매핑 함수의 부수효과로 숨어 있던 오답노트 저장을 Facade의 명시적 조합으로 끌어올린다.
Service 간 직접 의존(`ProblemSubmissionCommandService` → `WrongAnsweredNoteService`)을 제거하고,
동작하지 않던 요청 DTO 중첩 검증을 살린다. 응답 필드와 예외 코드는 바꾸지 않는다.

## 이번 계획의 범위

이슈의 Task 중 **로직 개선**만 다룬다. 성능 작업(N+1 제거, 인덱스)은 별도 작업으로 분리한다.

| 이슈 Task | 이번 계획 |
|---|---|
| 레슨 존재 검증을 `getLearningIdsByLessonId`로 흡수 | 포함 |
| 문제 유형 검증과 문제 제출 저장 분리 | 포함 |
| 문제 제출 저장이 오답 문제 ID 목록 반환 → Facade가 조합 | 포함 |
| `WrongAnsweredNoteService` 의존 제거 | 포함 |
| Facade 흐름 재배치 (`isFirstTry` 선행 유지) | 포함 |
| `LearningSubmissionSaveRequest`에 `@Valid`, `@NotNull` | 포함 |
| 변경 범위 테스트 보강 | 포함 |
| 오답노트 조회·저장 목록 단위 일괄 처리 (N+1) | **제외** — 인덱스 작업과 함께 성능 작업으로 분리 |
| `wrong_answered_note` 인덱스 마이그레이션 | **제외** — 별도 성능 작업으로 분리 |

`WrongAnsweredNoteService`는 이번에 손대지 않는다. Facade가 반환받은 오답 문제 ID 목록을 순회하며
기존 단건 메서드 `saveWrongAnsweredNote(userId, problemId)`를 호출한다.
오답노트 관련 쿼리 수는 지금과 동일하게 유지된다. 순회를 목록 단위 일괄 처리로 바꾸는 것은 후속 성능 작업이다.

## 영향 범위

### 신규 파일

- 없음

### 수정 파일

- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` — `saveLessonSubmission`을 검증 → 저장 → 응답 조회 순으로 재배치, 오답노트 저장 조합 추가, 설명 주석 제거
- `src/main/java/gravit/code/lesson/service/LessonSubmissionCommandService.java` — `lessonRepository.existsById` 검증과 `LessonRepository` 의존 제거, 저장만 담당
- `src/main/java/gravit/code/problem/service/ProblemSubmissionCommandService.java` — `WrongAnsweredNoteService` 의존 제거, 검증(`validateProblemSubmissions`)과 저장(`saveProblemSubmissions`) 분리, 저장이 오답 문제 ID 목록 반환, 단건 메서드 제거
- `src/main/java/gravit/code/problem/facade/ProblemFacade.java` — 단건 문제 제출 조합 메서드 `saveProblemSubmission` 추가
- `src/main/java/gravit/code/problem/controller/ProblemController.java` — `POST /results` 위임 대상을 `ProblemSubmissionCommandService`에서 `ProblemFacade`로 변경
- `src/main/java/gravit/code/learning/dto/request/LearningSubmissionSaveRequest.java` — `@Valid`, `@NotNull` 추가

정책 파일 변경 없음. `content.md`의 "레슨 정답률은 0~100 범위만 저장할 수 있다"는 이미 문서에 있으나
`@Valid` 누락으로 코드에서 실행되지 않던 규칙이고, 이번 변경으로 문서대로 동작하게 된다. 정책 자체는 바뀌지 않는다.

## 구현 계획

### 1. Entity / Flyway

DB 변경 없음. `wrong_answered_note` 인덱스는 이번 범위에서 제외한다.

### 2. Repository

변경 없음. `WrongAnsweredNoteRepository`, `LessonRepository`, `ProblemSubmissionRepository` 모두 그대로 둔다.

### 3. Service

#### 3-1. `LessonSubmissionCommandService`

- 필드 `private final LessonRepository lessonRepository;` 제거, 쓰이지 않게 되는 import(`LessonRepository`, `CustomErrorCode`, `RestApiException`) 정리
- `saveLessonSubmission(long userId, LessonSubmissionSaveRequest request)` 본문에서 아래 2줄 삭제

```java
if(!lessonRepository.existsById(request.lessonId()))
    throw new RestApiException(CustomErrorCode.LESSON_NOT_FOUND);
```

- 결과: `LessonSubmission.create(...)` → `lessonSubmissionRepository.save(...)`만 남는다
- 레슨 존재 검증은 `LessonFacade`가 호출 순서상 앞에서 `lessonQueryService.getLearningIdsByLessonId(lessonId)`로 수행한다.
  이 메서드도 실패 시 `LESSON_NOT_FOUND`를 던지므로 API 응답은 동일하다

#### 3-2. `ProblemSubmissionCommandService`

- 필드 `private final WrongAnsweredNoteService wrongAnsweredNoteService;`와 해당 import 제거
- 단건 메서드 `saveProblemSubmission(long, ProblemSubmissionRequest)` 제거 (`ProblemFacade`가 목록 메서드를 재사용해 대체)
- `createProblemSubmission`에서 `wrongAnsweredNoteService.saveWrongAnsweredNote` 호출 제거 → 순수 매핑 함수로 환원

```java
private ProblemSubmission createProblemSubmission(
        long userId,
        ProblemSubmissionRequest request
) {
    return ProblemSubmission.create(
            request.isCorrect(),
            request.problemId(),
            userId,
            request.selectedOptionId(),
            request.submittedContent()
    );
}
```

- 검증 메서드 신설

```java
@Transactional(readOnly = true)
public void validateProblemSubmissions(List<ProblemSubmissionRequest> requests) {
    List<Long> problemIds = requests.stream()
            .map(ProblemSubmissionRequest::problemId)
            .toList();

    Map<Long, ProblemType> problemTypes = findProblemTypes(problemIds);

    requests.forEach(request -> validateSubmission(request, problemTypes));
}
```

- 저장 메서드는 시그니처를 `void` → `List<Long>`(오답 문제 ID 목록)으로 바꾸고 검증 호출을 뺀다

```java
@Transactional
public List<Long> saveProblemSubmissions(
        long userId,
        List<ProblemSubmissionRequest> requests
) {
    List<ProblemSubmission> problemSubmissions = requests.stream()
            .map(request -> createProblemSubmission(userId, request))
            .toList();

    problemSubmissionRepository.saveAll(problemSubmissions);

    return requests.stream()
            .filter(request -> !request.isCorrect())
            .map(ProblemSubmissionRequest::problemId)
            .toList();
}
```

- `findProblemTypes`, `validateSubmission`, `validateSubmissionContent`는 private으로 유지 (내용 변경 없음)

> 검증과 저장이 별도 public 메서드가 되므로, 저장만 단독 호출하면 문제 유형 검증이 건너뛰어진다.
> 두 메서드의 유일한 호출자는 `LessonFacade`와 `ProblemFacade`이고, 둘 다 검증 → 저장 순으로 호출한다.

#### 3-3. `WrongAnsweredNoteService`

변경 없음. 기존 `saveWrongAnsweredNote(long userId, long problemId)`를 그대로 쓴다.

### 4. Facade

#### 4-1. `LessonFacade.saveLessonSubmission` — 필요 (레슨·문제·오답노트·유저·리그·학습 도메인 조합)

```java
@Transactional
public LessonSubmissionSaveResponse saveLessonSubmission(
        long userId,
        LearningSubmissionSaveRequest request
){
    LessonSubmissionSaveRequest lessonSubmissionSaveRequest = request.lessonSubmissionSaveRequest();

    LearningIdsDto learningIdsDto = lessonQueryService.getLearningIdsByLessonId(lessonSubmissionSaveRequest.lessonId());
    problemSubmissionCommandService.validateProblemSubmissions(request.problemSubmissionRequests());

    boolean isFirstTry = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lessonSubmissionSaveRequest.lessonId());

    lessonSubmissionCommandService.saveLessonSubmission(userId, lessonSubmissionSaveRequest);

    List<Long> wrongAnsweredProblemIds = problemSubmissionCommandService.saveProblemSubmissions(userId, request.problemSubmissionRequests());
    wrongAnsweredProblemIds.forEach(problemId -> wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId));

    UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByLessonId(lessonSubmissionSaveRequest.lessonId());
    String leagueName = userLeagueService.getUserLeagueName(userId);
    UserLevelResponse userLevelResponse = userService.updateUserLevelByLessonSubmission(userId, lessonSubmissionSaveRequest, isFirstTry);

    ConsecutiveSolvedDto consecutiveSolvedDto = learningCommandService.updateLearningStatus(userId, learningIdsDto.chapterId());

    if(isFirstTry){
        publisher.publishEvent(new LessonCompletedEvent(
                userId,
                learningIdsDto.lessonId(),
                learningIdsDto.chapterId(),
                POINT_PER_LESSON,
                lessonSubmissionSaveRequest.accuracy(),
                lessonSubmissionSaveRequest.learningTime(),
                consecutiveSolvedDto.before(),
                consecutiveSolvedDto.after()
        ));
    }

    return LessonSubmissionSaveResponse.create(
            leagueName,
            userLevelResponse,
            unitSummaryResponse
    );
}
```

순서에 대한 근거:

- `getLearningIdsByLessonId`를 기존 위치(저장 이후)에서 맨 앞으로 옮겨 레슨 존재 검증을 겸하게 한다.
  중복 조회(`existsById`)가 사라지고 레슨 조회가 2회에서 1회로 준다
- `validateProblemSubmissions`를 저장보다 앞에 둬 `PROBLEM_NOT_FOUND` / `PROBLEM_TYPE_MISMATCH`가 쓰기 전에 나오게 한다
- 예외 우선순위는 기존과 동일하다. 레슨 없음(`LESSON_NOT_FOUND`)이 문제 검증보다 먼저다
- **`isFirstTry` 판정은 `lessonSubmissionCommandService.saveLessonSubmission`보다 반드시 앞에 둔다.**
  뒤로 가면 항상 `false`가 되어 XP 지급과 `LessonCompletedEvent`가 조용히 사라진다
- 오답노트 저장은 문제 제출 저장 **뒤**로 간다. 기존에는 매핑 단계에서 오답노트가 문제 제출보다 먼저 저장됐으나,
  같은 트랜잭션 안이고 두 테이블 간 제약이 없어 결과는 같다
- 응답 조회 블록(`unitSummaryResponse` → `leagueName` → `userLevelResponse`)과 이벤트 발행 위치는
  기존 상대 순서를 그대로 유지한다. `LessonCompletedEvent` 리스너가 리그 점수를 갱신하므로
  `getUserLeagueName`과 발행 순서를 바꾸면 응답의 `leagueName`이 달라질 수 있다
- `request.lessonSubmissionSaveRequest()`를 지역 변수로 뽑아 6회 반복 호출을 없앤다
- 설명 주석(`// 첫번째 풀이인지 체크` 등)은 `common.md`("메인 코드에 설명 주석을 달지 마라")에 따라 제거하고, 빈 줄 그룹핑으로 단계를 드러낸다

#### 4-2. `ProblemFacade.saveProblemSubmission` — 필요 (문제 + 오답노트 조합)

`ProblemSubmissionCommandService`에서 오답노트 의존을 걷어내면 단건 엔드포인트(`POST /api/v1/problems/results`)도
오답노트가 저장되지 않는다. 조합 책임을 Facade로 올려 기존 동작을 유지한다.

기존 필드(`problemQueryService`, `unitQueryService`, `problemFactory`) 아래에 도메인별 그룹으로 추가한다.

```java
private final ProblemSubmissionCommandService problemSubmissionCommandService;
private final WrongAnsweredNoteService wrongAnsweredNoteService;

@Transactional
public void saveProblemSubmission(
        long userId,
        ProblemSubmissionRequest request
) {
    List<ProblemSubmissionRequest> requests = List.of(request);

    problemSubmissionCommandService.validateProblemSubmissions(requests);

    List<Long> wrongAnsweredProblemIds = problemSubmissionCommandService.saveProblemSubmissions(userId, requests);
    wrongAnsweredProblemIds.forEach(problemId -> wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId));
}
```

### 5. DTO

`LearningSubmissionSaveRequest` — 두 필드 모두 중첩 검증이 캐스케이드되도록 고친다.

```java
@Schema(description = "레슨 풀이 제출 결과")
@Valid
@NotNull(message = "레슨 풀이 제출 결과가 비어있습니다.")
LessonSubmissionSaveRequest lessonSubmissionSaveRequest,

@Schema(description = "문제 풀이 제출 리스트")
@Valid
@NotNull(message = "문제 풀이 제출 리스트가 비어있습니다.")
List<ProblemSubmissionRequest> problemSubmissionRequests
```

- `lessonSubmissionSaveRequest`에 `@Valid`를 붙여야 `LessonSubmissionSaveRequest`의 `@NotNull`, `@Min(0)`, `@Max(100)`이 비로소 실행된다
- `problemSubmissionRequests`의 `@NotNull`은 이슈 Task에 없는 추가분이다. 현재 이 필드가 null이면
  `validateProblemSubmissions`의 `requests.stream()`에서 NPE(500)가 난다. 같은 결함이라 함께 막는다
- `lessonSubmissionSaveRequest`의 `@Schema` description이 "레슨 풀이 제출 리스트"로 잘못돼 있어 함께 고친다
- 동작 변화: 두 필드가 null이던 요청, `accuracy`가 범위 밖인 요청의 응답이 500(또는 무검증 통과) → 400으로 바뀐다.
  잘못된 요청을 잘못됐다고 응답하게 되는 변화다

### 6. Controller

- `POST /api/v1/lessons/results` → `LessonController.saveLessonSubmission` — 변경 없음
- `POST /api/v1/problems/results` → `ProblemController.saveProblemSubmission` — 위임 대상만 교체

```java
private final ProblemFacade problemFacade;

problemFacade.saveProblemSubmission(loginUser.getId(), request);
```

`ProblemSubmissionCommandService` 필드와 import를 제거한다. `ProblemControllerDocs`는 시그니처가 그대로라 변경 없다.

## 결정 필요 (Decisions needed)

- [x] **A. 오답노트 목록 단위 일괄 처리(N+1 제거) 포함 여부** → **제외**.
  `WrongAnsweredNoteService`는 손대지 않고, Facade가 반환받은 오답 ID 목록을 순회하며 단건 메서드를 호출한다.
  N+1과 인덱스는 후속 성능 작업에서 함께 다룬다
- [x] **B. 단건 엔드포인트 `POST /api/v1/problems/results` 처리 방식** → **`ProblemFacade`로 조합 이동**.
  Service의 단건 메서드는 제거하고 목록 메서드로 흡수한다. 단건 제출 시 오답노트가 저장되는 동작은 그대로 유지된다
- [x] **C. `problemSubmissionRequests`에 `@NotNull` 추가 여부** → **추가**. null 요청이 500 → 400이 된다

## 검증

### 수정이 필요한 기존 테스트

- `src/test/java/gravit/code/lesson/service/LessonSubmissionCommandServiceUnitTest.java` — `LESSON_NOT_FOUND`를 기대하는 케이스(L75 부근)와 `lessonRepository` 스텁 제거
- `src/test/java/gravit/code/lesson/service/LessonSubmissionCommandServiceIntegrationTest.java` — 동일 케이스(L94 부근) 제거
- `src/test/java/gravit/code/problem/service/ProblemSubmissionCommandServiceIntegrationTest.java`
  - 검증 실패 케이스(L213·228·243·294·313)를 `validateProblemSubmissions` 대상으로 옮긴다
  - 단건 메서드 케이스(L331~426)는 `ProblemFacade` 테스트로 이동한다
  - 오답노트 저장을 확인하던 단언은 제거한다 (더 이상 이 Service의 책임이 아니다)
- `src/test/java/gravit/code/lesson/facade/LessonFacadeUnitTest.java` — `getLearningIdsByLessonId` 스텁이 검증 단계로 앞당겨지고, `saveProblemSubmissions`가 `List<Long>`을 반환하도록 스텁 수정

`WrongAnsweredNoteServiceUnitTest`, `WrongAnsweredNoteServiceIntegrationTest`는 변경 없다.

### 보강할 시나리오

- `LessonFacadeUnitTest`
  - 존재하지 않는 레슨이면 `LESSON_NOT_FOUND`가 나고 `lessonSubmissionCommandService.saveLessonSubmission`이 호출되지 않는다
  - 문제 검증에 실패하면 `saveLessonSubmission`과 `saveProblemSubmissions`가 모두 호출되지 않는다 (`InOrder`로 검증 → 저장 순서 고정)
  - `checkFirstLessonSubmission`이 `saveLessonSubmission`보다 먼저 호출된다 (`InOrder`) — 순서가 뒤집히면 XP·이벤트가 조용히 사라지는 제약이라 테스트로 못 박는다
  - 오답이 섞인 요청이면 `saveProblemSubmissions`가 돌려준 오답 ID마다 `saveWrongAnsweredNote`가 호출된다
  - 전부 정답이면 `saveWrongAnsweredNote`가 한 번도 호출되지 않는다
- `ProblemSubmissionCommandService` 테스트
  - `saveProblemSubmissions`가 오답 문제 ID만, 요청 순서대로 반환한다
  - 전부 정답이면 빈 목록을 반환한다
  - `validateProblemSubmissions`가 `PROBLEM_NOT_FOUND` / `PROBLEM_TYPE_MISMATCH`를 그대로 던진다
- `ProblemFacade` 단건 제출 테스트 — 오답 제출 시 오답노트가 저장되고, 정답 제출 시 저장되지 않는다
- 요청 DTO 검증 (Controller 슬라이스 테스트) — `lessonSubmissionSaveRequest`가 null, `problemSubmissionRequests`가 null, `accuracy`가 101일 때 각각 400이 나온다

### 실행

```bash
./gradlew test
```

## Deviation Log
