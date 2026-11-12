# [PLAN-608] 재시도 큐 중복 처리와 유실, 지연 해소

> 이슈: #608
> 브랜치: fix/608-retry-queue-integrity

## 목표
재시도 큐는 "재처리 성공 → 항목 제거"가 원자적이지 않아, 제거가 실패하거나 그 사이 서버가 종료되면 다음 스윕이 같은 건을 다시 처리해 리그 포인트(LP)를 두 번 더한다. 또 제출 커밋 직후 서버가 종료되면 LP가 지급되지 않고, 이를 찾아낼 기록도 남지 않는다.
LP 지급 기록을 출처 기준 unique로 남겨 **중복을 0으로**, 기록이 없는 첫 제출을 대조로 다시 지급해 **영구 미지급을 0으로** 만든다. 함께 스윕의 재적재 유실(지운 뒤 다시 넣기)과, 기본 스케줄러 스레드 1개를 21시 알림 배치와 공유해 생기는 처리 정지를 없앤다.

## 현재 코드에서 확인한 사실 (계획의 근거)
| # | 사실 | 위치 |
|---|---|---|
| F1 | 스윕은 `reprocess` 성공 뒤 `removeQuietly`로 제거한다. 제거 실패는 warn 로그 "다음 스윕에서 재정리 기대"만 남기는데, 실제로는 다음 스윕이 **다시 처리**한다 | `RetryQueueSweeper:66-83` |
| F2 | 재처리 실패 시 원본을 먼저 제거하고(`removeQuietly`) 새 항목을 추가한다. 추가가 실패하면 "유실" 로그만 남는다 | `RetryQueueSweeper:66-70, 94-104` |
| F3 | 파싱 실패도 제거 → 데드레터 순서라, 데드레터 적재가 실패하면 원문이 사라진다 | `RetryQueueSweeper:57-61` |
| F4 | `__retryId`는 재적재마다 새 UUID다. 재적재는 직전 시도가 롤백된 뒤라 그 자체로 중복을 만들지 않는다. 중복 경로는 F1뿐이다 | `RetryQueueSweeper:96`, `RedisRetryEventPublisher:33` |
| F5 | LP 재시도 payload에 출처 식별자가 없다. 레슨은 `userId, points, accuracy`, 면접은 `userId, points`뿐이다 | `UserLeagueEventListener:56-60, 83-86` |
| F6 | 레슨 LP는 첫 제출에만 지급하고(`isFirstTry`), 제출은 이력으로 쌓인다. 따라서 `(userId, lessonId)`가 레슨 LP 지급 1건을 유일하게 가리킨다. 면접 LP는 완료 세션마다 1건이라 `sessionId`가 키다 | `LessonFacade:94-122`, `learning.md:7`, `interview.md:250-253` |
| F7 | `@EnableScheduling`만 있고 스케줄러 설정이 없어 Spring Boot 기본값(스레드 1개)을 쓴다. 21시 알림 배치 4개(FCM 발송 포함), 자정 배치, 스윕이 이 스레드 하나를 나눠 쓴다 | `SchedulingConfig`, `NotificationScheduler`, `NotificationBatchFacade` |
| F8 | 공지 재처리 `notifyAllUsers`는 `INSERT ... SELECT` 한 문장이다. 부분 실패 후 전체 재발송은 일어나지 않는다(앞선 검토의 "공지 부분 실패 중복" 지적은 틀렸음) | `NotificationService:45-52` |
| F9 | 운영 배포는 단일 컨테이너 `up -d --force-recreate`로, 구버전이 멈춘 뒤 신버전이 마이그레이션한다. 구버전과 신버전이 함께 쓰는 구간이 없다 | `cd-prod.yml:149` |

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V52__add_league_point_grant.sql` - 지급 기록 테이블, unique 인덱스, 기존 지급분 백필
- `src/main/java/gravit/code/userLeague/domain/LeaguePointGrant.java` - 지급 기록 Entity
- `src/main/java/gravit/code/userLeague/domain/LeaguePointSource.java` - 지급 출처 enum (`LESSON`, `INTERVIEW`)
- `src/main/java/gravit/code/userLeague/repository/LeaguePointGrantRepository.java` - 지급 기록 insert-if-absent
- `src/main/java/gravit/code/userLeague/repository/custom/LeaguePointGrantQueryRepository.java` - 미지급 첫 제출 조회 인터페이스
- `src/main/java/gravit/code/userLeague/repository/custom/LeaguePointGrantQueryRepositoryImpl.java` - `NamedParameterJdbcTemplate` 구현
- `src/main/java/gravit/code/userLeague/repository/sql/LeaguePointGrantQuerySql.java` - 미지급 조회 SQL 상수
- `src/main/java/gravit/code/userLeague/dto/internal/UngrantedLessonSubmissionDto.java` - `(userId, lessonId, accuracy)`
- `src/main/java/gravit/code/userLeague/service/LeaguePointReconcileService.java` - 미지급 대조와 재지급
- `src/main/java/gravit/code/userLeague/scheduler/LeaguePointReconcileScheduler.java` - 10분 주기 대조 실행
- `src/main/java/gravit/code/lesson/policy/LessonRewardPolicy.java` - 레슨 기본 보상(20)과 지급량 계산식의 단일 출처
- `src/test/java/gravit/code/lesson/policy/LessonRewardPolicyTest.java` - 순수 JUnit
- `src/test/java/gravit/code/global/event/retry/RetryQueueSweeperIntegrationTest.java`
- `src/test/java/gravit/code/userLeague/service/LeaguePointReconcileServiceIntegrationTest.java`

### 수정 파일
- `src/main/java/gravit/code/global/config/SchedulingConfig.java` - 기본 `taskScheduler`(스레드 1)와 재시도 전용 `retrySweepScheduler`(스레드 2)를 명시 등록
- `src/main/java/gravit/code/global/event/retry/RetryQueueSweeper.java` - 전용 스케줄러 지정, "추가(재적재/데드레터) 성공 후 제거" 순서로 교정, 로그 문구 정정
- `src/main/java/gravit/code/userLeague/service/UserLeaguePointService.java` - 레슨, 면접 지급에 출처 식별자 인자 추가, 지급 기록 insert 결과로 중복이면 건너뜀
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` - private `POINT_PER_LESSON` 삭제, 이벤트 `points`에 `LessonRewardPolicy.BASE_REWARD_POINTS`를 싣는다
- `src/main/java/gravit/code/user/service/UserService.java` - private `POINT_PER_LESSON` 삭제, `updateUserLevelAndXp`의 계산식을 `LessonRewardPolicy.calculate`로 교체
- `src/main/java/gravit/code/userLeague/listener/UserLeagueEventListener.java` - 서비스 호출과 재시도 payload에 `lessonId`, `sessionId` 추가
- `src/main/java/gravit/code/userLeague/infrastructure/LeaguePointRetryTarget.java` - `FIELD_LESSON_ID` 추가, 재처리 시 전달
- `src/main/java/gravit/code/userLeague/infrastructure/LeaguePointInterviewRetryTarget.java` - `FIELD_SESSION_ID` 추가, 재처리 시 전달
- `src/test/java/gravit/code/userLeague/service/UserLeaguePointServiceIntegrationTest.java` - 바뀐 시그니처 반영, 중복 지급 차단 시나리오 추가
- `src/test/java/gravit/code/userLeague/listener/UserLeagueEventListenerIntegrationTest.java` - payload 필드 검증 갱신
- `.claude/spec/service-policy/learning.md` - 정책 추가: 레슨 첫 제출 LP는 한 번만 지급, 누락 시 대조로 지급되는 조건과 시점
- `.claude/spec/service-policy/interview.md` - 정책 추가: 완료 세션당 LP는 한 번만 지급
- `.claude/rules/code-convention/facade.md` - "보상의 실제 성질"의 스윕 실행 스레드 설명 갱신(전용 스케줄러), LP 지급 기록과 대조 한 줄 추가

## 구현 계획

### STEP 1. 지급 기록 테이블과 백필 (Entity / Flyway)
`V52__add_league_point_grant.sql`
```sql
-- V52__add_league_point_grant.sql

-- 리그 포인트 지급 기록. 출처(레슨, 면접 세션)당 1건만 지급되도록 unique로 막는다
CREATE TABLE league_point_grant
(
    id          BIGINT       GENERATED BY DEFAULT AS IDENTITY,
    user_id     BIGINT       NOT NULL,
    source_type VARCHAR(255) NOT NULL CHECK (source_type IN ('LESSON', 'INTERVIEW')),
    source_id   BIGINT       NOT NULL,
    points      INTEGER      NOT NULL,
    created_at  TIMESTAMP(6) NOT NULL,
    PRIMARY KEY (id)
);

-- 지급 여부 판정과 대조 anti-join용 unique 인덱스
CREATE UNIQUE INDEX IF NOT EXISTS ux_league_point_grant_source
    ON league_point_grant (source_type, source_id, user_id);

-- 기존 레슨 첫 제출은 지급된 것으로 본다 (대조가 과거분을 재지급하지 않도록)
INSERT INTO league_point_grant (user_id, source_type, source_id, points, created_at)
SELECT DISTINCT ON (user_id, lesson_id)
       user_id, 'LESSON', lesson_id, ROUND(20 * accuracy / 100.0), created_at
FROM lesson_submission
ORDER BY user_id, lesson_id, created_at, id;

-- 기존 완료 면접 세션도 지급된 것으로 본다
INSERT INTO league_point_grant (user_id, source_type, source_id, points, created_at)
SELECT user_id, 'INTERVIEW', id,
       ROUND(30.0 * (accuracy_score + delivery_score) / (accuracy_max_score + structure_max_score + clarity_max_score)),
       COALESCE(ended_at, updated_at, started_at)
FROM interview_session
WHERE status = 'COMPLETED'
  AND accuracy_max_score + structure_max_score + clarity_max_score > 0;
```
- 백필은 "과거 지급이 모두 성공했다"고 가정한다. 과거 미지급분은 지금도 찾을 방법이 없으므로, 이 가정이 현재 상태를 더 나쁘게 만들지 않는다.
- `ROUND(numeric)`은 양수에서 HALF_UP이라 `Math.round`, `InterviewRewardPolicy`(HALF_UP)와 같다.
- `LeaguePointSource` enum: `LESSON`, `INTERVIEW`
- `LeaguePointGrant` Entity: `BaseEntity`를 상속하지 않는다(`updated_at` 없음). `id`, `userId`, `sourceType`(`@Enumerated(STRING)`), `sourceId`, `points`, `createdAt`. 테스트 준비용 `create(long userId, LeaguePointSource sourceType, long sourceId, int points, LocalDateTime createdAt)`

### STEP 2. 지급을 멱등하게 (Repository / Service / Listener / RetryTarget)
**Repository**: `LeaguePointGrantRepository extends JpaRepository<LeaguePointGrant, Long>, LeaguePointGrantQueryRepository`
```java
@Modifying
@Query(value = """
        INSERT INTO league_point_grant (user_id, source_type, source_id, points, created_at)
        VALUES (:userId, :sourceType, :sourceId, :points, :now)
        ON CONFLICT (source_type, source_id, user_id) DO NOTHING
""", nativeQuery = true)
int insertIfAbsent(
        @Param("userId") long userId,
        @Param("sourceType") String sourceType,
        @Param("sourceId") long sourceId,
        @Param("points") int points,
        @Param("now") LocalDateTime now
);
```
- 예외 대신 영향 행 수(0 또는 1)로 판정한다. unique 위반 예외는 트랜잭션을 rollback-only로 만들기 때문이다.
- 같은 키를 동시에 insert하면(스윕과 대조가 겹칠 때) 두 번째는 첫 번째 커밋까지 기다린 뒤 0을 받는다.

**Policy**: `lesson/policy/LessonRewardPolicy` (`@Component`, `InterviewRewardPolicy`와 같은 형태)
- `public static final int BASE_REWARD_POINTS = 20;`
- `public int calculate(int basePoints, int accuracy)` → `(int) Math.round(basePoints * accuracy * 0.01)`
  - 지금의 `UserService:155`, `UserLeaguePointService:36` 계산식을 그대로 옮긴다. 정답률이 정수라 `basePoints × accuracy ÷ 100`이 정확히 .5가 되는 경우가 없어, 반올림 방식을 바꿔도 결과는 같지만 동작을 바꾸지 않기 위해 `Math.round`를 유지한다.
  - 이벤트의 `points` 필드는 유지하므로(사용자 결정), 받는 쪽은 `calculate(event.points(), event.accuracy())`로 계산한다. 기본값 20은 발행하는 쪽(`LessonFacade`)과 대조만 `BASE_REWARD_POINTS`로 참조한다.
- 사용처: `UserService.updateUserLevelAndXp`(XP), `UserLeaguePointService.addLeaguePointsForLesson`(LP), `LeaguePointReconcileService`(대조). user, userLeague 도메인이 lesson의 정책 컴포넌트를 주입받는다. Service가 다른 도메인 Service를 부르는 것이 아니라 정책 계산만 빌리는 것이라 `service.md`와 충돌하지 않는다.

**Service**: `UserLeaguePointService` (주입 추가: `LeaguePointGrantRepository`, `LessonRewardPolicy`, `Clock`)
- `addLeaguePointsForLesson(long userId, long lessonId, int points, int accuracy)`
  1. `earnedPoints = lessonRewardPolicy.calculate(points, accuracy)`
  2. `grantOnce(userId, LESSON, lessonId, earnedPoints)`
- `addLeaguePointsForInterview(long userId, long sessionId, int earnedPoints)` → `grantOnce(userId, INTERVIEW, sessionId, earnedPoints)`
- `addLeaguePointsForCongratulation`은 그대로 둔다. 동기 호출이라 재시도 큐를 거치지 않는다.
- `private void grantOnce(long userId, LeaguePointSource source, long sourceId, int earnedPoints)`
  - `insertIfAbsent(...) == 0`이면 info 로그 "이미 지급된 리그 포인트, 건너뜀"을 남기고 반환
  - 아니면 `applyLeaguePoints(userId, earnedPoints)`
  - insert와 적용이 같은 `REQUIRES_NEW` 트랜잭션이다. 적용이 실패하면(`USER_LEAGUE_NOT_FOUND` 등) 기록도 함께 롤백되어 재시도와 대조 대상으로 남는다.

**Listener**: `UserLeagueEventListener`
- `handleLessonCompleted`: `pointService.addLeaguePointsForLesson(event.userId(), event.lessonId(), event.points(), event.accuracy())`
- `queueLeaguePointsRetry`: payload에 `LeaguePointRetryTarget.FIELD_LESSON_ID → event.lessonId()` 추가
- `handleInterviewCompleted`: `addLeaguePointsForInterview(event.userId(), event.sessionId(), event.rewardPoints())`
- `queueInterviewLeaguePointsRetry`: payload에 `LeaguePointInterviewRetryTarget.FIELD_SESSION_ID → event.sessionId()` 추가

**RetryTarget**
- `LeaguePointRetryTarget`: `public static final String FIELD_LESSON_ID = "lessonId";`. `reprocess`에서 읽어 전달
- `LeaguePointInterviewRetryTarget`: `public static final String FIELD_SESSION_ID = "sessionId";`. `reprocess`에서 읽어 전달
- 배포 직전 큐에 남은 구 payload(식별자 없음)는 `Long.valueOf(null)`에서 실패해 10회 뒤 데드레터로 간다. 배포 전 `ZCARD league-points-retry`, `ZCARD league-points-interview-retry`가 0인지 확인한다(검증 섹션 체크리스트).

### STEP 3. 미지급 대조 (Repository / Service / Scheduler)
**SQL**: `LeaguePointGrantQuerySql.FIND_UNGRANTED_FIRST_LESSON_SUBMISSIONS`
```sql
SELECT first.user_id, first.lesson_id, first.accuracy
FROM (
    SELECT DISTINCT ON (ls.user_id, ls.lesson_id) ls.user_id, ls.lesson_id, ls.accuracy
    FROM lesson_submission ls
    WHERE ls.created_at >= :since AND ls.created_at < :until
    ORDER BY ls.user_id, ls.lesson_id, ls.created_at, ls.id
) first
WHERE NOT EXISTS (
        SELECT 1 FROM league_point_grant g
        WHERE g.source_type = 'LESSON' AND g.source_id = first.lesson_id AND g.user_id = first.user_id)
  AND NOT EXISTS (
        SELECT 1 FROM lesson_submission prev
        WHERE prev.user_id = first.user_id AND prev.lesson_id = first.lesson_id AND prev.created_at < :since)
LIMIT :limit
```
- 두 번째 `NOT EXISTS`가 없으면, 창 밖에서 미지급된 첫 제출 뒤의 창 안 재제출이 "첫 제출"로 잡혀 재제출 정답률로 지급된다. 이 조건이 그 경우를 막는다. `ix_lesson_submission_user_created_at (user_id, created_at) INCLUDE (lesson_id)`를 탄다.
- 창 조건 `created_at` 단독 인덱스는 없다. 필요 여부는 M3 측정 결과로 정한다(결정 필요 D4).

**Repository**: `LeaguePointGrantQueryRepository.findUngrantedFirstLessonSubmissions(LocalDateTime since, LocalDateTime until, int limit)` → `List<UngrantedLessonSubmissionDto>`

**Service**: `LeaguePointReconcileService` (`UserLeaguePointService`, `LeaguePointGrantRepository`, `SeasonRepository`, `Clock`)
- 상수
  - `GRACE = Duration.ofMinutes(30)`: 재시도 큐 총 대기(백오프 5+10+20+40+80+160+300×3 = 1,215초, 스윕 간격 30초×10 = 300초, 합 약 25분)보다 길게 잡아, 아직 재시도 중인 건과 경쟁하지 않게 한다. 경쟁해도 unique가 중복을 막으므로 이 값은 정합성이 아니라 헛수고를 줄이기 위한 것이다.
  - `WINDOW = Duration.ofHours(24)`: 재시도 불가 오류(`USER_LEAGUE_NOT_FOUND`)로 계속 실패하는 건을 무한히 다시 시도하지 않게 하는 상한이다.
  - `BATCH_SIZE = 500`
- `public int reconcileLessonPoints()` (트랜잭션 없음, 건마다 `REQUIRES_NEW`)
  1. `now = LocalDateTime.now(clock)`, `until = now - GRACE`
  2. `since = max(now - WINDOW, 활성 시즌 startsAt)`. 활성 시즌이 없으면 0 반환. 지난 시즌 제출을 새 시즌 LP로 지급하지 않기 위해서다.
  3. `findUngrantedFirstLessonSubmissions(since, until, BATCH_SIZE)`
  4. 건마다 `pointService.addLeaguePointsForLesson(userId, lessonId, LessonRewardPolicy.BASE_REWARD_POINTS, accuracy)`. 예외는 건별로 잡아 error 로그를 남기고 다음 건으로 넘어간다.
  5. 지급 건수를 반환하고, 1건 이상이면 warn 로그 "미지급 리그 포인트 대조 지급: N건"을 남긴다(누락 발생 감시용).

**Scheduler**: `LeaguePointReconcileScheduler`
```java
@Scheduled(fixedDelay = 600_000, initialDelay = 600_000, scheduler = "retrySweepScheduler")
public void reconcile() { leaguePointReconcileService.reconcileLessonPoints(); }
```

### STEP 4. 스윕 재적재 순서 교정 (Global)
`RetryQueueSweeper`
- `processDueEntry`
  - 파싱 실패: `if (deadLetter(target, json)) removeQuietly(target, json);` (F3)
  - 재처리 실패: `if (requeueOrDeadLetter(target, fields, attempt, e)) removeQuietly(target, json);` (F2). 추가에 실패하면 원본이 남아 다음 스윕에서 같은 attempt로 다시 시도된다.
  - 재처리 성공: `removeQuietly(target, json)` 그대로
- `requeueOrDeadLetter(...)`, `deadLetterFields(...)`, `deadLetter(...)`의 반환형을 `boolean`(적재 성공 여부)으로 바꾼다.
- `removeQuietly` 로그: `"재시도 큐 항목 제거 실패, 다음 스윕에서 다시 처리됨: queueKey={}, raw={}"` (F1)
- "추가 후 제거"로 바꾸면 실패 시 결과가 유실에서 중복으로 바뀐다. LP는 STEP 2로 중복이 무해해지고, 알림과 피드 중복은 기존에도 감수하던 범위다. 그래서 Lua로 묶지 않는다.

### STEP 5. 스윕 전용 스케줄러 (Global)
`SchedulingConfig`
```java
@Bean(name = "taskScheduler")
public ThreadPoolTaskScheduler taskScheduler() { pool 1, prefix "scheduling-" }

@Bean(name = "retrySweepScheduler")
public ThreadPoolTaskScheduler retrySweepScheduler() { pool 2, prefix "retry-sweep-" }
```
- **`taskScheduler`를 함께 등록해야 한다.** `TaskScheduler` 빈을 하나라도 직접 등록하면 Spring Boot 자동 구성이 물러나고, `@Scheduled`의 기본 스케줄러는 이름이 `taskScheduler`인 빈으로 정해진다. 전용 빈만 등록하면 21시 배치까지 그 빈으로 옮겨가 분리 효과가 사라진다.
- 기본 스케줄러는 지금처럼 1개로 유지한다. 21시 배치 4개가 동시에 FCM을 보내도록 바꾸는 것은 이번 범위가 아니다.
- 전용 스케줄러를 2개로 두는 이유: 스윕(30초)과 대조(10분)가 서로를 막지 않게 하기 위해서다.
- `RetryQueueSweeper.sweep()`: `@Scheduled(fixedDelay = 30000, scheduler = "retrySweepScheduler")`
- 이슈의 "무거운 대상(공지) 분리"는 이번 범위에서 뺀다. F8대로 공지 재처리는 SQL 한 문장이고, 실제로 오래 막는 것은 21시 FCM 배치(F7)라 스케줄러 분리로 해소된다. M4에서 100만 명 공지 1건의 스윕 점유 시간을 재서 5초를 넘으면 후속 이슈로 연다(결정 필요 D3).

### STEP 6. 정책, 규칙 문서
- `learning.md`: "레슨 첫 제출 리그 점수는 레슨당 한 번만 지급한다. 지급이 누락되면 제출 30분 뒤부터 10분 주기 대조로 지급되며, 대조 대상은 현재 시즌 안의 최근 24시간 제출이다"
- `interview.md` 완료 보상: "리그 점수는 완료 세션당 한 번만 지급한다. 재시도가 겹쳐도 두 번 지급되지 않는다"
- `facade.md` 보상의 실제 성질: 스윕이 전용 스케줄러에서 돈다는 사실, LP는 지급 기록으로 중복이 막히고 레슨 LP는 대조로 누락이 메워진다는 사실

### Facade
불필요. 대조는 userLeague 단일 도메인 Service(`UserLeaguePointService`)를 부르고, 다른 도메인은 Repository(`SeasonRepository`, SQL의 `lesson_submission`) 조회만 한다. `UserLeaguePointService`가 `LeagueRepository`를 쓰는 것과 같은 선례다.

### DTO / Controller
- DTO: `UngrantedLessonSubmissionDto(long userId, long lessonId, int accuracy)` (internal record)
- Controller: 변경 없음

## 결정 필요 (Decisions needed)
- [x] D1. 멱등 적용 범위 - **(A) LP 레슨, 면접만(이슈 범위)**. 같은 결함(스윕 F1 경로 중복)이 있는 면접 XP(`UserXpInterviewRetryTarget`), 레슨 미션 진행도(`MissionLessonRetryTarget`), 일일 학습 기록(`DailyLearningRecordRetryTarget`)은 이번 범위 밖이며 PR 본문의 한계와 후속 이슈로 남긴다
- [x] D2. 대조 범위 - **(A) 레슨 LP만**. 면접 LP는 중복만 막히고, 커밋 직후 종료로 인한 미지급은 한계로 남긴다
- [x] D3. 공지처럼 무거운 재처리 대상 분리 - **(A) 이번 범위에서 빼고 M4 결과가 5초를 넘으면 후속 이슈**
- [x] D4. 대조 창 조건 인덱스 `lesson_submission (created_at)` - **(A) M3 결과를 보고 1회 대조가 100ms를 넘으면 추가**
- [x] D5. 레슨 기본 보상 20과 계산식 - **`LessonRewardPolicy`로 모으고 이벤트 `points` 필드는 유지**. 값(`LessonFacade`, `UserService`)과 계산식(`UserService`, `UserLeaguePointService`)이 이미 두 곳씩 복사돼 있어, 대조 서비스가 세 번째 복사본이 되지 않게 한다

## 검증
### 대상 테스트
- `LessonRewardPolicyTest`: 정답률 0, 35, 100에서 0, 7, 20을 반환한다
- 기존 레슨 제출 XP, LP 지급 테스트(`UserServiceIntegrationTest`, `LessonFacade` 관련)가 그대로 통과해야 한다(계산식 이동의 회귀 확인)
- `UserLeaguePointServiceIntegrationTest`
  - 같은 `(userId, lessonId)`로 두 번 호출하면 LP가 한 번만 오르고 지급 기록이 1건이다
  - 같은 `sessionId` 면접 지급도 한 번만 오른다
  - 적용이 `USER_LEAGUE_NOT_FOUND`로 실패하면 지급 기록이 남지 않는다
- `RetryQueueSweeperIntegrationTest` (`@MockitoSpyBean RedisTemplate`로 실패 주입)
  - 재처리 성공 뒤 제거가 실패해 두 번 스윕돼도 LP는 한 번만 오른다
  - 재처리 실패 뒤 재적재(`ZADD`)가 실패하면 원본 항목이 큐에 남는다
  - 파싱 실패 항목은 데드레터 적재에 실패하면 큐에 남는다
- `LeaguePointReconcileServiceIntegrationTest`
  - 지급 기록 없는 첫 제출(30분 경과)은 정답률대로 지급된다
  - 30분이 지나지 않은 제출, 이미 지급된 제출, 24시간 밖 제출, 시즌 시작 전 제출은 지급되지 않는다
  - 창 밖 첫 제출이 있고 창 안에 재제출만 있으면 지급되지 않는다
- `UserLeagueEventListenerIntegrationTest`: 재시도 payload에 `lessonId`, `sessionId`가 실린다

### 측정 계획 (이력서 수치용)
기록 위치는 `.claude/resources/perf/608/`이고, 숫자는 측정 대장에 ID와 로그를 함께 올린 것만 쓴다. 성능 항목(M3, M4)은 기존 재측정 조건(합성 시드, 로컬 docker, 앱 HTTP 8클라이언트, 5회 중앙값)을 따른다.

| ID | 무엇을 | 방법 | 전 | 후 목표 |
|---|---|---|---|---|
| M1 | LP 중복 | 재처리 100건마다 제거 실패 주입 후 스윕 2회 | 중복 100건 예상 | 0건 |
| M2 | 영구 미지급 | 첫 제출 100건을 리스너 없이 커밋(서버 종료 모사) | 미지급 100건이 남고 찾을 수단 없음 | 대조 1회 뒤 0건 |
| M3 | 대조 비용 | `lesson_submission` 100만 행, 최근 24시간 1만 건, `EXPLAIN (ANALYZE, BUFFERS)` 5회 | - | 1회 실행 시간과 읽은 페이지 수. D4 판정 |
| M4 | 21시 배치 중 스윕 정지 | FCM 스텁에 지연을 넣은 21시 배치(대상 10만 명) 실행 중 큐 적재부터 처리까지 지연 측정. 100만 명 공지 1건의 스윕 점유 시간도 함께 잰다 | 지연 max ≈ 배치 소요 시간 | 지연 max ≤ 30초 + 처리 시간 |
| M5 | 재적재 유실 | 재처리 실패 100건마다 `ZADD` 실패 주입 | 유실 100건 | 0건(원본 잔존) |
| M6 | 제출 오버헤드 | 레슨 제출 API p95, TPS 전후 | 기준값 측정 | insert 1회 추가분 기록 |

- M1, M2, M5는 결정적 장애 주입 테스트라 1회로 충분하다. 실행 스크립트를 함께 남긴다.

### 배포 체크리스트
- 배포 전 `ZCARD league-points-retry`, `ZCARD league-points-interview-retry`가 0인지 확인 (STEP 2의 구 payload)
- 배포 직후 구 payload 잔존 확인. 확인 뒤 컨테이너가 교체되기 전까지 구버전이 출처 식별자 없는 항목을 적재할 수 있고, 신버전은 이를 파싱하지 못해 재시도 한도 뒤 데드레터로 보낸다
  - `ZRANGE league-points-interview-retry 0 -1`, `LRANGE league-points-interview-retry:dead-letter 0 -1`에서 `sessionId`가 없는 항목을 찾는다. 레슨 큐(`league-points-retry`)도 같은 방법으로 `lessonId`가 없는 항목을 본다
  - 레슨 항목은 대조가 24시간 안에 지급하므로 지우기만 한다. 면접 항목은 대조가 없으니 `userId`로 지급 기록이 없는 `COMPLETED` 세션을 찾아 `sessionId`를 채워 다시 적재하거나 수동 지급한다
- 배포 뒤 롤백(`rollback-prod.yml`)했다가 다시 올리면, 롤백 기간의 제출은 지급 기록 없이 지급돼 있어 대조가 다시 지급한다. 롤백했다면 재배포 전에 아래 멱등 백필을 실행한다. V52의 백필 INSERT를 그대로 다시 돌리면 이미 있는 기록과 `ux_league_point_grant_source`가 충돌해 문장 전체가 실패한다. V52 파일은 적용된 마이그레이션이라 고치지 않는다
  ```sql
  -- 롤백 기간에 기록 없이 지급된 레슨 첫 제출을 지급된 것으로 기록한다 (이미 있는 기록은 건너뜀)
  INSERT INTO league_point_grant (user_id, source_type, source_id, points, created_at)
  SELECT DISTINCT ON (user_id, lesson_id)
         user_id, 'LESSON', lesson_id, ROUND(20 * accuracy / 100.0), created_at
  FROM lesson_submission
  ORDER BY user_id, lesson_id, created_at, id
  ON CONFLICT (source_type, source_id, user_id) DO NOTHING;

  -- 롤백 기간에 기록 없이 지급된 완료 면접 세션도 같은 방식으로 기록한다
  INSERT INTO league_point_grant (user_id, source_type, source_id, points, created_at)
  SELECT user_id, 'INTERVIEW', id,
         ROUND(30.0 * (accuracy_score + delivery_score) / (accuracy_max_score + structure_max_score + clarity_max_score)),
         COALESCE(ended_at, updated_at, started_at)
  FROM interview_session
  WHERE status = 'COMPLETED'
    AND accuracy_max_score + structure_max_score + clarity_max_score > 0
  ON CONFLICT (source_type, source_id, user_id) DO NOTHING;
  ```
  - 전체 테이블을 다시 읽으므로 소요 시간은 최초 백필과 같다. 신버전이 이미 남긴 기록과 겹치는 행은 `ON CONFLICT`로 건너뛴다
- 운영 `lesson_submission` 행 수로 백필 소요 시간을 추정해 둔다(로컬 100만 행 기준 측정값 첨부)

## Deviation Log
- `V52__add_league_point_grant.sql`: 마이그레이션 번호를 V51에서 V52로 변경 - 이유: 운영 배포 전 콘텐츠 확장(#619, PR #621)이 V51을 쓰고 먼저 머지한다. 처음에는 #610 계획(D3)에서 친구 검색 표현식 통계가 V51을 쓰기로 했으나, #610은 V53으로 옮겨 이 작업 다음에 머지한다. 운영 Flyway는 `outOfOrder`가 꺼져 있어 머지 순서는 #619, #608, #610이어야 한다
- `LeaguePointGrant`: `@Table(uniqueConstraints = ux_league_point_grant_source)` 추가 — 이유: 테스트 스키마는 `ddl-auto: create`로 만들어져 마이그레이션의 unique 인덱스가 없다. 없으면 `ON CONFLICT (source_type, source_id, user_id)`가 실패한다. `UserMission`과 같은 선례다
- `RetryQueueSweeper`: 재적재, 데드레터 실패 로그의 "유실"을 "원본 항목을 남겨 다음 스윕에서 다시 처리"로 변경 — 이유: STEP 4로 실패 시 원본이 남으므로 "유실"이 사실과 달라진다
- `LeaguePointRetryTarget`, `LeaguePointInterviewRetryTarget`: 재시도 불가 로그에 `lessonId`, `sessionId` 추가 — 이유: 지급 기록 키가 출처 식별자라 확인할 때 필요하다
- 기존 테스트(`UserLeaguePointServiceIntegrationTest`, `UserLeagueEventListenerIntegrationTest`): 바뀐 시그니처와 payload 필드만 반영했다. 검증 섹션의 새 시나리오와 신규 테스트 클래스는 `write-test`에서 작성한다
