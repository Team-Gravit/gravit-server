# [PLAN-550] 레슨 결과 화면 표시 정보 추가

> 이슈: #550
> 브랜치: feat/550-level-xp-boundary
> 범위 확장: XP 경계값 구현 후 프론트엔드가 정답률과 풀이 시간을 추가로 요청해 같은 이슈, PR에 합쳤다

## 목표
레슨 결과 조회(`GET /api/v1/lessons/results/{lessonSubmissionId}`) 응답에 결과 화면이 쓰는 값 두 가지를 추가한다.

1. `LessonResultResponse.userLevelResponse`에 현재 레벨의 XP 구간인 `minXp`, `maxXp`를 추가한다. 지금은 `currentLevel`, `nextLevel`, `xp`만 있어 프론트엔드가 XP 프로그래스 바 구간을 알 수 없다
2. `LessonResultResponse`에 조회한 제출 건의 정답률(`accuracy`)과 풀이 시간(`learningTime`)을 추가한다. 두 값은 제출 기록에 이미 저장돼 있지만 결과 조회 응답에는 나가지 않는다

응답 예 (3레벨, 누적 XP 250, 정답률 79, 풀이 시간 80초)

```json
{
  "leagueName": "브론즈",
  "userLevelResponse": {
    "currentLevel": 3,
    "nextLevel": 4,
    "xp": 250,
    "minXp": 200,
    "maxXp": 400
  },
  "unitSummaryResponse": { ... },
  "accuracy": 79,
  "learningTime": 80
}
```

최고 레벨 (10레벨, 누적 XP 5000)이면 `"minXp": 3700, "maxXp": 5000`이다.

## 배치 기준

### XP 경계값
- **필드는 `UserLevelResponse`에 둔다.** 이슈 발의 때 확정했다. 레벨 관련 값(`currentLevel`, `nextLevel`, `xp`)이 이미 여기 모여 있다. `UserLevelResponse`를 만드는 곳은 `UserService.getUserLevel` 한 곳, 담는 곳은 `LessonResultResponse` 한 곳이라 다른 API 응답은 바뀌지 않는다
- **`minXp`는 현재 레벨의 시작 XP(`Level.getStartXp()`), `maxXp`는 다음 레벨의 시작 XP(`Level.getEndXp()`)다.** `service-policy/user.md`의 레벨 구간 정의를 그대로 노출할 뿐이라 정책은 바뀌지 않는다
- **최고 레벨이면 `maxXp`는 현재 `xp`다.** `Level.getEndXp()`는 최고 레벨에서 예외를 던진다. 메인페이지, 프로필에 쓰는 `UserLevel.getUserLevelDetail()`의 `maxXp`와 같은 규칙이고, 프로그래스 바가 가득 찬다(`user.md`: 최고 레벨 진행률은 항상 100%)
- **최고 레벨에 막 도달해 `xp`가 3700이면 `minXp`와 `maxXp`가 모두 3700이다.** 프론트가 `(xp - minXp) / (maxXp - minXp)`로 계산하면 0으로 나누게 된다. 프론트는 `currentLevel == nextLevel`로 최고 레벨을 판별해 가득 찬 바로 그려야 한다. 프론트에 전달할 사항이다
- **계산은 `UserLevelResponse.create` 안에서 한다.** 이미 `nextLevel`을 이 팩토리에서 `Level` enum으로 계산하고 있다. 팩토리 시그니처(`create(int level, int xp)`)는 그대로라 `UserService`는 바꾸지 않는다
- **레벨은 `Level.fromLevel(level)`로 구한다.** 기존 `nextLevel` 계산, `UserLevel.getUserLevelDetail()`의 `maxXp` 계산과 같은 기준이다. `fromLevel`을 한 번만 호출해 `nextLevel`, `minXp`, `maxXp` 계산에 함께 쓴다
- **`UserLevel.getUserLevelDetail()`과의 최고 레벨 분기 중복은 정리하지 않는다.** 한 줄짜리 삼항식 두 곳이고, 합치려면 `UserLevel`, `Level`까지 손대야 해 이번 범위를 넘는다
- **`xp`의 `@Schema` 예시값을 `100`에서 `250`으로 고친다.** 3레벨 예시와 맞지 않는 값이다(3레벨은 200부터). 새 필드 예시(`200`, `400`)와 한 화면에서 읽히도록 맞춘다

### 정답률, 풀이 시간
- **값은 조회한 제출 건(`lessonSubmissionId`)의 것이다.** 레슨 제출은 이력으로 쌓이므로(`content.md`) 같은 레슨의 최신 제출이나 평균이 아니라, 요청받은 제출 행의 `accuracy`, `learning_time`을 그대로 내려준다. 저장된 값을 노출할 뿐이라 정책은 바뀌지 않는다
- **필드는 `LessonResultResponse`에 직접 둔다.** 레벨 정보가 아니라 제출 결과라서 `UserLevelResponse`에 넣지 않는다. 기존 필드 순서를 흔들지 않도록 `unitSummaryResponse` 뒤에 붙인다
- **필드 이름과 단위는 제출 요청(`LessonSubmissionSaveRequest`)과 같게 둔다.** `accuracy`는 0~100 정수, `learningTime`은 초 단위 정수다. 앱이 보낸 이름 그대로 돌려받으면 매핑이 필요 없다
- **새 쿼리를 추가하지 않고 기존 제출 조회를 넓힌다.** `getLessonResult`는 이미 `findLessonIdByIdAndUserId`로 같은 제출 행을 읽어 `lessonId`만 가져온다. 이 조회가 `lessonId`, `accuracy`, `learningTime`을 함께 가져오게 바꾸면 쿼리 수가 늘지 않는다. 본인 제출만 조회하는 조건(`ls.userId = :userId`)과 없으면 `LESSON_SUBMISSION_NOT_FOUND`를 던지는 동작은 그대로다
- **조회 결과는 `dto/internal`의 `SubmittedLessonDto`로 받는다.** JPQL 생성자 표현식 대상이라 표준 생성자를 그대로 쓴다(`dto.md`). 기존 메서드(`findLessonIdByIdAndUserId`, `getSubmittedLessonId`)는 호출처가 `LessonFacade.getLessonResult` 한 곳뿐이라 새 메서드로 바꾸고 없앤다

### 공통
- **`LessonControllerDocs`는 바꾸지 않는다.** 200 응답에 예시 JSON이 없고 스키마를 DTO에서 가져온다
- **Controller, `UserService`는 바꾸지 않는다**

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/lesson/dto/internal/SubmittedLessonDto.java` - 제출 행에서 읽은 레슨 아이디, 정답률, 풀이 시간

### 수정 파일
- `src/main/java/gravit/code/user/dto/response/UserLevelResponse.java` - `minXp`, `maxXp` 컴포넌트 추가, `create`에서 계산, `xp` 예시값 수정 (구현 완료)
- `src/main/java/gravit/code/lesson/repository/LessonSubmissionRepository.java` - `findLessonIdByIdAndUserId`를 `findSubmittedLessonByIdAndUserId`로 교체
- `src/main/java/gravit/code/lesson/service/LessonSubmissionQueryService.java` - `getSubmittedLessonId`를 `getSubmittedLesson`으로 교체
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` - `getLessonResult`가 제출 결과를 받아 응답에 담음
- `src/main/java/gravit/code/lesson/dto/response/LessonResultResponse.java` - `accuracy`, `learningTime` 컴포넌트 추가, `create` 파라미터 추가

## 구현 계획
1. **Entity / Flyway**: 변경 없음 - `lesson_submission`에 `accuracy`, `learning_time`이 이미 있다
2. **DTO (internal)**: `SubmittedLessonDto` (신규)
   ```java
   public record SubmittedLessonDto(
           long lessonId,

           int accuracy,

           int learningTime
   ) {
   }
   ```
3. **Repository**: `LessonSubmissionRepository.findSubmittedLessonByIdAndUserId(long lessonSubmissionId, long userId)` → `Optional<SubmittedLessonDto>` (기존 `findLessonIdByIdAndUserId` 삭제)
   ```java
   @Query("""
           SELECT new gravit.code.lesson.dto.internal.SubmittedLessonDto(
               ls.lessonId, ls.accuracy, ls.learningTime
           )
           FROM LessonSubmission ls
           WHERE ls.id = :lessonSubmissionId AND ls.userId = :userId
   """)
   ```
4. **Service**: `LessonSubmissionQueryService.getSubmittedLesson(long userId, long lessonSubmissionId)` → `SubmittedLessonDto` (기존 `getSubmittedLessonId` 삭제)
   - `findSubmittedLessonByIdAndUserId(lessonSubmissionId, userId)`가 비면 `RestApiException(LESSON_SUBMISSION_NOT_FOUND)`
   - `@Transactional(readOnly = true)` 유지
5. **Facade**: `LessonFacade.getLessonResult(long userId, long lessonSubmissionId)` - 새 Facade는 불필요, 기존 메서드만 고친다
   ```java
   SubmittedLessonDto submittedLesson = lessonSubmissionQueryService.getSubmittedLesson(userId, lessonSubmissionId);

   String leagueName = userLeagueService.getUserLeagueName(userId);
   UserLevelResponse userLevelResponse = userService.getUserLevel(userId);
   UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByLessonId(submittedLesson.lessonId());

   return LessonResultResponse.create(
           leagueName,
           userLevelResponse,
           unitSummaryResponse,
           submittedLesson.accuracy(),
           submittedLesson.learningTime()
   );
   ```
6. **DTO (response)**
   - `UserLevelResponse` (구현 완료)
     - `minXp` (`@Schema` description "현재 레벨 시작 경험치", example "200"), `maxXp` (description "다음 레벨 시작 경험치 (최고 레벨이면 현재 경험치와 동일)", example "400")
     - `create`에서 `Level currentLevel = Level.fromLevel(level)`로 `minXp = currentLevel.getStartXp()`, `maxXp = currentLevel.isMax() ? xp : currentLevel.getEndXp()`
   - `LessonResultResponse`
     - `unitSummaryResponse` 뒤에 컴포넌트 추가
       ```java
       @Schema(
               description = "정답률(단위 : 정수, 0~100)",
               example = "79",
               requiredMode = Schema.RequiredMode.REQUIRED
       )
       int accuracy,

       @Schema(
               description = "풀이 시간(단위 : 정수 초) / 1분 20초가 걸렸다면 80",
               example = "80",
               requiredMode = Schema.RequiredMode.REQUIRED
       )
       int learningTime
       ```
     - `create(String leagueName, UserLevelResponse userLevelResponse, UnitSummaryResponse unitSummaryResponse, int accuracy, int learningTime)`
7. **Controller**: 변경 없음 - `GET /api/v1/lessons/results/{lessonSubmissionId}` → `LessonController.getLessonResult`

## 결정 필요 (Decisions needed)
- [x] 정답률, 풀이 시간 작업을 담을 곳 - #550, PR #551에 합친다 (새 이슈로 분리하지 않음)

## 검증
- 대상 테스트: `UserLevelResponseTest` (`src/test/java/gravit/code/user/dto/response/`)
  - 중간 레벨 (`create(3, 250)` → `minXp` 200, `maxXp` 400)
  - 구간 시작 XP와 같을 때 (`create(3, 200)` → `minXp` 200, `maxXp` 400)
  - 최고 레벨 (`create(10, 5000)` → `minXp` 3700, `maxXp` 5000)
  - 최고 레벨에 막 도달했을 때 (`create(10, 3700)` → `minXp`, `maxXp` 모두 3700)
- 대상 테스트: `LessonFacadeIntegrationTest.GetLessonResult`
  - 같은 레슨을 정답률, 풀이 시간을 달리해 두 번 제출하고 첫 제출 아이디로 조회하면 첫 제출의 `accuracy`, `learningTime`을 반환한다 (최신 제출 값이 섞이지 않음을 확인)
  - 기존 `타인의_제출_아이디로_조회하면_실패한다`가 `LESSON_SUBMISSION_NOT_FOUND`를 유지하는지 확인

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
