# [PLAN-434] 이벤트 리스너 실패 처리 및 복원력 개선 (UserLeagueEventListener/NotificationEventListener/SocialFeedEventListener)

> 이슈: #434
> 브랜치: refactor/434-listener-resilience

## 목표
세 리스너가 겪는 실패 처리 문제는 공통적으로 "AFTER_COMMIT 이후 부가 작업이 실패했을 때 어떻게 반드시 완료시킬 것인가"로 귀결된다. 이번 계획에서는:
1. 공용 재시도 인프라(Redis Sorted Set + 단일 스케줄 폴러, `global/event/retry/`)를 한 번 만들고
2. `UserLeagueEventListener.createUserLeague`(→`initUserLeague`)만 예외적으로 "onboarding과 원자적으로 반드시 완료"가 요구되므로 트랜잭션 내 세이브포인트 재시도(NESTED+`@Retryable`)로 별도 처리하고
3. 나머지(`addLeaguePoints`, `NotificationEventListener` 3종, `SocialFeedEventListener` 3종)는 모두 공용 재시도 인프라 위에 얹는다.

## 영향 범위

### 신규 파일 — 공용 재시도 인프라
- `src/main/java/gravit/code/global/event/retry/RetryEventPublisher.java` — 포트: `void publish(String queueKey, Map<String, String> fields)`
- `src/main/java/gravit/code/global/event/retry/RedisRetryEventPublisher.java` — Redis Sorted Set(ZADD) 구현체(기존 `RedisTemplate<String,String>`, 기존 `ObjectMapper` 빈 재사용 — 신규 Redis 빈/신규 의존성 불필요)
- `src/main/java/gravit/code/global/event/retry/RetrySweepTarget.java` — 재처리 계약 인터페이스(`queueKey()`/`maxAttempts()`/`reprocess(Map<String,String>)`)
- `src/main/java/gravit/code/global/event/retry/RetryQueueSweeper.java` — `@Scheduled(fixedDelay = 30000)`. 등록된 모든 `RetrySweepTarget`에 대해 `ZRANGEBYSCORE queueKey 0 now`로 처리 대상 조회 → 성공 시 `ZREM`, 실패 시 `maxAttempts` 미만이면 지수 백오프로 score를 미래로 미뤄 재적재, 초과 시 `ZREM` + `log.error`(데드레터)

> DB 테이블 신설 없이 기존 Redis 인프라만 재사용. Redis Streams의 컨슈머 그룹/즉시소비 리스너/`XCLAIM` idle-claim 로직은 두지 않는다 — 재시도 대상은 이미 한 번 실패한 이벤트라 즉시 소비 경로가 필요 없고, 단일 폴링 경로 하나로 "즉시 재시도"와 "장애 복구"를 겸한다(자세한 배경은 하단 Deviation Log 참고).

### 신규 파일 — 도메인별 RetrySweepTarget 구현
- `src/main/java/gravit/code/userLeague/infrastructure/LeaguePointRetryTarget.java` — `queueKey="league-points-retry"`
- `src/main/java/gravit/code/notification/infrastructure/NoticeCreatedRetryTarget.java` — `queueKey="notice-created-retry"`
- `src/main/java/gravit/code/notification/infrastructure/FollowedRetryTarget.java` — `queueKey="followed-retry"`
- `src/main/java/gravit/code/notification/infrastructure/InquiryAnsweredRetryTarget.java` — `queueKey="inquiry-answered-retry"`
- `src/main/java/gravit/code/social/infrastructure/SocialFeedStreakRetryTarget.java` — `queueKey="social-feed-streak-retry"`
- `src/main/java/gravit/code/social/infrastructure/SocialFeedLevelUpRetryTarget.java` — `queueKey="social-feed-levelup-retry"`
- `src/main/java/gravit/code/social/infrastructure/SocialFeedTierPromotionRetryTarget.java` — `queueKey="social-feed-tier-retry"`

### 수정 파일
- `src/main/java/gravit/code/userLeague/listener/UserLeagueEventListener.java` — `handleLessonCompleted` 실패 시 `retryEventPublisher.publish(...)` 호출로 변경(그 외 동기 우선 시도 로직 유지)
- `src/main/java/gravit/code/userLeague/service/UserLeagueService.java` — `initUserLeague`에 NESTED 전파 + `@Retryable` 적용
- `src/main/java/gravit/code/userLeague/service/UserLeaguePointService.java` — `addLeaguePoints`를 `REQUIRES_NEW`로 변경
- `src/main/java/gravit/code/notification/listener/NotificationEventListener.java` — 3개 핸들러 모두 `@Transactional(REQUIRES_NEW)` 제거, 서비스 직접 호출 대신 큐 적재로 변경
- `src/main/java/gravit/code/social/listener/SocialFeedEventListener.java` — 3개 핸들러 모두 `@Async`/`@Transactional` 제거, 큐 적재로 변경
- `src/main/java/gravit/code/global/config/AsyncConfig.java` — `socialFeedAsync` 빈 제거(사용처 없어짐)
- `docker-compose-dev.yml`, `docker-compose-prod.yml` — redis 서비스에 AOF 활성화 커맨드 추가(Redis 재시작 시 재시도 큐 유실 방지)

## 구현 계획

### A. 공용 재시도 인프라

1. **`RetryEventPublisher`** (port)
   ```java
   public interface RetryEventPublisher {
       void publish(String queueKey, Map<String, String> fields);
   }
   ```

2. **`RedisRetryEventPublisher implements RetryEventPublisher`**
   - `fields`에 `__retryId`(UUID — ZSET 멤버 유일성 보장용. 동일한 payload가 두 번 들어와도 서로 다른 재시도 항목으로 유지되어야 하므로 필요)와 `__attempt`(초기값 `"0"`)를 덧붙여 `ObjectMapper`로 JSON 직렬화 후 `redisTemplate.opsForZSet().add(queueKey, json, System.currentTimeMillis())`.
   - Redis 연결 자체가 불가능한 경우(마지막 방어선 없음)는 `try/catch` + `log.error`로 남기고 호출부에 예외를 전파하지 않음.

3. **`RetrySweepTarget`** (인터페이스)
   ```java
   public interface RetrySweepTarget {
       String queueKey();
       int maxAttempts();
       void reprocess(Map<String, String> fields);
   }
   ```
   - 컨슈머 그룹을 쓰지 않으므로 `groupName()`/`consumerName()` 없음.

4. **`RetryQueueSweeper`**
   ```java
   @Component
   @RequiredArgsConstructor
   @Slf4j
   public class RetryQueueSweeper {
       private final RedisTemplate<String, String> redisTemplate;
       private final ObjectMapper objectMapper;
       private final List<RetrySweepTarget> targets;
       private static final long BASE_BACKOFF_MS = 5_000L;
       private static final long MAX_BACKOFF_MS = 300_000L;

       @Scheduled(fixedDelay = 30000)
       public void sweep() {
           for (RetrySweepTarget target : targets) {
               Set<String> due = redisTemplate.opsForZSet()
                       .rangeByScore(target.queueKey(), 0, System.currentTimeMillis(), 0, 100);
               for (String json : due) {
                   Map<String, String> fields = readValue(json); // __retryId, __attempt 포함
                   int attempt = Integer.parseInt(fields.remove("__attempt"));
                   fields.remove("__retryId");
                   try {
                       target.reprocess(fields);
                       redisTemplate.opsForZSet().remove(target.queueKey(), json);
                   } catch (Exception e) {
                       redisTemplate.opsForZSet().remove(target.queueKey(), json);
                       if (attempt + 1 >= target.maxAttempts()) {
                           log.error("재시도 한도 초과, 데드레터 처리: queueKey={}, fields={}", target.queueKey(), fields, e);
                       } else {
                           fields.put("__retryId", UUID.randomUUID().toString());
                           fields.put("__attempt", String.valueOf(attempt + 1));
                           long backoffMs = Math.min(BASE_BACKOFF_MS * (1L << attempt), MAX_BACKOFF_MS);
                           redisTemplate.opsForZSet().add(target.queueKey(), writeValue(fields),
                                   System.currentTimeMillis() + backoffMs);
                       }
                   }
               }
           }
       }
   }
   ```
   - `fixedDelay=30000` 하나로 "즉시 재시도"와 "장애 복구"를 겸한다 — 재시도 대상은 이미 실패한 이벤트라 초 단위 지연 요구가 없다.
   - `reprocess()` 성공 직후 ~ `ZREM` 사이에 프로세스가 죽으면 다음 기동 후 스윕에서 같은 항목이 다시 처리되어 중복 실행될 수 있다(at-least-once, 정확히 한 번은 아님). Streams+ack 설계였어도 "처리 성공 후 ack 사이" 크래시엔 동일한 중복 가능성이 있었으므로 새로운 리스크는 아니다. 대상 이벤트(리그 포인트 반영, 알림 발송, 소셜 피드 게시)는 중복이 발생해도 치명적이지 않다고 판단해 별도 idempotency 키를 두지 않는다.
   - `fixedDelay`는 이전 실행이 끝난 뒤부터 대기 시간을 세므로, 단일 인스턴스에서 `sweep()` 호출이 겹치지 않는다(별도 락 불필요).

5. `RedisConfig` 변경 없음 — ZSet 연산은 기존 `RedisTemplate<String,String>` 빈으로 충분하다(Stream 전용 직렬화/컨테이너 빈이 필요 없어짐).

### B. UserLeagueEventListener — 원자적 필수 처리(초기화) + 큐 기반 처리(포인트)

6. **`UserLeagueService.initUserLeague(Long userId)`**
   - `@Transactional` → `@Transactional(propagation = Propagation.NESTED)`
   - `@Retryable(retryFor = {TransientDataAccessException.class, RecoverableDataAccessException.class, SQLException.class, DataIntegrityViolationException.class}, backoff = @Backoff(delay = 500, multiplier = 2), maxAttempts = 3)` 추가
     - `DataIntegrityViolationException` 포함 이유: `seasonService.getOrCreateActiveSeason()`이 동시 온보딩 경합 시 시즌 중복 생성으로 unique 제약 위반을 던질 수 있는데, 재시도하면 `findByStatus`가 경쟁에서 이긴 트랜잭션의 시즌을 찾아 정상 처리되는 일시적 상황이라 재시도 대상에 포함.
   - 세이브포인트 기반(NESTED)이라 재시도가 onboarding 트랜잭션과 물리적으로 묶인 채 이루어지고, 재시도 모두 소진 시 예외가 리스너 → onboarding 트랜잭션으로 전파되어 전체 롤백(의도된 동작 — "필수" 요구 충족).

7. **`UserLeagueEventListener.createUserLeague`**
   - 변경 없음. `phase = BEFORE_COMMIT` 유지, try/catch 추가하지 않음(실패 시 그대로 전파되어야 onboarding이 롤백되므로).

8. **`UserLeaguePointService.addLeaguePoints`**
   - `@Transactional` → `@Transactional(propagation = Propagation.REQUIRES_NEW)`

9. **`UserLeagueEventListener.handleLessonCompleted`**
   - `phase = BEFORE_COMMIT` → `phase = AFTER_COMMIT` 유지(기존 계획대로)
   - 필드 추가: `RetryEventPublisher retryEventPublisher`
   ```java
   @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
   public void handleLessonCompleted(LessonCompletedEvent event) {
       try {
           pointService.addLeaguePoints(event.userId(), event.points(), event.accuracy());
       } catch (Exception e) {
           log.error("리그 포인트 반영 실패, 재시도 큐 적재: userId={}", event.userId(), e);
           retryEventPublisher.publish("league-points-retry", Map.of(
                   "userId", String.valueOf(event.userId()),
                   "points", String.valueOf(event.points()),
                   "accuracy", String.valueOf(event.accuracy())
           ));
       }
   }
   ```
   - "동기 우선 시도" 유지 이유: 레슨 완료 직후 응답에서 갱신된 리그 포인트를 바로 반영해야 하는 요구(사용자 확인 사항)가 있어 SocialFeed/Notification과 달리 즉시 시도를 남긴다.

10. **`LeaguePointRetryTarget implements RetrySweepTarget`**
    - `queueKey()="league-points-retry"`, `maxAttempts()=10`
    - `reprocess(fields)`: 필드 파싱 후 `pointService.addLeaguePoints(userId, points, accuracy)` 호출

### C. NotificationEventListener — 항상 큐 경유로 전환

> 결정 사항: 알림 수신자가 항상 요청 액터와 다른 사용자라 같은 요청 내 즉시 반영 요구가 없음 → 동기 시도 제거, 응답 지연 감소 + 크래시 안전성 확보(사용자 확인 완료).

11. **`NotificationEventListener`**
    - 3개 핸들러 모두 `@Transactional(propagation = Propagation.REQUIRES_NEW)` 제거(리스너에서 DB 접근이 없어짐)
    - `handleNoticeCreated`: 서비스 직접 호출 대신
      ```java
      retryEventPublisher.publish("notice-created-retry", Map.of(
              "headline", messageProvider.noticeHeadline(),
              "title", event.title(),
              "noticeId", String.valueOf(event.noticeId())
      ));
      ```
    - `handleFollowed`: 닉네임을 미리 조회해 저장하지 않고 원본 ID만 적재(재처리 시점에 최신 닉네임으로 재계산하기 위함)
      ```java
      retryEventPublisher.publish("followed-retry", Map.of(
              "followerId", String.valueOf(event.followerId()),
              "followeeId", String.valueOf(event.followeeId())
      ));
      ```
    - `handleInquiryAnswered`:
      ```java
      retryEventPublisher.publish("inquiry-answered-retry", Map.of(
              "userId", String.valueOf(event.userId()),
              "title", event.title(),
              "inquiryId", String.valueOf(event.inquiryId())
      ));
      ```
    - 큐 적재 자체가 실패하는 경우(Redis 장애)에 대비해 각 handle 메서드는 `try/catch` + `log.error`로 최후 방어선만 남김(현재 구조와 동일한 수준).

12. **`NoticeCreatedRetryTarget implements RetrySweepTarget`**
    - `reprocess`: `notificationService.notifyAllUsers(NotificationType.NOTICE, headline, title, noticeId)`

13. **`FollowedRetryTarget implements RetrySweepTarget`**
    - `reprocess`: `String nickname = userService.getUser(followerId).getNickname(); String message = messageProvider.followReceived(nickname); notificationFacade.notifyUserInApp(followeeId, NotificationType.FOLLOW, message, followerId);` — 리스너의 원래 로직을 그대로 재현(스냅샷이 아닌 최신 닉네임 사용)

14. **`InquiryAnsweredRetryTarget implements RetrySweepTarget`**
    - `reprocess`: `String message = messageProvider.inquiryAnswered(title); notificationFacade.notifyUser(userId, NotificationType.INQUIRY_ANSWERED, message, inquiryId);`

### D. SocialFeedEventListener — 전용 스레드풀 제거, 항상 큐 경유로 전환

> 결정 사항: 스레드풀 포화로 인한 silent drop의 근본 원인이 자체 스레드풀 운용 자체이므로 제거. 리스너가 하는 일이 "판정 후 큐 적재"로 가벼워져 별도 스레드풀 불필요(사용자 확인 완료).

15. **`SocialFeedEventListener`**
    - 3개 핸들러 모두 `@Async("socialFeedAsync")`, `@Transactional(propagation = Propagation.REQUIRES_NEW)` 제거
    - `handleLessonCompleted`: milestone 판정 로직은 유지, 판정 통과 시에만 큐 적재
      ```java
      @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
      public void handleLessonCompleted(LessonCompletedEvent event) {
          try {
              int days = event.afterConsecutiveSolved();
              if (isStreakMilestone(days)) {
                  retryEventPublisher.publish("social-feed-streak-retry", Map.of(
                          "userId", String.valueOf(event.userId()),
                          "days", String.valueOf(days)
                  ));
              }
          } catch (Exception e) {
              log.error("소셜 피드 연속 학습 큐 적재 실패 userId={}", event.userId(), e);
          }
      }
      ```
    - `handleLevelUp`, `handleTierPromotion`도 동일하게 판정/계산 로직만 남기고 `socialFacade.publishFeed(...)` 직접 호출을 `retryEventPublisher.publish("social-feed-levelup-retry", ...)` / `publish("social-feed-tier-retry", ...)`로 대체

16. **`SocialFeedStreakRetryTarget implements RetrySweepTarget`**
    - `reprocess`: `socialFacade.publishFeed(userId, FeedEventType.STREAK_DAYS, String.valueOf(days))`

17. **`SocialFeedLevelUpRetryTarget implements RetrySweepTarget`**
    - `reprocess`: `socialFacade.publishFeed(userId, FeedEventType.LEVEL_UP, String.valueOf(newLevel))`

18. **`SocialFeedTierPromotionRetryTarget implements RetrySweepTarget`**
    - `reprocess`: `socialFacade.publishFeed(userId, FeedEventType.TIER_PROMOTION, tierName)`

19. **`AsyncConfig`**
    - `socialFeedAsync` 빈(`socialFeedAsyncExecutor()`) 삭제 — 사용처가 없어짐.

### E. Infra

20. **docker-compose**
    - `docker-compose-dev.yml`, `docker-compose-prod.yml`의 `gravit-redis-{dev,prod}` 서비스에 `command: redis-server --appendonly yes --appendfsync everysec` 추가.

## 결정 필요 (Decisions needed)
- [x] MAX_ATTEMPTS(최대 재시도 횟수) — 10회로 확정(초과 시 로그만 남기고 ZREM)
- [x] 재시도 인프라 구현 방식 — Redis Streams+Consumer Group(즉시소비 리스너 + `XCLAIM` 스윕 이원화) 대신 Redis Sorted Set + 단일 `@Scheduled` 폴러로 확정. DB 테이블 신설 없이 기존 Redis만 재사용하면서 컨슈머 그룹 부트스트랩/ack/idle-claim 복잡도를 제거(사용자 확인 완료, 2026-07-12). 배경은 Deviation Log 참고.
- [x] 백오프 정책 — 실패 시 `min(5초 * 2^attempt, 5분)` 지수 백오프로 score를 미뤄 재적재. 스윕 주기(30초)와 별개로 반복 실패 항목이 매 스윕마다 재시도되지 않도록 함.
- [x] NotificationEventListener를 동기 우선 시도 없이 항상 큐 경유로 전환할지 — 전환하기로 확정(수신자가 항상 요청 액터와 다른 사용자라 즉시 반영 요구 없음)
- [x] SocialFeedEventListener의 전용 스레드풀(`socialFeedAsync`) 제거 여부 — 제거하고 항상 큐 경유로 전환하기로 확정

## 검증
- 대상 테스트:
  - `UserLeagueServiceTest` — `initUserLeague`가 지정한 예외 타입에서 N회 재시도 후 성공/최종 실패하는지
  - `UserLeagueEventListenerIntegrationTest` — `createUserLeague` 실패 시 onboarding 트랜잭션 전체 롤백 검증, `handleLessonCompleted` 실패 시 큐 적재 검증
  - `NotificationEventListenerIntegrationTest` — 3개 핸들러 모두 실패 시 각자의 큐(ZSET)에 적재되는지
  - `SocialFeedEventListenerIntegrationTest` — milestone 판정 로직 유지 확인 + 큐 적재 검증
  - `RetryQueueSweeperTest`(Testcontainers Redis) — enqueue → 스윕이 due 항목을 조회해 `reprocess()` 후 `ZREM`하는지, 실패 시 백오프 score로 재적재되는지, `maxAttempts` 초과 시 데드레터(ZREM+로그) 처리되는지

## Deviation Log

### 2026-07-12 — Redis Streams+Consumer Group → Redis Sorted Set+단일 스케줄 폴러
- **배경**: 원래 계획은 Redis Streams(XADD) + Consumer Group(`RetryStreamListener`로 즉시소비, `RetryQueueSweeper`로 `XPENDING`/`XCLAIM` 기반 장애 복구)를 병행하는 구조였음. 사용자가 이 구성이 실제 실패 심각도(알림 미발송, 소셜 피드 미게시 등 — 데이터 정합성 문제가 아닌 저심각도 이벤트가 대부분) 대비 비용이 과한지 재검토를 요청.
- **조사 결과**: 이 프로젝트의 Redis는 현재 순수 캐시 용도(리프레시 토큰, 메일 인증코드 등)로만 쓰이고 AOF 등 영속성 설정이 없으며, Redis Streams 사용 이력도 전무. `spring-retry`(`@EnableRetry`)는 이미 `SeasonBatchService`에서 검증된 패턴으로 사용 중. 배포는 단일 인스턴스(docker-compose, replica 없음) 구성.
- **1차 대안(DB outbox 테이블)**: Postgres 기반 outbox 테이블 + `@Scheduled` 폴링을 제안했으나, 사용자가 Flyway 마이그레이션을 동반하는 신규 테이블 추가에 부담을 표함.
- **최종 결정**: DB 테이블 없이 기존 Redis만 재사용하되, Streams의 컨슈머 그룹(즉시소비 리스너 + ack/idle-claim 이원 경로)은 제거하고 Sorted Set(ZADD/ZRANGEBYSCORE/ZREM) 기반 단일 `@Scheduled` 폴링 하나로 통일. 재시도 대상은 이미 한 번 실패한 이벤트라 즉시 소비 경로가 애초에 불필요하다는 점을 근거로 함. 이로써 신규 파일이 6개(Publisher, 구현체, Target 인터페이스, Listener, ConsumerConfig, Sweeper)에서 4개(Publisher, 구현체, Target 인터페이스, Sweeper)로 줄고, 컨슈머 그룹 부트스트랩/`BUSYGROUP` 처리/ack 시맨틱스가 사라짐.
- **트레이드오프로 남는 점**: (1) Redis 재시작 시 유실 방지를 위해 AOF는 여전히 필요(다만 이는 docker-compose 커맨드 한 줄로, 스키마 마이그레이션과 성격이 다름). (2) Redis 자체 장애 시 방어선 없음 — Streams 방식이었어도 동일했던 한계. (3) "처리 성공 후 ZREM 사이" 크래시 시 중복 처리 가능성(at-least-once) — Streams+ack 방식도 "처리 후 ack 사이" 크래시에서 동일한 리스크가 있었으므로 새로 생긴 문제는 아님. 대상 이벤트들이 중복에 민감하지 않다고 판단해 별도 idempotency 키는 두지 않기로 함.

### 구현 중 trivial 편차
- `RedisRetryEventPublisher.java`, `RetryQueueSweeper.java`: 페이로드 메타 필드명(`__retryId`, `__attempt`)을 공용 상수 파일 없이 각 클래스 상단에 `private static final`로 개별 선언 — 이유: common.md의 매직스트링 금지 컨벤션은 지키되, 계획서의 "신규 파일" 목록에 없는 별도 상수 클래스를 추가하지 않기 위함. 문자열 2개 중복은 감수.
- `RetryQueueSweeper.java`: 계획서 pseudocode(단일 메서드)를 `processDueEntry`/`requeueOrDeadLetter` 두 메서드로 분리하고, JSON 파싱 실패를 별도로 방어 처리(파싱 실패 시 즉시 데드레터) — 이유: 파싱 실패 시 예외가 그대로 전파되면 해당 스윕 사이클에서 같은 target의 나머지 due 항목 처리가 중단되는 문제가 있어 방어적으로 분리.
