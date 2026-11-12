# [PLAN-450] 레슨 제출 기록을 이력 누적 구조로 전환

> 이슈: #450
> 브랜치: refactor/450-lesson-submission-history

## 목표

`LessonSubmission`을 유저와 레슨당 1행 덮어쓰기에서 제출마다 새 행을 쌓는 이력 구조로 바꾼다.
총 학습 시간, 평균 정확도, 주간 리포트가 실제 시도 이력을 반영하게 하고, 1행 전제를 깔고 있던 조회들을 함께 재설계한다.

## 선행 조건

## 영향 범위

### 신규 파일
- `src/main/resources/db/migration/V28__convert_lesson_submission_to_history.sql` — try_count 제거, created_at 백필

### 수정 파일
- `src/main/java/gravit/code/lesson/domain/LessonSubmission.java` — tryCount 필드와 갱신 메서드 3개 제거
- `src/main/java/gravit/code/lesson/repository/LessonSubmissionRepository.java` — 잠금 조회 제거, DISTINCT 집계 전환, 기준 시각을 createdAt으로 변경
- `src/main/java/gravit/code/lesson/service/LessonSubmissionCommandService.java` — 덮어쓰기 분기 제거, 항상 INSERT
- `src/main/java/gravit/code/lesson/service/LessonSubmissionQueryService.java` — 완료 레슨 수 조회를 DISTINCT 메서드로 교체
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` — saveLessonSubmission 호출에서 isFirstTry 인자 제거
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — LESSON_SUBMISSION_NOT_FOUND 제거
- `src/test/java/gravit/code/lesson/service/LessonSubmissionCommandServiceUnitTest.java` — 재풀이 시나리오 재작성
- `src/test/java/gravit/code/lesson/service/LessonSubmissionCommandServiceIntegrationTest.java` — 재풀이 시나리오 재작성
- `src/test/java/gravit/code/lesson/service/LessonSubmissionQueryServiceIntegrationTest.java` — 재시도 누적 케이스 추가
- `src/test/java/gravit/code/lesson/facade/LessonFacadeUnitTest.java` — 변경된 호출 시그니처에 맞춰 verify 수정

## 구현 계획

### 1. Entity / Flyway

`LessonSubmission`
- `tryCount` 필드 제거, `@Column(name = "try_count")` 제거
- 생성자의 `this.tryCount = 1;` 제거
- `updateTryCount()`, `updateLearningTime(int)`, `updateAccuracy(int)` 제거 — 이력 구조에서는 행을 갱신하지 않는다
- `create(...)`, `validateAccuracy(int)`는 그대로 유지

`V28__convert_lesson_submission_to_history.sql`
```sql
-- V28__convert_lesson_submission_to_history.sql
-- 레슨 제출을 유저+레슨당 1행 덮어쓰기에서 제출마다 새 행을 쌓는 이력 구조로 전환

-- 시도 횟수는 엔티티 필드 대신 행 개수로 센다
ALTER TABLE lesson_submission
    DROP COLUMN try_count;

-- 주간 리포트 기준 시각이 created_at으로 바뀌므로, V7 이전 행의 빈 created_at을 채운다
UPDATE lesson_submission
SET created_at = COALESCE(updated_at, NOW())
WHERE created_at IS NULL;
```

> 배포 순서 주의: `try_count`는 NOT NULL이라 구버전 인스턴스가 남아 있는 상태에서 컬럼을 드롭하면 해당 인스턴스의 INSERT가 실패한다. 마이그레이션과 애플리케이션 배포가 함께 나가는지 확인한다.

### 2. Repository — `LessonSubmissionRepository`

| 메서드 | 변경 |
|---|---|
| `findByLessonIdAndUserId` | **삭제**. 갱신 대상 행을 잡던 용도이며 `@Lock(PESSIMISTIC_WRITE)`도 함께 사라진다. `LockModeType`, `Lock` import 제거 |
| `countByUserId` | **삭제 후 교체** (아래 신규 메서드) |
| `findLearningRateTopPercent` | 서브쿼리의 `COUNT(ls.id) AS solved_count` → `COUNT(DISTINCT ls.lesson_id) AS solved_count` |
| `getPeakLearningHour` | `EXTRACT(HOUR FROM updated_at)` → `created_at`, `WHERE ... updated_at IS NOT NULL` → `created_at IS NOT NULL` |
| `findTopChaptersByUserIdInWeek` | SELECT의 `COUNT(l.id)` → `COUNT(DISTINCT l.id)`, `ls.updatedAt` → `ls.createdAt` |
| `countSolvedLessonsByUserIdInWeek` | `COUNT(ls.id)` → `COUNT(DISTINCT ls.lessonId)`, `ls.updatedAt` → `ls.createdAt` |
| `findWeakLessonsByUserId` | 아래 별도 항목 |
| `countLessonSubmissionByLessonIdAndUserId` | 변경 없음. 이제 실제 시도 횟수를 반환한다 |
| `existsByLessonIdAndUserId` | 변경 없음 |
| `countSolvedLessonByChapterIdAndUserId` / `...ByUnitIdAndUserId` | 변경 없음. 이미 `COUNT(DISTINCT l.id)` |
| `getTotalLearningTime` / `getAverageAccuracy` | 쿼리 변경 없음. 행이 시도 1건이 되면서 값이 저절로 교정된다 |

신규 메서드
```java
@Query("""
    SELECT COUNT(DISTINCT ls.lessonId)
    FROM LessonSubmission ls
    WHERE ls.userId = :userId
""")
long countDistinctLessonByUserId(@Param("userId") long userId);
```

`findWeakLessonsByUserId` 재작성
현재는 `FROM LessonSubmission ls JOIN Lesson l`이라 제출 1건당 1행이 나온다. 이력이 쌓이면 같은 레슨이 시도 횟수만큼 중복 반환된다.
집계 기준을 제출이 아니라 레슨으로 바꾼다. FROM 절을 `Lesson`으로 두고 제출 이력은 EXISTS 조건으로만 쓴다.

```java
@Query("""
    SELECT new gravit.code.learning.dto.internal.WeakLessonStatDto(
        l.id, u.title, c.title,
        (SELECT COUNT(DISTINCT ps.problemId)
         FROM ProblemSubmission ps
         WHERE ps.userId = :userId
           AND ps.isCorrect = false
           AND ps.problemId IN (SELECT p.id FROM Problem p WHERE p.lessonId = l.id)),
        (SELECT COUNT(p.id) FROM Problem p WHERE p.lessonId = l.id)
    )
    FROM Lesson l
    JOIN Unit u ON u.id = l.unitId
    JOIN Chapter c ON c.id = u.chapterId
    WHERE EXISTS (
        SELECT 1 FROM LessonSubmission ls
        WHERE ls.lessonId = l.id AND ls.userId = :userId
    )
    ORDER BY
        (1.0 * (SELECT COUNT(DISTINCT ps.problemId)
                FROM ProblemSubmission ps
                WHERE ps.userId = :userId
                  AND ps.isCorrect = false
                  AND ps.problemId IN (SELECT p.id FROM Problem p WHERE p.lessonId = l.id))
         / NULLIF((SELECT COUNT(p.id) FROM Problem p WHERE p.lessonId = l.id), 0)) DESC,
        l.id ASC
""")
List<WeakLessonStatDto> findWeakLessonsByUserId(
        @Param("userId") long userId,
        Pageable pageable
);
```
> 내부 서브쿼리의 `COUNT(DISTINCT ps.problemId)`는 PR #449가 이미 반영한 내용이다. 리베이스 후 중복 적용하지 않는다.

### 3. Service

`LessonSubmissionCommandService`
```java
@Transactional
public void saveLessonSubmission(
        long userId,
        LessonSubmissionSaveRequest request
)
```
- `isFirstTry` 파라미터 제거
- 분기 전체를 제거하고 항상 `LessonSubmission.create(...)` 후 `save`
- `findByLessonIdAndUserId` 조회와 `LESSON_SUBMISSION_NOT_FOUND` 예외 제거
- `lessonRepository.existsById` 검증은 유지

`LessonSubmissionQueryService`
- `getCompletedLessonCount(long userId)` — `countByUserId` → `countDistinctLessonByUserId` 호출로 교체. 반환 타입과 `Math.toIntExact` 래핑은 유지
- `getLessonSubmissionTryCount`, `checkFirstLessonSubmission`, `getTotalLearningHours`, `getAverageAccuracy`, `getPeakLearningHour`, `getTopChapters`, `getWeakConcepts` — 시그니처 변경 없음

`LearningProgressRateService`
- `getPlanetConquestRate`에서 `lessonSubmissionRepository.countByUserId` → `countDistinctLessonByUserId`
- `getLearningRankPercentile`, `getChapterProgress`, `getUnitProgress` — 변경 없음

`MissionService`
- 코드 변경 없음. `getLessonSubmissionTryCount`가 이제 실제 시도 횟수를 반환하면서 `tryCount > 1` 가드가 의미를 갖는다
- 다만 `LessonFacade`가 `isFirstTry`일 때만 `LessonCompletedEvent`를 발행하므로, 현재 흐름에서 이 가드는 여전히 발동하지 않는다. 아래 "결정 필요" 참고

### 4. Facade

`LessonFacade.saveLessonSubmission`
- `lessonSubmissionCommandService.saveLessonSubmission(userId, request.lessonSubmissionSaveRequest(), isFirstTry)` → 인자에서 `isFirstTry` 제거
- `isFirstTry` 변수 자체는 유지한다. `userService.updateUserLevelByLessonSubmission`의 경험치 지급 분기와 `LessonCompletedEvent` 발행 조건이 계속 사용한다
- 그 외 흐름 변경 없음

### 5. DTO
변경 없음. `LessonSubmissionSaveRequest(lessonId, learningTime, accuracy)`와 `LessonSubmissionSaveResponse`를 그대로 쓴다.

### 6. Controller
변경 없음. API 경로와 응답 스펙이 그대로다.

### 7. 예외 코드
`CustomErrorCode.LESSON_SUBMISSION_NOT_FOUND`는 유일한 사용처가 사라지므로 제거한다.

## 결정 필요 (Decisions needed)

- [x] `MissionService`의 `tryCount > 1` 가드를 어떻게 둘지 → **그대로 유지**
  이슈 본문은 이 가드가 "실제로 동작하게 된다"고 적었으나, 코드를 확인해 보니 사실과 다르다.
  `LessonFacade`는 `isFirstTry`일 때만 `LessonCompletedEvent`를 발행하고, `MissionEventListener`를 거쳐 `handleLessonMission`이 호출되는 시점에는 이미 첫 행이 INSERT된 뒤라 시도 횟수는 항상 1이다.
  즉 값은 정확해지지만 가드는 여전히 발동하지 않는다.
  가드는 코드 변경 없이 그대로 두고, 이벤트 게이트가 바뀌어도 미션이 중복 적립되지 않는 이중 방어로 남긴다.
  이벤트 발행 조건 자체를 손보는 선택지는 리스너 설계 영역이라 담당 범위 밖이며, 인계 사항으로 분류한다.

## 검증

- `LessonSubmissionCommandServiceUnitTest`
  - `재풀이면_기존_기록을_업데이트한다` → `재풀이면_새_행을_저장한다`로 교체. `findByLessonIdAndUserId` 호출이 없고 `save`가 호출되는지 검증
  - `재풀이인데_기존_기록이_없으면_예외를_던진다` 삭제. 해당 예외 경로가 사라진다
  - `첫_풀이면_새로_생성한다`, `레슨이_존재하지_않으면_예외를_던진다`는 인자 변경만 반영
- `LessonSubmissionCommandServiceIntegrationTest`
  - 같은 레슨을 2회 제출하면 행이 2개 쌓이고 각 행의 learningTime, accuracy가 제출값 그대로인지 검증
- `LessonSubmissionQueryServiceIntegrationTest`
  - `getCompletedLessonCount` — 같은 레슨 3회 제출 시 1을 반환 (DISTINCT)
  - `getLessonSubmissionTryCount` — 같은 레슨 3회 제출 시 3을 반환
  - `getTotalLearningHours` — 재시도분이 합산되는지 (기존 `학습_기록이_여러_개면...` 옆에 재시도 케이스 추가)
  - `getAverageAccuracy` — 40점, 100점 2회 제출 시 70을 반환
  - `getTopChapters` — 같은 레슨을 여러 번 제출해도 solvedLessonCount가 부풀지 않는지
  - `getWeakConcepts` — 같은 레슨 재제출 시 응답에 중복 레슨이 없는지
- `LessonFacadeUnitTest`
  - `lessonSubmissionCommandService.saveLessonSubmission(userId, request)` 2인자 verify로 수정
  - `재풀이면_이벤트를_발행하지_않는다`는 그대로 통과해야 한다
- `MissionServiceUnitTest`
  - 시도 횟수 2 스텁은 이제 서비스 계약상 유효한 입력이므로 유지한다
- `./gradlew build` — flyway validate 포함, V28 체크섬 확인

## Deviation Log

- `LessonSubmissionCommandServiceUnitTest`: `재풀이면_새_행을_저장한다`에서 `findByLessonIdAndUserId` 미호출 검증을 넣지 않았다 — 이유: 해당 메서드를 리포지토리에서 삭제해 `verify(..., never())` 대상 자체가 사라졌다. `save` 호출 검증만 남긴다
- `LearningProgressRateServiceUnitTest`: 계획서 수정 파일 목록에 없었으나 `countByUserId` 스텁 3건을 `countDistinctLessonByUserId`로 교체했다 — 이유: 메서드 삭제로 컴파일이 깨진다
- `LessonSubmissionQueryServiceIntegrationTest`: 계획서 "검증" 항목의 신규 케이스를 `write-test`로 넘겼다가 이후 모두 추가 완료 — 이력 누적 6개 케이스(시도 횟수 3, 완료 레슨 DISTINCT 1, 학습 시간 합산, 평균 정확도 70, TOP 챕터 미부풀림, 취약 개념 미중복)
- `LessonSubmissionQueryService.getTotalLearningHours()`: 계획서에 없던 변경 — 반환값을 소수점 첫째 자리 반올림으로 바꾸고 `SECONDS_PER_HOUR`, `LEARNING_HOURS_ROUNDING_SCALE` 상수를 도입했다. 이유: 사용자 요청(계획서 범위 밖의 별도 지시)
