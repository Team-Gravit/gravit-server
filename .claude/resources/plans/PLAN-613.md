# [PLAN-613] Redis 장애 시 서비스 전체 정지와 작업 유실 방지

> 이슈: #613
> 브랜치: fix/613-redis-outage-resilience

## 목표
기본 Redis 연결은 명령 타임아웃이 60초이고, 연결이 끊긴 동안 명령을 버퍼에 쌓아 둔다. 그래서 Redis가 죽으면 Redis를 쓰는 요청이 요청 스레드와 DB 커넥션을 최대 60초 붙잡고, Redis와 무관한 API까지 멈출 수 있다. 알림과 피드는 재시도 큐에만 넣으므로 Redis 장애 중에는 유실되고, 랭킹 조회는 상한 없이 전부 DB 폴백으로 몰린다.
Redis가 죽으면 **바로 실패하게** 하고, 알림과 피드는 **큐 적재가 실패하면 그 자리에서 처리**하고, 랭킹 DB 폴백에는 **동시 실행 상한**을 둔다. 운영 Redis에는 `maxmemory`를 걸어 **OOM으로 종료되지 않게** 한다.

## 선행 조건
- 없음. #608(`RetryQueueSweeper`, `SchedulingConfig`), #609(`RedisLeagueRankingStore`, `LeagueRankingRebuildService`, `LeagueRankSyncListener`)와 수정 파일이 겹치지 않는다. 머지 순서와 상관없이 구현할 수 있다
- 다만 **측정 M3(랭킹 폴백 HTTP 측정)은 STEP 4보다 먼저** 한다. 동시 실행 상한(D6)을 이 측정으로 정한다

## 현재 코드에서 확인한 사실 (계획의 근거)
| # | 사실 | 위치 |
|---|---|---|
| F1 | 기본 연결은 `new LettuceConnectionFactory(host, port)`로 직접 만든다. 그래서 Boot 자동 설정(`spring.data.redis.timeout`)이 적용되지 않고, Spring Data Redis 기본값인 명령 타임아웃 60초가 걸린다. yml에도 timeout 설정이 없다 | `RedisConfig:37-41`, `application*.yml` |
| F2 | 두 연결 모두 `ClientOptions.disconnectedBehavior`가 기본값이다. Lettuce는 `autoReconnect=true`일 때 기본값으로 끊긴 동안의 명령을 버퍼에 쌓고, 명령 타임아웃이 지나서야 실패시킨다 (라이브러리 기본 동작이고, 코드에서 재현한 적은 없다. M0에서 확인한다) | `RedisConfig:54-67` |
| F3 | 랭킹 연결은 명령, 접속 타임아웃이 100ms라 장애 때도 100ms 안에 실패한다. 버퍼링은 기본 연결과 같다 | `RedisConfig:23, 54-67` |
| F4 | 요청 스레드에서 기본 연결을 쓰는 곳: 모든 `AFTER_COMMIT` 리스너의 재시도 큐 적재(알림과 피드는 항상, 나머지는 실패할 때), 토큰 재발급과 로그아웃, OAuth state, 메일 인증 코드, 리그 홈 시즌 팝업 | `RedisRetryEventPublisher`, `AuthTokenProvider:61-94`, `LeagueService:73, 85` |
| F5 | 리그 홈 시즌 팝업의 Redis 호출 두 번은 `@Transactional` 안에 있다. Redis를 기다리는 동안 DB 커넥션도 붙잡는다. Hikari 풀은 설정이 없어 기본값 10이다. 리그 홈 요청 10개만 묶여도 풀이 바닥나고, DB를 쓰는 다른 API가 커넥션을 기다리며 멈춘다(코드 기준 추정, M1에서 확인) | `LeagueService:57-89`, `application-prod.yml` |
| F6 | 레슨 제출처럼 쓰기 트랜잭션 뒤의 `AFTER_COMMIT` 리스너도 커넥션을 쥔 채 실행된다(`afterCommit`은 커넥션 정리보다 먼저 호출된다). 재시도 큐 적재가 60초 걸리면 그동안 커넥션이 반납되지 않는다(Spring 동작 기준 추정, M1에서 확인) | `facade.md` "어길 수 없는 제약" |
| F7 | 알림(공지, 팔로우, 문의 답변)과 피드(연속 학습, 레벨업, 티어 승급) 리스너는 큐에 적재만 한다. 적재가 실패하면 error 로그만 남고 유실된다. 나머지 리스너는 먼저 직접 처리하고, 실패할 때만 큐에 넣는다 | `NotificationEventListener:27-62`, `SocialFeedEventListener:30-74`, `facade.md:66-67` |
| F8 | 알림과 피드의 처리 메서드는 `REQUIRED`다. `AFTER_COMMIT` 리스너에서 그대로 부르면 이미 커밋된 트랜잭션에 참여해, 쓰기가 커밋되지 않는다. 다른 리스너가 `REQUIRES_NEW` 서비스를 부르는 이유가 이것이다 | `SocialFacade:74`, `NotificationService:44`, `UserLeaguePointService:30` |
| F9 | 랭킹 DB 폴백에는 동시 실행 상한이 없다. 조회 서비스가 `@Transactional(readOnly = true)`라서 폴백 쿼리(100만 명 기준 p95 984ms, 이슈 본문) 동안 요청마다 커넥션을 하나씩 쥔다 | `LeagueRankFinder:59-74`, `UserLeagueQueryService:40-77` |
| F10 | `findRank`는 Redis에 순위가 없으면 저장소 조회 람다 **안에서** DB를 조회한다. 지금 구조에서는 이 DB 조회에 상한을 걸 자리가 없다 | `LeagueRankFinder:38-39` |
| F11 | 정책은 "리그에 참여한 유저는 순위가 집계돼 있지 않아도 즉시 계산해 응답하므로 0이 되지 않는다"이다. 폴백을 거절하면 이 규칙이 바뀌므로 **정책 변경**이다 | `league-season.md:14` |
| F12 | 운영 Redis는 `redis:latest`, AOF everysec, 컨테이너 메모리 제한 768M이고 `maxmemory`가 없다. 메모리가 제한에 닿으면 컨테이너가 OOM으로 종료된다. AOF 재작성 fork의 copy-on-write 여유도 이 768M 안에 있어야 한다. dev도 같다 | `docker-compose-prod.yml:20-39`, `docker-compose-dev.yml:20-34` |
| F13 | 서킷 브레이커 라이브러리가 없다. `spring-retry`만 있다 | `build.gradle:69` |
| F14 | 응답 코드 503을 쓰는 에러 코드는 아직 없다 | `CustomErrorCode` |

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/global/event/retry/RetryFallbackProcessor.java` - 큐 적재를 시도하고, 실패하면 새 트랜잭션(`REQUIRES_NEW`)에서 대상의 `reprocess`를 바로 실행
- `src/main/java/gravit/code/global/config/ResilienceConfig.java` - 랭킹 저장소 서킷 브레이커, DB 폴백 벌크헤드 빈과 Micrometer 연결
- `src/test/java/gravit/code/global/config/RedisConfigIntegrationTest.java`
- `src/test/java/gravit/code/global/event/retry/RetryFallbackProcessorIntegrationTest.java`
- `.claude/resources/perf/613/` - 측정 기록(M0~M4)

### 수정 파일
- `build.gradle` - Resilience4j `circuitbreaker`, `bulkhead`, `micrometer` 모듈 추가(D2)
- `src/main/java/gravit/code/global/config/RedisConfig.java` - 기본 연결에 명령, 접속 타임아웃 적용, 두 연결 모두 끊긴 동안 명령 즉시 거절
- `src/main/java/gravit/code/notification/listener/NotificationEventListener.java` - `publish` 대신 `RetryFallbackProcessor.publishOrProcess`
- `src/main/java/gravit/code/social/listener/SocialFeedEventListener.java` - 같음
- `src/main/java/gravit/code/userLeague/support/LeagueRankFinder.java` - 저장소 조회를 서킷 브레이커로 감싸고, DB 폴백을 벌크헤드로 제한, 상한 초과 시 503
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `LEAGUE_RANKING_TEMPORARILY_UNAVAILABLE` 추가
- `src/main/java/gravit/code/userLeague/controller/docs/UserLeagueControllerDocs.java` - 랭킹 조회 3개 API에 503 응답 추가
- `src/main/java/gravit/code/league/service/LeagueService.java` - 시즌 팝업의 Redis 실패 시 팝업 없이 응답(D4)
- `docker-compose-prod.yml`, `docker-compose-dev.yml` - Redis에 `--maxmemory`, `--maxmemory-policy noeviction` 추가(D5)
- `src/test/java/gravit/code/notification/listener/NotificationEventListenerIntegrationTest.java` - 적재 실패 시 직접 처리 시나리오 추가
- `src/test/java/gravit/code/social/listener/SocialFeedEventListenerIntegrationTest.java` - 같음
- `src/test/java/gravit/code/userLeague/support/LeagueRankFinderIntegrationTest.java` - 브레이커 개방, 벌크헤드 거절 시나리오 추가
- `src/test/java/gravit/code/league/service/LeagueServiceTest.java` - 팝업 Redis 실패 시나리오 추가(D4)
- `.claude/spec/service-policy/league-season.md` - **정책 변경**: 순위 계산이 몰리면 잠시 순위를 주지 않고 "순위 집계 중"으로 응답한다
- `.claude/rules/code-convention/facade.md` - "보상의 실제 성질"의 소셜 피드와 알림 설명 갱신(적재 실패 시 직접 처리)

## 구현 계획

### STEP 1. Redis 연결이 바로 실패하게 (Global)
**`RedisConfig`**
- 상수
  - `DEFAULT_COMMAND_TIMEOUT = Duration.ofSeconds(1)` (D1)
  - `DEFAULT_CONNECT_TIMEOUT = Duration.ofSeconds(1)`
  - 기존 `RANKING_COMMAND_TIMEOUT = Duration.ofMillis(100)` 유지
- `private LettuceConnectionFactory failFastConnectionFactory(Duration commandTimeout, Duration connectTimeout)`
  ```java
  ClientOptions clientOptions = ClientOptions.builder()
          .autoReconnect(true)
          .disconnectedBehavior(ClientOptions.DisconnectedBehavior.REJECT_COMMANDS)
          .socketOptions(SocketOptions.builder().connectTimeout(connectTimeout).build())
          .build();
  LettuceClientConfiguration clientConfiguration = LettuceClientConfiguration.builder()
          .commandTimeout(commandTimeout)
          .clientOptions(clientOptions)
          .build();
  return new LettuceConnectionFactory(new RedisStandaloneConfiguration(redisHost, redisPort), clientConfiguration);
  ```
- `redisConnectionFactory()` → `failFastConnectionFactory(DEFAULT_COMMAND_TIMEOUT, DEFAULT_CONNECT_TIMEOUT)`
- `rankingRedisConnectionFactory()` → `failFastConnectionFactory(RANKING_COMMAND_TIMEOUT, RANKING_COMMAND_TIMEOUT)` (끊긴 동안 거절만 새로 붙는다)
- 두 설정을 함께 두는 이유
  - 거절(`REJECT_COMMANDS`)은 Lettuce가 끊김을 **안 뒤에만** 동작한다. 컨테이너가 죽으면 RST로 바로 알지만, 호스트가 멈추거나 네트워크가 끊겨 응답 없이 사라지면 알기까지 시간이 걸린다. 그동안은 타임아웃이 상한이다
  - 타임아웃만 두면 끊긴 동안의 명령이 매번 타임아웃만큼 기다린다
- 예외 변환: 거절은 Lettuce `RedisException` → `RedisSystemException`, 타임아웃은 `QueryTimeoutException`, 접속 실패는 `RedisConnectionFailureException`이다. `LeagueRankFinder`가 이미 이 세 가지를 잡는다. 테스트로 확인한다

### STEP 2. 리그 홈 시즌 팝업의 Redis 실패 격리 (Service, D4)
**`LeagueService.computeLastSeasonPopup`**
- `seasonClosedCache.getLastClosedSeasonId()`와 `seasonPopupSeenStore.markSeenIfFirst(...)`를 `private Optional<Long> findLastClosedSeasonId()`, `private boolean markPopupSeenIfFirst(long userId, long seasonId, Duration ttl)`로 감싼다
- `DataAccessException`을 잡으면 warn 로그 "시즌 팝업 Redis 조회 실패, 팝업 없이 응답: userId={}"를 남기고 각각 `Optional.empty()`, `false`를 반환한다. 이렇게 하면 리그 홈은 팝업 없이 정상 응답한다
- 팝업 표시 여부를 기록하지 못했으므로, Redis가 회복된 뒤 다음 진입에서 팝업이 나온다. 팝업이 두 번 뜨지는 않는다(기록이 실패했으면 이번에는 보여주지 않았기 때문이다)

### STEP 3. 알림, 피드 적재 실패 시 직접 처리 (Global / Listener)
**`RetryFallbackProcessor`** (`global/event/retry`, `@Component`)
- 필드: `RetryEventPublisher retryEventPublisher`, `TransactionTemplate requiresNewTemplate`
  - 생성자에서 `PlatformTransactionManager`를 받아 `new TransactionTemplate(transactionManager)` 후 `setPropagationBehavior(PROPAGATION_REQUIRES_NEW)`. 자동 등록된 `TransactionTemplate`은 `REQUIRED`라 그대로 쓰면 F8 문제가 그대로 남는다
- `public void publishOrProcess(RetrySweepTarget target, Map<String, String> fields)`
  ```java
  try {
      retryEventPublisher.publish(target.queueKey(), fields);
      return;
  } catch (Exception e) {
      log.warn("재시도 큐 적재 실패, 직접 처리: queueKey={}", target.queueKey(), e);
  }
  try {
      requiresNewTemplate.executeWithoutResult(status -> target.reprocess(fields));
  } catch (Exception e) {
      log.error("재시도 큐 적재와 직접 처리 모두 실패, 유실: queueKey={}, fields={}", target.queueKey(), fields, e);
  }
  ```
- 직접 처리도 큐와 같은 `reprocess`를 쓴다. 처리 로직을 한 곳에 두어, 큐로 처리한 결과와 직접 처리한 결과가 달라지지 않게 한다
- 예외를 밖으로 던지지 않는다(`AFTER_COMMIT` 예외는 어차피 호출자에게 닿지 않는다, `facade.md`)

**`NotificationEventListener`**
- `RetryEventPublisher` 대신 `RetryFallbackProcessor`와 대상 3개(`NoticeCreatedRetryTarget`, `FollowedRetryTarget`, `InquiryAnsweredRetryTarget`)를 주입한다
- 각 핸들러의 `retryEventPublisher.publish(X.QUEUE_KEY, fields)` → `retryFallbackProcessor.publishOrProcess(xTarget, fields)`
- 각 핸들러의 바깥 `try/catch`는 payload를 만들다 생기는 예외(`event.title()`이 null이라 `Map.of`에서 NPE 등) 기록용으로 남긴다

**`SocialFeedEventListener`**
- 같은 방식으로 대상 3개(`SocialFeedStreakRetryTarget`, `SocialFeedLevelUpRetryTarget`, `SocialFeedTierPromotionRetryTarget`)를 주입해 바꾼다

**알고 받아들이는 것**
- 적재가 Redis에는 들어갔는데 응답만 타임아웃(1초)으로 끊기면, 큐 항목과 직접 처리가 둘 다 실행돼 알림이나 피드가 두 번 생길 수 있다. Redis가 죽어서 거절된 경우에는 생기지 않는다. 알림과 피드는 중복돼도 금전성 피해가 없어서 받아들인다
- 문의 답변 직접 처리는 FCM 푸시가 트랜잭션 안에서 나간다(`NotificationFacade.notifyUser`). 푸시 뒤 커밋이 실패할 확률은 무시한다
- 장애 중 공지 등록은 관리자 요청 스레드에서 `INSERT ... SELECT`로 전체 유저 알림을 바로 만든다. 관리자 API라 지연을 받아들인다

### STEP 4. 랭킹 조회 서킷 브레이커와 DB 폴백 상한 (Global / Support)
> M3(폴백 HTTP 측정)을 먼저 하고, 아래 수치(D6)를 확정한 뒤 구현한다.

**`build.gradle`** (D2)
```groovy
implementation 'io.github.resilience4j:resilience4j-circuitbreaker:2.3.0'
implementation 'io.github.resilience4j:resilience4j-bulkhead:2.3.0'
implementation 'io.github.resilience4j:resilience4j-micrometer:2.3.0'
```
- 스타터(`resilience4j-spring-boot3`)는 쓰지 않는다. 대상이 한 곳이라 어노테이션, AOP 없이 코드에서 직접 감싼다

**`ResilienceConfig`** (`global/config`)
- `@Bean CircuitBreaker leagueRankingStoreCircuitBreaker(MeterRegistry meterRegistry)`
  - `slidingWindowType(COUNT_BASED)`, `slidingWindowSize(20)`, `minimumNumberOfCalls(10)`, `failureRateThreshold(50)`
  - `waitDurationInOpenState(Duration.ofSeconds(10))`, `permittedNumberOfCallsInHalfOpenState(3)`
  - `recordExceptions(RedisConnectionFailureException.class, RedisSystemException.class, QueryTimeoutException.class)`
  - 이름 `league-ranking-store`. `CircuitBreakerRegistry`에 등록한 뒤 `TaggedCircuitBreakerMetrics.ofCircuitBreakerRegistry(registry).bindTo(meterRegistry)`
- `@Bean Bulkhead leagueRankDatabaseBulkhead(MeterRegistry meterRegistry)`
  - `maxConcurrentCalls(D6, 초기값 4)`, `maxWaitDuration(Duration.ZERO)`
  - 이름 `league-rank-db-fallback`. `TaggedBulkheadMetrics`로 연결
- 수치는 `ResilienceConfig`의 상수로 둔다. 근거(M3 측정 ID)는 코드 주석이 아니라 이 계획서와 측정 기록에 남긴다

**`LeagueRankFinder`**
- 주입 추가: `CircuitBreaker leagueRankingStoreCircuitBreaker`, `Bulkhead leagueRankDatabaseBulkhead`
- `findRank` 재구성(F10)
  ```java
  Optional<Optional<Integer>> stored = fromStore(FIND_RANK_OPERATION, seasonId, leagueId,
          () -> leagueRankingStore.findRank(seasonId, leagueId, userId));
  if (stored.isPresent() && stored.get().isEmpty()) {
      log.warn("랭킹 저장소에 순위가 없어 DB로 폴백: ...");
  }
  return stored.flatMap(Function.identity())
          .orElseGet(() -> fromDatabase(FIND_RANK_OPERATION, seasonId, leagueId,
                  () -> userLeagueRepository.findRankInLeague(seasonId, leagueId, leaguePoint, userId)));
  ```
  저장소에 순위가 없을 때와 저장소 장애일 때가 같은 상한 경로(`fromDatabase`)로 모인다. "순위가 없어 DB로 폴백" warn 로그는 저장소가 정상 응답했는데 비어 있는 경우에만 남긴다. 기존 `findRankFromDatabase`는 지운다
- `findPage`도 같은 방식: `fromStore(...)`가 비어 있으면(장애 또는 개방) `fromDatabase(...)`
- `private <T> Optional<T> fromStore(String operation, long seasonId, long leagueId, Supplier<T> query)` (기존 `withFallback` 대체)
  - `leagueRankingStoreCircuitBreaker.executeSupplier(query)` 결과를 `Optional.of`
  - `CallNotPermittedException` → `Optional.empty()`. 로그를 남기지 않는다(개방 동안 요청마다 쌓이지 않게. 상태 전이는 Micrometer 지표와 이벤트 로그로 본다)
  - `RedisConnectionFailureException | RedisSystemException | QueryTimeoutException` → 기존 error 로그 유지 후 `Optional.empty()`
- `private <T> T fromDatabase(String operation, long seasonId, long leagueId, Supplier<T> query)`
  - `leagueRankDatabaseBulkhead.executeSupplier(query)`
  - `BulkheadFullException` → warn 로그 "랭킹 DB 폴백 상한 초과로 거절" 후 `throw new RestApiException(LEAGUE_RANKING_TEMPORARILY_UNAVAILABLE)`
- 브레이커 상태 전이 로그: `ResilienceConfig`에서 `circuitBreaker.getEventPublisher().onStateTransition(e -> log.warn(...))`. 상태가 바뀔 때만 한 줄 남긴다

**`CustomErrorCode`** (D3)
- `LEAGUE_RANKING_TEMPORARILY_UNAVAILABLE(SERVICE_UNAVAILABLE, "U_L_5031", "순위를 집계하고 있습니다. 잠시 후 다시 시도해주세요.")`

**`UserLeagueControllerDocs`**
- 내 순위, 리그별 목록, 내 리그 목록 3개 API에 503 `U_L_5031` 응답 예시 추가(`api-docs-convention.md`)

**#609와의 관계**
- 브레이커는 `LeagueRankFinder`의 조회에만 붙는다. #609의 반영(`place`, `evict`), 정기 대조, 유실 감지는 `RedisLeagueRankingStore`를 직접 써서 브레이커 영향을 받지 않는다
- Redis가 데이터 없이 돌아오면 `findPage`는 예외 없이 빈 목록을 돌려주므로 브레이커가 닫힌다. 빈 랭킹은 #609 유실 감지(30초 + 재구축)가 메운다. 이 계획에서 따로 다루지 않는다

### STEP 5. 운영 Redis 메모리 상한 (Infra, D5)
**`docker-compose-prod.yml`, `docker-compose-dev.yml`**
- `command: redis-server --appendonly yes --appendfsync everysec --maxmemory {D5} --maxmemory-policy noeviction`
- `noeviction`을 고르는 이유: 리프레시 토큰, 재시도 큐, 랭킹은 캐시가 아니라 원본이다. 키를 지우는 정책을 쓰면 조용히 사라진다. `noeviction`은 상한에서 쓰기만 OOM 오류로 거절하고, 읽기와 프로세스는 살아 있다
- 상한에 닿았을 때의 앱 동작: 쓰기 명령은 `RedisSystemException`으로 실패한다. 알림과 피드는 STEP 3으로 직접 처리되고, 랭킹 반영은 #609 재시도와 대조로 메워지고, 로그인 토큰 저장은 실패한다(받아들인다. 지표로 상한 도달 전에 알아채는 것이 목표다)
- 값: 운영 `INFO memory`(`used_memory_peak`, `used_memory_rss`, `mem_fragmentation_ratio`)를 확인한 뒤 확정한다. 768M 안에 AOF 재작성 fork의 copy-on-write와 클라이언트 버퍼 여유를 남겨야 해서, 후보는 512mb(약 2/3)다

### STEP 6. 정책, 규칙 문서
- `league-season.md` 14줄 교체: "리그에 참여한 유저는 순위가 집계돼 있지 않아도 즉시 계산해 응답하므로 0이 되지 않는다. 다만 순위 계산 요청이 한꺼번에 몰리면 일부 요청은 순위 대신 '순위 집계 중'(잠시 후 다시 시도) 응답을 받는다"
- `facade.md` 67줄 교체: "소셜 피드와 알림(공지 등록, 팔로우, 문의 답변): 리스너는 재시도 큐에 적재하고, 처리는 `RetryQueueSweeper`가 30초 주기로 한다. 적재가 실패하면(Redis 장애) 리스너가 새 트랜잭션에서 바로 처리한다(`RetryFallbackProcessor`)"

### Facade / DTO / Controller
- Facade: 불필요. 랭킹은 userLeague 안이고, 알림과 피드는 기존 리스너와 대상의 연결만 바뀐다
- DTO: 변경 없음(D3에서 503을 고르면 응답 DTO는 그대로다)
- Controller: 변경 없음. Docs 인터페이스에 503만 추가

## 결정 필요 (Decisions needed)
- [x] D1. 기본 연결 명령 타임아웃 - **1초**. 기본 연결의 명령은 전부 키 하나 또는 100건 이하 범위 조회라 정상일 때 1ms 안쪽이다. 1초면 정상 지연과는 겹치지 않고, 장애 때 요청 하나가 쥐는 시간을 60초에서 1초로 줄인다
- [x] D2. 서킷 브레이커 구현 - **Resilience4j 모듈 직접 사용** (세마포어 직접 구현안은 버림). STEP 1 뒤에는 Redis가 죽어도 조회가 즉시(거절) 또는 100ms(무응답) 안에 실패하므로, 브레이커가 아끼는 것은 무응답 장애 때의 요청당 100ms다. 핵심은 벌크헤드다. Resilience4j를 고르는 이유는 브레이커 상태와 거절 수가 Micrometer 지표로 바로 나와, 측정과 Grafana 관측을 따로 만들지 않아도 되기 때문이다
- [x] D3. 폴백 상한 초과 시 응답 - **503 + `U_L_5031`** (200 + null안은 버림). 503은 응답 DTO와 기존 필드의 의미를 바꾸지 않는다. null은 "0 = 순위 없음" 규칙과 별개로 클라이언트 분기가 하나 더 생긴다. 어느 쪽이든 프론트와 문구를 맞춰야 한다
- [x] D4. 리그 홈 시즌 팝업의 Redis 실패 격리(STEP 2) - **포함**. 이슈 본문의 범위(Redis와 무관한 API)에는 들지 않지만, F5대로 이 요청이 DB 커넥션을 쥐고 Redis를 기다린다. STEP 1로 대기는 1초가 되지만, 격리하지 않으면 Redis 장애 동안 리그 홈 자체가 500이 된다
- [ ] D5. `maxmemory` 값 - 운영 `INFO memory` 확인 후 확정(후보 512mb)
- [ ] D6. 벌크헤드 동시 실행 수와 브레이커 수치 - M3 측정 후 확정(초기값 동시 4, 대기 0)

## 검증
### 대상 테스트
- `RedisConfigIntegrationTest`
  - 기본 연결의 명령 타임아웃이 1초이고, 끊긴 동안 명령을 거절하도록 설정돼 있다(`LettuceConnectionFactory.getClientConfiguration()`)
  - 랭킹 연결도 끊긴 동안 명령을 거절하도록 설정돼 있다
- `RetryFallbackProcessorIntegrationTest`
  - 적재가 성공하면 직접 처리하지 않는다
  - 적재가 실패하면(`@MockitoBean RetryEventPublisher`가 예외) `reprocess`가 실행되고 그 쓰기가 커밋된다(F8 회귀 방지. `AFTER_COMMIT` 안에서 호출해 확인)
  - 직접 처리도 실패하면 예외를 던지지 않는다
- `NotificationEventListenerIntegrationTest`, `SocialFeedEventListenerIntegrationTest`
  - 적재가 실패해도 팔로우 알림, 레벨업 피드가 DB에 생긴다
- `LeagueRankFinderIntegrationTest`
  - 저장소 장애가 최소 호출 수 이상 이어지면 브레이커가 열리고, 이후에는 저장소를 부르지 않고 DB로 응답한다(`verify(store, times(n))`)
  - 벌크헤드가 가득 차면 `LEAGUE_RANKING_TEMPORARILY_UNAVAILABLE`을 던진다(벌크헤드 빈을 동시 1로 둔 테스트 설정 또는 `@MockitoBean`)
  - 저장소에 순위가 없을 때의 DB 조회도 벌크헤드를 거친다
- `LeagueServiceTest`
  - 시즌 팝업 Redis 조회가 실패하면 팝업 없이 응답한다(D4)

### 측정 계획 (이력서 수치용)
기록 위치는 `.claude/resources/perf/613/`이고, 숫자는 측정 대장에 ID와 로그를 함께 올린 것만 쓴다. 장애는 로컬 docker에서 `docker stop`(RST로 바로 끊김)과 `docker pause`(응답 없이 멈춤) 두 방식으로 주입한다. 성능 항목은 10월 재측정 조건(합성 시드 100만, ABBA 5회 중앙값)을 따른다.

| ID | 무엇을 | 방법 | 전 | 후 목표 |
|---|---|---|---|---|
| M0 | Lettuce 기본 동작 재현 | Redis 정지 중 기본 연결을 쓰는 API(리그 홈, 토큰 재발급) 1회 응답 시간. stop과 pause 각각 | 약 60초로 추정(F1, F2) | 1초 이내 |
| M1 | Redis와 무관한 API | k6로 무관한 API(챕터 조회 등)와 Redis를 쓰는 API(리그 홈, 레슨 제출)를 섞어 부하를 걸고, 중간에 Redis 60초 정지. 무관한 API의 p95와 오류율, Hikari 활성 커넥션, Tomcat 바쁜 스레드 | 정지 구간 p95, 오류율 측정값 | 정지 전과 같은 수준 |
| M2 | 알림, 피드 유실 | Redis 정지 중 팔로우 100건, 레벨업 피드가 생기는 제출 N건 발생 후 `notification`, `social_feed` 행 수 | 100건, N건 유실 | 0건 |
| M3 | 랭킹 DB 폴백 (선행) | Redis 정지, 100만 명 시드, 내 순위와 목록 API를 동시 1/2/4/8/16으로 호출. p95, DB 활성 커넥션, PostgreSQL CPU, 같은 시간의 무관한 API p95 | HTTP로 잰 적 없음 | D6 근거. 무관한 API p95가 정상 수준을 지키는 최대 동시 수 |
| M4 | 랭킹 DB 부하 전후 | M3의 동시 16 조건을 STEP 4 적용 후 재측정. 랭킹 p95, 거절 비율, DB 활성 커넥션과 CPU | M3 동시 16 값 | 활성 커넥션 ≤ D6, 무관한 API p95 정상 |
| M5 | 메모리 상한 | 로컬 Redis에 `maxmemory`를 걸고 큰 키로 채운다. 컨테이너 생존 여부와 앱의 쓰기 오류 | 768M에서 OOM 종료 | 생존, 쓰기만 거절 |

- M0, M2, M5는 결정적 장애 주입이라 1회로 충분하다. 실행 스크립트를 남긴다
- M1의 "전"은 이 브랜치의 STEP 1~3 적용 전 jar로 잰다. 커밋 해시를 기록한다

### 배포 체크리스트
- [ ] 운영 `INFO memory` 확인 후 D5 확정
- [ ] `redis-server` 실행 옵션이 바뀌어 운영 Redis 컨테이너가 재생성된다. AOF로 데이터는 유지되지만 수 초간 끊긴다. 사용량이 적은 시간에 배포한다
- [ ] 배포 뒤 `CONFIG GET maxmemory`, `CONFIG GET maxmemory-policy` 확인
- [ ] 503 `U_L_5031` 문구와 처리를 프론트와 공유(D3)

## 범위 밖 (한계로 기록)
- Redis 장애 동안 로그인, 토큰 재발급, 메일 인증은 실패한다. 저장소가 Redis뿐이라 대체 경로가 없다. 이번 작업은 1초 안에 실패하게 해서 다른 API를 지키는 데까지다
- 직접 처리를 먼저 하는 리스너(리그 점수, 미션, 일일 기록 등)는 직접 처리와 큐 적재가 **둘 다** 실패할 때만 유실된다. 이번 범위에 넣지 않는다. 리그 점수는 #608 대조가 메운다
- 운영 Redis 이미지가 `redis:latest`라 버전이 고정돼 있지 않다. 이번 범위에 넣지 않는다

## Deviation Log
