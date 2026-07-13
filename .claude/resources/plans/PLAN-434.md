# [PLAN-434] 이벤트 리스너 실패 처리 및 복원력 개선 (UserLeagueEventListener/NotificationEventListener/SocialFeedEventListener)

> 이슈: #434
> 브랜치: refactor/434-listener-resilience

## 목표
세 리스너가 겪는 실패 처리 문제는 공통적으로 "AFTER_COMMIT 이후 부가 작업이 실패했을 때 어떻게 반드시 완료시킬 것인가"로 귀결된다. 이번 계획에서는:
1. 공용 재시도 인프라(Redis Sorted Set + 단일 스케줄 폴러, `global/event/retry/`)를 한 번 만들고
2. `createUserLeague`를 포함한 6개 핸들러 전부를 동일한 패턴(`AFTER_COMMIT` + try/catch + 실패 시 큐 적재)으로 통일한다. 초기 계획은 `createUserLeague`(→`initUserLeague`)만 예외적으로 onboarding 트랜잭션과 물리적으로 묶어(NESTED+`@Retryable`) 실패 시 전체 롤백시키는 설계였으나, 구현 중 "하위 서비스 실패가 상위 트랜잭션 전체를 롤백시키지 않아야 한다"는 목표와 상충한다고 판단해 나머지와 동일한 큐 기반으로 전환했다(배경은 Deviation Log의 2026-07-13 항목 참고).
3. 재시도해도 결과가 달라지지 않는 비즈니스 예외(`USER_LEAGUE_CONFLICT`, `USER_LEAGUE_NOT_FOUND`, `LEAGUE_NOT_MATCH_LEAGUE_POINT` 등)는 리스너·RetryTarget 양쪽에서 큐 적재를 생략한다.

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
- `src/main/java/gravit/code/userLeague/listener/UserLeagueEventListener.java` — `handleLessonCompleted` 실패 시 `retryEventPublisher.publish(...)` 호출로 변경(그 외 동기 우선 시도 로직 유지), `createUserLeague`도 `AFTER_COMMIT` + try/catch + 큐 적재로 전환(전환 배경은 Deviation Log 2026-07-13 참고)
- `src/main/java/gravit/code/userLeague/service/UserLeagueService.java` — `initUserLeague`를 `REQUIRES_NEW` 전파로 변경(`@Retryable` 미적용)
- `src/main/java/gravit/code/userLeague/service/UserLeaguePointService.java` — `addLeaguePoints`를 `REQUIRES_NEW`로 변경
- `src/main/java/gravit/code/notification/listener/NotificationEventListener.java` — 3개 핸들러 모두 `@Transactional(REQUIRES_NEW)` 제거, 서비스 직접 호출 대신 큐 적재로 변경
- `src/main/java/gravit/code/social/listener/SocialFeedEventListener.java` — 3개 핸들러 모두 `@Async`/`@Transactional` 제거, 큐 적재로 변경
- `src/main/java/gravit/code/global/config/AsyncConfig.java` — `socialFeedAsync` 빈 제거(사용처 없어짐)
- `docker-compose-dev.yml`, `docker-compose-local.yml`, `docker-compose-prod.yml` — redis 서비스에 AOF 활성화 커맨드 추가(Redis 재시작 시 재시도 큐 유실 방지)

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
   - `@Transactional` → `@Transactional(propagation = Propagation.REQUIRES_NEW)`
   - `@Retryable` 미적용 — JPA `JpaTransactionManager`는 savepoint를 지원하지 않아 `NESTED`가 애초에 `NestedTransactionNotSupportedException`을 던졌고(구현 중 발견), DB transient 예외에 대한 3회 인메모리 재시도도 Redis 큐의 재시도(최대 10회 백오프)와 중복이라 판단해 제거.

7. **`UserLeagueEventListener.createUserLeague`**
   - `phase = BEFORE_COMMIT` → `phase = AFTER_COMMIT`, try/catch 추가
   - `RestApiException`의 `errorCode`가 `USER_LEAGUE_CONFLICT`(이미 리그 존재) 또는 `USER_NOT_FOUND`(onboarding 트랜잭션 커밋 후에도 유저가 없는 데이터 정합성 문제 — 재시도로 해소 불가)면 큐 적재를 생략하고 로그만 남긴다. 그 외 예외(예: `LEAGUE_NOT_FOUND` — 시드 데이터 지연 반영 가능성 있어 재시도 대상 유지)는 `user-league-create-retry` 큐에 적재. onboarding 트랜잭션 전체를 롤백시키지 않는다(원 설계에서 전환 — Deviation Log 2026-07-13 참고).

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
    - `docker-compose-dev.yml`, `docker-compose-local.yml`, `docker-compose-prod.yml`의 `gravit-redis-{dev,local,prod}` 서비스에 `command: redis-server --appendonly yes --appendfsync everysec` 추가.

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

## 후속 조치: CodeRabbit 리뷰 대응 (2026-07-13, 구현 완료)

> PR #435에 대한 CodeRabbit 자동 리뷰(actionable 7개 + nitpick 4개) 중, 실제 코드를 확인해 개선이 필요하다고 판단한 항목만 정리한다. 판단하지 않은/기각한 항목은 하단 "검토했으나 미채택" 참고.
> 아래 21~27번은 모두 구현 완료. 전체 테스트(`./gradlew test`) 통과 확인.

### 수정 파일
- `src/main/java/gravit/code/global/event/retry/RedisRetryEventPublisher.java` — `publish()` 예외 삼킴 제거
- `src/main/java/gravit/code/global/event/retry/RetryQueueSweeper.java` — `reprocess`/`remove` try-catch 분리, 데드레터 저장소 추가
- `src/main/java/gravit/code/userLeague/listener/UserLeagueEventListener.java` — `createUserLeague`에 `USER_NOT_FOUND` 비재시도 처리 추가
- `src/main/java/gravit/code/notification/infrastructure/FollowedRetryTarget.java` — `USER_NOT_FOUND` 비재시도 처리 추가
- `docker-compose-dev.yml`, `docker-compose-prod.yml` — redis 메모리 제한 상향
- `src/test/java/gravit/code/social/listener/SocialFeedEventListenerIntegrationTest.java` — streak 재처리 테스트 추가

### 구현 계획

21. **`RedisRetryEventPublisher.publish`** — JSON 직렬화/Redis 적재(`opsForZSet().add`) 실패 시 현재는 `catch (Exception e)` 후 `log.error`만 남기고 정상 반환한다. 호출부(`UserLeagueEventListener`/`NotificationEventListener`/`SocialFeedEventListener`)의 try/catch가 큐 적재 실패를 감지할 방법이 없어져, 실패한 이벤트가 로그 한 줄만 남기고 완전히 유실된다. `log.error` 후 원래 예외를 `RuntimeException`으로 감싸 다시 던지도록 변경한다. 호출부의 기존 try/catch는 그대로 최후 방어선 역할을 한다(로그만 한 번 더 남기고 삼킴 — 큐 자체가 안 되면 더 할 수 있는 게 없으므로 현재 수준 유지).

22. **`RetryQueueSweeper.processDueEntry`** — 현재 `reprocess(fields)`와 `redisTemplate.opsForZSet().remove(...)`가 하나의 try 블록에 묶여 있어, `reprocess` 성공 후 `remove`만 실패해도 `catch`로 빠져 `requeueOrDeadLetter`가 호출되고, 이미 적용된 부작용(포인트 반영/알림 발송/피드 게시)이 다음 스윕에서 그대로 중복 실행된다. `reprocess` 전용 try-catch와 `remove` 전용 try-catch로 분리하여, `remove` 실패는 `log.warn`만 남기고 다음 스윕에서 자연스럽게 정리되도록 한다(재시도/데드레터 경로를 타지 않음).

23. **`RetryQueueSweeper` — 데드레터 저장소 추가** — 실패 payload가 영구 유실되는 지점이 두 곳 있다. 둘 다 `log.error`만 남기고 `return`하는데, 로그가 로테이션되면 어떤 유저의 어떤 알림/포인트 반영이 실패했는지 복구할 방법이 없어진다.
    - `requeueOrDeadLetter`: `attempt + 1 >= target.maxAttempts()`(재시도 한도 초과) 분기 — `return` 직전에 `redisTemplate.opsForList().leftPush(target.queueKey() + ":dead-letter", objectMapper.writeValueAsString(fields))` 추가
    - `processDueEntry`: JSON 파싱 실패 분기 — `redisTemplate.opsForZSet().remove(...)` 직후, `return` 직전에 `redisTemplate.opsForList().leftPush(target.queueKey() + ":dead-letter", json)`(파싱조차 안 된 raw 문자열 그대로) 추가
    - 두 경우 모두 키 규칙은 `{queueKey}:dead-letter`(예: `league-points-retry:dead-letter`)로 통일. List(`LPUSH`)를 쓰는 이유: 데드레터는 더 이상 자동 재시도 대상이 아니라 score(다음 시도 시각) 정렬이 필요 없고, 운영자가 `redis-cli LRANGE {queueKey}:dead-letter 0 -1`로 조회해 수동으로 원인 파악·재발행하는 용도면 충분하다. 자동 소비 컨슈머나 조회 API는 이번 범위 밖(TTL 없음, 수동 정리 전제).

24. **`UserLeagueEventListener.createUserLeague`** — 위 "구현 계획 B" 7번에 반영(비재시도 분기에 `USER_NOT_FOUND` 추가).

25. **`FollowedRetryTarget.reprocess`** — `userService.getUser(followerId)`가 `RestApiException(USER_NOT_FOUND)`를 던질 수 있다(그 사이 팔로워 탈퇴/삭제). `LeaguePointRetryTarget`/`UserLeagueCreateRetryTarget`과 동일한 `NON_RETRYABLE_ERRORS` 패턴을 도입해 `Set.of(CustomErrorCode.USER_NOT_FOUND)`인 경우 `log.warn` 후 종료, 그 외 예외는 그대로 재던진다.

26. **`docker-compose-dev.yml`, `docker-compose-prod.yml`** — `gravit-redis-{dev,prod}`의 `deploy.resources.limits.memory`를 `512M` → `768M`로 상향. AOF 활성화로 `BGREWRITEAOF`(백그라운드 재작성) 시 `fork()` 기반 COW로 메모리 사용량이 일시적으로 늘 수 있는데(쓰기가 몰릴수록 커짐), 재시도 큐가 이 Redis 인스턴스에 함께 적재되는 만큼 기존 512M로는 재작성 중 OOM kill 위험이 있다.

27. **`SocialFeedEventListenerIntegrationTest`** — `HandleLevelUp`/`HandleTierPromotion`과 동일한 패턴으로 `SocialFeedStreakRetryTarget`을 `@Autowired`로 주입하고, `streakRetryTarget.reprocess(Map.of("userId", "1", "days", "7"))` 호출 후 `socialFeedRepository.findAll()`에서 `STREAK_DAYS` 피드가 저장됐는지 검증하는 테스트를 `HandleLessonCompleted` 아래에 추가한다(레벨업·티어승급은 이미 reprocess 테스트가 있으나 streak만 enqueue 검증만 있고 누락되어 있었음).

### 검토했으나 미채택
- **재시도 멱등성 전면 도입(`__retryId` 기반 dedup)** — CodeRabbit 제안. 이미 본 문서 Deviation Log(2026-07-12)에서 "`reprocess` 성공~`ZREM` 사이 크래시로 인한 중복은 at-least-once로 감수하고, 대상 이벤트(포인트/알림/피드)가 중복에 민감하지 않다"고 명시적으로 결정한 사안이라 재검토하지 않는다. 다만 22번(`reprocess`/`remove` try-catch 분리)으로 "`remove` 자체 실패"가 불필요한 중복을 유발하는 경로는 별도로 좁힌다.
- **`handleLessonCompleted`의 `USER_LEAGUE_NOT_FOUND`를 재시도 대상으로 전환** — CodeRabbit 제안(온보딩·레슨완료 두 파이프라인 간 순서 경쟁 가능성). 문제 풀이에 걸리는 시간을 감안하면 그 시점까지도 유저 리그가 없는 것은 정상 흐름에서 나올 수 없는 심각한 이상 상태로 판단해 재시도 대상에서 제외하기로 이미 확정했다(비재시도 유지).
- **`InquiryAnsweredRetryTarget`에 비재시도 예외 처리 추가** — CodeRabbit 제안. 실제 코드 확인 결과 `reprocess()`가 호출하는 `NotificationFacade.notifyUser` → `NotificationService.notify`/`pushToUser`는 수신자 존재 여부를 검증하지 않는다(FK 체크 없이 `userId`만 저장, FCM 토큰이 없으면 조용히 스킵). `RestApiException`을 던지는 경로 자체가 없어 해당 사항 없음.

### 검증 (후속 조치)
- [x] `UserLeagueEventListenerIntegrationTest` — `createUserLeague`에서 `USER_NOT_FOUND` 발생 시 큐 적재 생략 검증(`유저가_존재하지_않으면_재시도_큐에_적재하지_않는다`로 기존 테스트 갱신), 재시도 대상(`LEAGUE_NOT_FOUND`) 케이스 커버리지 보강(`매칭되는_리그가_없으면_재시도_큐에_적재된다` 신규 추가)
- [x] `FollowedRetryTarget` 재처리 테스트 — `SocialFacadeIntegrationTest.Follow`에 `재처리_시점에_팔로워가_존재하지_않으면_알림을_생성하지_않는다` 추가
- [x] `SocialFeedEventListenerIntegrationTest` — streak 재처리 테스트 추가(27번, `연속_학습일_재처리시_피드가_DB에_저장된다`)
- [ ] `RetryQueueSweeperTest`(Testcontainers Redis, 신규) — `remove()`가 예외를 던져도 `reprocess` 성공 건이 재적재/중복 처리되지 않는지, `maxAttempts` 초과 시 `{queueKey}:dead-letter` List에 payload가 남는지. Redis 실패를 주입하려면 `RedisTemplate`을 스파이/모킹해야 해서 이번 반영 범위에서 보류 — 필요 시 별도 작업으로 진행
- [ ] `RedisRetryEventPublisherTest`(신규) — Redis 적재 실패 시 예외가 호출부로 전파되는지. 위와 동일한 이유로 보류

## Deviation Log

### 2026-07-12 — Redis Streams+Consumer Group → Redis Sorted Set+단일 스케줄 폴러
- **배경**: 원래 계획은 Redis Streams(XADD) + Consumer Group(`RetryStreamListener`로 즉시소비, `RetryQueueSweeper`로 `XPENDING`/`XCLAIM` 기반 장애 복구)를 병행하는 구조였음. 사용자가 이 구성이 실제 실패 심각도(알림 미발송, 소셜 피드 미게시 등 — 데이터 정합성 문제가 아닌 저심각도 이벤트가 대부분) 대비 비용이 과한지 재검토를 요청.
- **조사 결과**: 이 프로젝트의 Redis는 현재 순수 캐시 용도(리프레시 토큰, 메일 인증코드 등)로만 쓰이고 AOF 등 영속성 설정이 없으며, Redis Streams 사용 이력도 전무. `spring-retry`(`@EnableRetry`)는 이미 `SeasonBatchService`에서 검증된 패턴으로 사용 중. 배포는 단일 인스턴스(docker-compose, replica 없음) 구성.
- **1차 대안(DB outbox 테이블)**: Postgres 기반 outbox 테이블 + `@Scheduled` 폴링을 제안했으나, 사용자가 Flyway 마이그레이션을 동반하는 신규 테이블 추가에 부담을 표함.
- **최종 결정**: DB 테이블 없이 기존 Redis만 재사용하되, Streams의 컨슈머 그룹(즉시소비 리스너 + ack/idle-claim 이원 경로)은 제거하고 Sorted Set(ZADD/ZRANGEBYSCORE/ZREM) 기반 단일 `@Scheduled` 폴링 하나로 통일. 재시도 대상은 이미 한 번 실패한 이벤트라 즉시 소비 경로가 애초에 불필요하다는 점을 근거로 함. 이로써 신규 파일이 6개(Publisher, 구현체, Target 인터페이스, Listener, ConsumerConfig, Sweeper)에서 4개(Publisher, 구현체, Target 인터페이스, Sweeper)로 줄고, 컨슈머 그룹 부트스트랩/`BUSYGROUP` 처리/ack 시맨틱스가 사라짐.
- **트레이드오프로 남는 점**: (1) Redis 재시작 시 유실 방지를 위해 AOF는 여전히 필요(다만 이는 docker-compose 커맨드 한 줄로, 스키마 마이그레이션과 성격이 다름). (2) Redis 자체 장애 시 방어선 없음 — Streams 방식이었어도 동일했던 한계. (3) "처리 성공 후 ZREM 사이" 크래시 시 중복 처리 가능성(at-least-once) — Streams+ack 방식도 "처리 후 ack 사이" 크래시에서 동일한 리스크가 있었으므로 새로 생긴 문제는 아님. 대상 이벤트들이 중복에 민감하지 않다고 판단해 별도 idempotency 키는 두지 않기로 함.

### 2026-07-13 — createUserLeague를 NESTED+세이브포인트 방식에서 REQUIRES_NEW+큐 방식으로 전환
- **배경**: 원 계획(구현 계획 B, 6-7번)은 `initUserLeague`를 `Propagation.NESTED`+`@Retryable`로 처리하고, `createUserLeague`는 `BEFORE_COMMIT`에서 예외를 그대로 전파시켜 onboarding 트랜잭션 전체를 롤백하는 설계였다. 구현 중 실행해보니 `NESTED`는 Spring `JpaTransactionManager`가 savepoint를 지원하지 않아 호출 즉시 `NestedTransactionNotSupportedException`을 던지는 것으로 확인됐다(JPA 환경에서 원천적으로 성립하지 않는 조합).
- **1차 수정**: `Propagation.NESTED` → `Propagation.REQUIRES_NEW`로 변경(JPA에서 지원되는 전파 방식, `UserLeaguePointService.addLeaguePoints`와 동일 패턴).
- **재검토**: `REQUIRES_NEW`로 바뀌면서 "재시도 소진 시 onboarding 트랜잭션 전체 롤백"이라는 원 설계의 전제 자체가 무의미해졌다(REQUIRES_NEW는 이미 별도 트랜잭션이라 실패해도 onboarding 트랜잭션에 영향을 주지 않는다). 이 시점에 "하위 서비스 실패가 상위 트랜잭션 전체를 롤백시키지 않도록 한다"는 이슈의 근본 목표와 원 설계가 상충한다고 판단해, `createUserLeague`도 나머지 5개 핸들러와 동일하게 `AFTER_COMMIT` + try/catch + 큐 적재 패턴으로 통일했다.
- **추가 결정**: DB transient 예외에 대한 `@Retryable`도 제거(3회 인메모리 재시도가 Redis 큐의 최대 10회 백오프 재시도와 중복이라 판단).
- **재시도 큐 적재 예외 필터링 도입**: 큐 적재 여부를 판단할 때, 재시도해도 결과가 달라지지 않는 비즈니스 예외(`RestApiException`)는 큐 적재를 생략하도록 리스너·RetryTarget 양쪽에 분기를 추가했다. 대상: `createUserLeague`의 `USER_LEAGUE_CONFLICT`, `handleLessonCompleted`의 `USER_LEAGUE_NOT_FOUND`/`LEAGUE_NOT_MATCH_LEAGUE_POINT`. `USER_LEAGUE_NOT_FOUND`를 비재시도로 분류한 근거: 레슨 완료 시점까지도 유저 리그가 없는 것은(문제 풀이 소요 시간을 감안하면) 정상 흐름에서 나올 수 없는 심각한 이상 상태로 판단했다.
- **CodeRabbit 리뷰(PR #435) 대응**: 위 전환 배경이 원 문서에 기록되지 않아 계획서와 구현이 상충한다는 지적을 받아, "목표"·"구현 계획 B" 본문을 최종 구현에 맞게 갱신하고 이 항목을 추가했다. 상세 후속 조치는 "## 후속 조치: CodeRabbit 리뷰 대응" 섹션 참고.

### 구현 중 trivial 편차
- `RedisRetryEventPublisher.java`, `RetryQueueSweeper.java`: 페이로드 메타 필드명(`__retryId`, `__attempt`)을 공용 상수 파일 없이 각 클래스 상단에 `private static final`로 개별 선언 — 이유: common.md의 매직스트링 금지 컨벤션은 지키되, 계획서의 "신규 파일" 목록에 없는 별도 상수 클래스를 추가하지 않기 위함. 문자열 2개 중복은 감수.
- `RetryQueueSweeper.java`: 계획서 pseudocode(단일 메서드)를 `processDueEntry`/`requeueOrDeadLetter` 두 메서드로 분리하고, JSON 파싱 실패를 별도로 방어 처리(파싱 실패 시 즉시 데드레터) — 이유: 파싱 실패 시 예외가 그대로 전파되면 해당 스윕 사이클에서 같은 target의 나머지 due 항목 처리가 중단되는 문제가 있어 방어적으로 분리.
