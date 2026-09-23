# [PLAN-554] 레슨 결과 응답에 챕터 아이디 추가

> 이슈: #554
> 브랜치: feat/554-lesson-result-chapter-id

## 목표
레슨 결과 조회(`GET /api/v1/lessons/results/{lessonSubmissionId}`) 응답에 조회한 제출 건의 레슨이 속한 챕터 아이디(`chapterId`)를 추가한다.
클라이언트가 결과 화면 이후 해당 챕터로 이동하려면 챕터 아이디가 필요한데, 지금 응답에는 유닛 요약 정보만 있다.

응답 예

```json
{
  "leagueName": "브론즈",
  "userLevelResponse": { ... },
  "unitSummaryResponse": { ... },
  "accuracy": 79,
  "learningTime": 80,
  "chapterId": 1
}
```

## 배치 기준
- **필드는 `LessonResultResponse`에 `chapterId` 하나로 직접 둔다.** `UnitSummaryResponse`에 넣으면 북마크, 오답 노트, 문제, 레슨 목록 응답까지 스키마가 바뀐다. 클라이언트가 요청한 것은 이 API의 챕터 아이디뿐이다. 챕터 제목 등 요약 정보는 요청 범위가 아니라 담지 않는다
- **기존 필드 순서를 흔들지 않도록 맨 뒤(`learningTime` 뒤)에 붙인다.** PLAN-550과 같은 기준이다
- **새 쿼리를 추가하지 않고 기존 제출 조회를 넓힌다.** `getLessonResult`는 이미 `findSubmittedLessonByIdAndUserId`로 제출 행을 읽는다. 이 조회에 `Lesson`, `Unit`을 조인해 `u.chapterId`를 함께 가져오면 쿼리 수가 늘지 않는다. `LessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId`가 같은 조인(`LessonSubmission` → `Lesson` → `Unit`)을 이미 쓴다
- **조인은 내부 조인이다.** `lesson_submission` → `lesson` → `unit` 사이에 FK는 없지만, 메인 코드에 레슨, 유닛을 지우는 경로가 없어 고아 제출 행은 생기지 않는다. 만약 생기면 지금은 뒤따르는 유닛 조회에서 `UNIT_NOT_FOUND`가 나고, 바뀐 뒤에는 제출 조회에서 `LESSON_SUBMISSION_NOT_FOUND`가 난다. 둘 다 404라 클라이언트 동작은 같다
- **본인 제출만 조회하는 조건(`ls.userId = :userId`)과 없으면 `LESSON_SUBMISSION_NOT_FOUND`를 던지는 동작은 그대로다**
- **정책 변경 없음.** `content.md`의 챕터 > 유닛 > 레슨 계층을 그대로 노출할 뿐이다
- **`LessonControllerDocs`는 바꾸지 않는다.** 200 응답에 예시 JSON이 없고 스키마를 DTO에서 가져온다
- **Controller, Service 메서드 시그니처는 바꾸지 않는다**

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/java/gravit/code/lesson/dto/internal/SubmittedLessonDto.java` - `chapterId` 컴포넌트 추가
- `src/main/java/gravit/code/lesson/repository/LessonSubmissionRepository.java` - `findSubmittedLessonByIdAndUserId`에 `Lesson`, `Unit` 조인과 `u.chapterId` 프로젝션 추가
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` - `getLessonResult`가 `submittedLesson.chapterId()`를 응답에 담음
- `src/main/java/gravit/code/lesson/dto/response/LessonResultResponse.java` - `chapterId` 컴포넌트 추가, `create` 파라미터 추가
- `src/test/java/gravit/code/lesson/facade/LessonFacadeIntegrationTest.java` - `GetLessonResult`에 챕터 아이디 검증 테스트 추가

## 구현 계획
1. **Entity / Flyway**: 변경 없음 - `unit.chapter_id`가 이미 있다
2. **DTO (internal)**: `SubmittedLessonDto`에 `chapterId` 추가
   ```java
   public record SubmittedLessonDto(
           long lessonId,

           long chapterId,

           int accuracy,

           int learningTime
   ) {
   }
   ```
3. **Repository**: `LessonSubmissionRepository.findSubmittedLessonByIdAndUserId(long lessonSubmissionId, long userId)` → `Optional<SubmittedLessonDto>` (시그니처 유지, 쿼리만 변경)
   ```java
   @Query("""
           SELECT new gravit.code.lesson.dto.internal.SubmittedLessonDto(
               ls.lessonId, u.chapterId, ls.accuracy, ls.learningTime
           )
           FROM LessonSubmission ls
           JOIN Lesson l ON l.id = ls.lessonId
           JOIN Unit u ON u.id = l.unitId
           WHERE ls.id = :lessonSubmissionId AND ls.userId = :userId
   """)
   ```
4. **Service**: 변경 없음 - `LessonSubmissionQueryService.getSubmittedLesson`이 DTO를 그대로 반환한다
5. **Facade**: 새 Facade는 불필요, `LessonFacade.getLessonResult(long userId, long lessonSubmissionId)`에서 `LessonResultResponse.create` 호출에 `submittedLesson.chapterId()`를 마지막 인자로 추가한다
6. **DTO (response)**: `LessonResultResponse`
   - `learningTime` 뒤에 컴포넌트 추가
     ```java
     @Schema(
             description = "레슨이 속한 챕터 아이디",
             example = "1",
             requiredMode = Schema.RequiredMode.REQUIRED
     )
     long chapterId
     ```
   - `create(String leagueName, UserLevelResponse userLevelResponse, UnitSummaryResponse unitSummaryResponse, int accuracy, int learningTime, long chapterId)`
7. **Controller**: 변경 없음 - `GET /api/v1/lessons/results/{lessonSubmissionId}` → `LessonController.getLessonResult`

## 결정 필요 (Decisions needed)
- 없음

## 검증
- 대상 테스트: `LessonFacadeIntegrationTest.GetLessonResult`
  - 신규: 챕터, 유닛, 레슨을 직접 만들어 제출하고 조회하면 `chapterId`가 만든 챕터의 아이디와 같다
  - 기존 `타인의_제출_아이디로_조회하면_실패한다`가 `LESSON_SUBMISSION_NOT_FOUND`를 유지하는지 확인
  - 기존 `GetLessonResult` 테스트 전체 통과

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
