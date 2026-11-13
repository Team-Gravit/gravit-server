# [PLAN-609] 랭킹 동기화 실패 시 DB와 어긋남 해소

> 이슈: #609
> 브랜치: fix/609-ranking-sync-recovery

## 목표
DB 커밋 뒤 Redis 랭킹 반영이 실패하면 로그만 남고, 기동 시 대조는 인원 수만 비교한다. 그래서 점수가 틀린 건은 시즌이 끝날 때까지 남고, 목록(Redis LP)과 내 순위(DB LP)가 다르게 보일 수 있다. 리그 이동은 제거와 추가가 따로 실행돼 그 사이 실패하면 유저가 랭킹에서 빠진다.
반영 쓰기를 **원자적이고 순서에 안전한 단일 연산**으로 바꾸고, 실패는 **DB를 다시 읽는 재시도**로, 재시도 큐까지 실패한 경우(Redis 장애)는 **정기 대조**로 메워 어긋남이 남는 시간을 "시즌 끝까지"에서 "재시도 또는 대조 주기 이내"로 줄인다.

## 선행 조건
- **#608이 먼저 머지되어야 한다.** 정기 대조를 #608의 `retrySweepScheduler`에서 돌리고, 재시도 큐의 "추가 후 제거" 순서 교정을 전제로 한다. 이 브랜치는 #608 머지 뒤 `dev`로 rebase하고 구현을 시작한다.

## 현재 코드에서 확인한 사실 (계획의 근거)
| # | 사실 | 위치 |
|---|---|---|
| F1 | 반영 실패는 `catch (Exception)`에서 error 로그만 남긴다 | `LeagueRankSyncListener:19-26` |
| F2 | `move`는 `remove` 후 `put`, 두 번 왕복한다. 사이에서 실패하면 어느 리그에도 없게 된다 | `RedisLeagueRankingStore:47-60` |
| F3 | 이벤트는 반영 시점의 LP 절대값을 싣는다. 늦게 반영된 이벤트가 더 새로운 점수를 덮을 수 있다 | `LeagueRankChangedEvent`, `UserLeaguePointService:71-77` |
| F4 | 보정은 기동 시 `rebuildIfStale`(인원 수 비교)과 시즌 롤오버 재구축뿐이다. 점수만 틀리면 잡지 못한다 | `LeagueRankingRebuildService:34-47`, `SeasonBatchService:65` |
| F5 | 랭킹 Redis와 재시도 큐 Redis는 같은 호스트다. Redis 장애 때는 큐 적재도 함께 실패한다 | `RedisConfig:54-67` |
| F6 | 시즌 안에서 LP는 늘기만 한다. 변경 경로는 `UserLeague.addLeaguePoints`(가산)뿐이고, 감소는 시즌이 바뀌는 소프트 리셋(다른 시즌 키)에서만 일어난다 | `UserLeague:77-82`, `UserLeagueRepository.softResetForNextSeason` |
| F7 | 점수는 `LP × 10억 + (10억 − userId)`로 인코딩돼, 리그가 달라도 점수 비교가 곧 LP 비교다 | `LeagueRankScore` |
| F8 | `user_league`는 #478에서 HOT update 95.46%를 얻으려고 쓰기 경로 인덱스를 지웠다. `updated_at`에 인덱스를 걸면 매 쓰기마다 인덱스 값이 바뀌어 HOT이 다시 깨진다. 그래서 "최근 변경분만 대조"는 인덱스 없이는 전체 스캔과 비용이 같다 | V36, `결과-정리 §2` |

## 핵심 설계
### 1. 반영 연산 하나: `place`(배치) / `evict`(제외)
- 한 유저의 반영은 "시즌의 모든 리그 키에서 지우고, 목표 리그 하나에만 넣는다"를 Lua 스크립트 하나로 실행한다. 리그는 15개로 고정이라(정책) 키 15개를 넘긴다.
- **순서 보호**: `place`는 시즌의 어느 리그 키에든 더 큰 점수가 이미 있으면 아무것도 하지 않는다(F6, F7). 늦게 도착한 이벤트나 재처리가 새 점수를 덮지 못한다. `evict`(탈퇴)는 보호 없이 지운다.
- 결과: F2(부분 실패)와 F3(순서 역전)이 같은 연산으로 사라진다. 왕복은 `move` 기준 2회에서 1회로 준다.

### 2. 실패 처리: DB를 다시 읽는 재시도
- 큐에는 `(seasonId, userId)`만 싣는다. 재처리는 그 시점의 DB 상태(리그, LP, 탈퇴 여부)를 읽어 `place` 또는 `evict`한다. 몇 번을 다시 해도, 순서가 바뀌어도 결과는 DB와 같다.
- 큐 적재도 실패하면(F5) error 로그만 남기고 정기 대조에 맡긴다.

### 4. Redis 데이터 유실 감지와 즉시 재구축
- Redis가 데이터 없이 재시작되면(AOF 손상, 볼륨 유실, FLUSH) `findPage`는 예외 없이 빈 목록을 돌려준다. 그래서 폴백이 동작하지 않고, 앱을 재기동하거나(기동 시 `rebuildIfStale`) 매시 대조가 돌 때까지 빈 랭킹이 보인다.
- 재구축이 끝날 때 준비 표시 키 `league:rank-ready:{seasonId}`를 남기고, 30초마다 이 키가 있는지 `EXISTS`로 확인한다. 없으면 즉시 재구축한다. 데이터를 유지한 채 재시작했다면(AOF 정상) 표시 키도 남아 있으므로 재구축하지 않는다.
- 표시 키 접두어를 `league:rank:`와 다르게 두는 이유: `scanSeasonKeys`의 `league:rank:{seasonId}:*` 패턴에 문자열 키가 섞이면 `countRanked`의 `ZCARD`가 WRONGTYPE으로 실패한다.

### 3. 정기 대조: 전체 비교 + 리그별 인원 확인
- `user_league`를 PK 순서로 1,000건씩 읽고, 같은 묶음의 Redis 점수를 `ZMSCORE`로 한 번에 받아 비교한다. 다르면 2번과 같은 방식으로 맞춘다.
- 스캔 중 리그별 기대 인원을 세어 두었다가 마지막에 `ZCARD`와 비교한다. 다르면 DB에 없는 유저가 Redis에 남은 것이므로 그 리그 키를 임시 키에 다시 만들어 `RENAME`으로 바꿔 끼운다.
- 최근 변경분만 보는 방식은 F8 때문에 버린다(인덱스를 걸면 쓰기 경로 HOT이 깨지고, 안 걸면 전체 스캔과 같다).
- 매시 30분에 실행하고, 1,000건 묶음 단위로 DB 조회와 Redis 비교를 번갈아 해 한 번에 큰 부하를 만들지 않는다(D1).

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/userLeague/infrastructure/LeagueRankScripts.java` - `place`, `evict` Lua 스크립트 상수(`DefaultRedisScript`, `RedisMailAuthCodeConstants` 선례)
- `src/main/java/gravit/code/userLeague/service/LeagueRankSyncService.java` - 이벤트 반영, DB 재조회 반영
- `src/main/java/gravit/code/userLeague/service/LeagueRankingReconcileService.java` - 정기 대조
- `src/main/java/gravit/code/userLeague/scheduler/LeagueRankingReconcileScheduler.java` - 정기 대조 실행
- `src/main/java/gravit/code/userLeague/infrastructure/LeagueRankSyncRetryTarget.java` - 재시도 대상
- `src/main/java/gravit/code/userLeague/scheduler/LeagueRankingLossDetectScheduler.java` - 30초마다 준비 표시 키를 확인하고 없으면 재구축
- `src/main/java/gravit/code/userLeague/dto/internal/LeagueRankStateDto.java` - `(userLeagueId, userId, leagueId, leaguePoint, active)`
- `src/main/java/gravit/code/userLeague/dto/internal/LeagueRankReconcileResultDto.java` - 대조 결과 집계(`scanned`, `placed`, `evicted`, `rebuiltLeagues`, `elapsedMs`)
- `src/test/java/gravit/code/userLeague/service/LeagueRankSyncServiceIntegrationTest.java`
- `src/test/java/gravit/code/userLeague/service/LeagueRankingReconcileServiceIntegrationTest.java`

### 수정 파일
- `src/main/java/gravit/code/userLeague/service/port/LeagueRankingStore.java` - `move` 제거, `place`, `evict`, `findLeaguePoints`, `countRanked(seasonId, leagueId)`, `replaceLeague`, `markReady`, `isReady` 추가
- `src/main/java/gravit/code/userLeague/infrastructure/RedisLeagueRankingStore.java` - 위 메서드 구현, `deleteSeason`이 준비 표시 키도 지우게 수정
- `src/main/java/gravit/code/userLeague/service/LeagueRankingRebuildService.java` - 재구축 완료와 인원 일치 확인 시 준비 표시, `rebuildIfLost(seasonId)` 추가
- `src/main/java/gravit/code/userLeague/listener/LeagueRankSyncListener.java` - `LeagueRankSyncService`에 위임, 실패 시 재시도 큐 적재
- `src/main/java/gravit/code/userLeague/repository/UserLeagueRepository.java` - 상태 조회 3개 추가
- `src/main/java/gravit/code/league/repository/LeagueRepository.java` - `findAllIds()` 추가
- `src/main/java/gravit/code/global/config/SchedulingConfig.java` - `retrySweepScheduler` 스레드 2 → 4 (#608 이후, 랭킹 대조와 유실 감지 두 작업 추가분)
- `src/test/java/gravit/code/userLeague/listener/LeagueRankSyncListenerIntegrationTest.java` - 실패 시 큐 적재 검증으로 갱신
- `src/test/java/gravit/code/userLeague/infrastructure/RedisLeagueRankingStoreIntegrationTest.java` - `move` 테스트를 `place`, `evict`로 교체
- `.claude/spec/service-policy/league-season.md` - 정책 추가: 시즌 중 리그 점수는 줄지 않는다, 랭킹 목록 반영이 실패하면 재시도와 정기 대조로 맞춰진다

## 구현 계획

### STEP 1. 원자 반영 연산 (Infrastructure / Port)
**`LeagueRankScripts`** (`@UtilityClass`)
- `PLACE_SCRIPT` (`DefaultRedisScript<Long>`)
  ```lua
  -- KEYS: 시즌의 리그 키 전부, ARGV[1]: member, ARGV[2]: 목표 키 인덱스(1부터), ARGV[3]: score
  local score = tonumber(ARGV[3])
  for _, key in ipairs(KEYS) do
    local existing = redis.call('ZSCORE', key, ARGV[1])
    if existing and tonumber(existing) > score then return 0 end
  end
  local target = tonumber(ARGV[2])
  for i, key in ipairs(KEYS) do
    if i ~= target then redis.call('ZREM', key, ARGV[1]) end
  end
  redis.call('ZADD', KEYS[target], ARGV[3], ARGV[1])
  return 1
  ```
- `EVICT_SCRIPT` (`DefaultRedisScript<Long>`): `KEYS` 전부에서 `ZREM` 후 지운 개수 반환
- score 인자는 `String.valueOf((long) LeagueRankScore.encode(lp, userId))`로 넘긴다. double 문자열의 지수 표기를 피하기 위해서다(최대 약 3×10¹², 2⁵³ 미만이라 long 변환에 손실이 없다).
- 반환값 `0`(더 새 점수가 있어 건너뜀)은 debug 로그만 남긴다.

**`LeagueRankingStore` 포트 변경**
```java
boolean place(long seasonId, Collection<Long> leagueIds, long leagueId, long userId, int leaguePoint);
void evict(long seasonId, Collection<Long> leagueIds, long userId);
Map<Long, Integer> findLeaguePoints(long seasonId, long leagueId, List<Long> userIds);   // ZMSCORE, 없는 유저는 키 없음
long countRanked(long seasonId, long leagueId);                                          // ZCARD
void replaceLeague(long seasonId, long leagueId, List<LeagueRankEntryDto> entries);      // 임시 키 적재 후 RENAME
```
- `move`는 지운다(호출처는 리스너와 스토어 테스트뿐). `put`, `remove`는 QA 픽스처(`QaFixtureReloader`)와 테스트 준비에서 쓰므로 유지한다.
- `findLeaguePoints`는 `opsForZSet().score(key, members...)`(ZMSCORE)로 한 번에 받고 `LeagueRankScore.toLeaguePoint`로 되돌린다.
- `replaceLeague`: 임시 키 `league:rank:{seasonId}:{leagueId}:rebuild`에 기존 `addInBatches`로 적재하고 `RENAME`한다. 대상이 0명이면 `UNLINK`만 한다. 적재와 `RENAME` 사이의 실시간 반영은 덮일 수 있지만 다음 대조에서 다시 맞춰진다(한계로 기록).

### STEP 2. 반영 서비스 (Repository / Service)
**Repository**
- `LeagueRepository.findAllIds()`
  ```java
  @Query("""
          SELECT l.id
          FROM League l
          ORDER BY l.sortOrder
  """)
  List<Long> findAllIds();
  ```
- `UserLeagueRepository.findRankStateByUserId(long userId)` → `Optional<LeagueRankStateDto>`
  ```java
  @Query("""
          SELECT new gravit.code.userLeague.dto.internal.LeagueRankStateDto(
                     ul.id, u.id, ul.season.id, ul.league.id, ul.lp,
                     CASE WHEN u.deletedAt IS NULL THEN true ELSE false END)
          FROM UserLeague ul
          JOIN ul.user u
          WHERE u.id = :userId
  """)
  ```
  - `LeagueRankStateDto`에는 `seasonId`도 넣는다. 재처리 시점에 시즌이 바뀌었는지 판정하기 위해서다.

**Service**: `LeagueRankSyncService` (`UserLeagueRepository`, `LeagueRepository`, `LeagueRankingStore`)
- `private volatile List<Long> leagueIds` - 처음 쓸 때 `findAllIds()`로 한 번 읽어 둔다. 리그는 15개 고정 데이터라 매 반영마다 조회하지 않는다.
- `public void apply(LeagueRankChangedEvent event)` - 이벤트 값으로 반영 (정상 경로, DB 조회 없음)
  - `removed` → `evict(seasonId, leagueIds, userId)`
  - 그 외 → `place(seasonId, leagueIds, newLeagueId, userId, leaguePoint)`. `joined`, `pointsChanged`의 구분, 이전 리그 정보는 더 이상 쓰지 않는다(전 리그 키에서 지우므로).
- `@Transactional(readOnly = true) public void syncFromDatabase(long seasonId, long userId)` - DB 상태로 반영 (재처리, 대조)
  1. `findRankStateByUserId(userId)`
  2. 없거나 `state.seasonId() != seasonId` → `evict(seasonId, ...)` 후 반환. 롤오버 뒤의 지난 시즌 재처리는 지난 시즌 키를 정리하는 것으로 끝난다(지난 시즌 키는 롤오버 때 삭제되므로 대부분 no-op).
  3. `!state.active()` → `evict`
  4. 그 외 → `place(seasonId, leagueIds, state.leagueId(), userId, state.leaguePoint())`
  - Redis 예외는 잡지 않고 던진다(재시도 대상이 실패로 판정하게).

### STEP 3. 실패 시 재시도 (Listener / RetryTarget)
**`LeagueRankSyncRetryTarget`** (`infrastructure/`)
- `QUEUE_KEY = "league-rank-sync-retry"`, `FIELD_SEASON_ID = "seasonId"`, `FIELD_USER_ID = "userId"`, `MAX_ATTEMPTS = 10`
- `reprocess(fields)` → `leagueRankSyncService.syncFromDatabase(seasonId, userId)`
- `LEAGUE_RANK_USER_ID_OUT_OF_RANGE`는 재시도해도 같은 결과라 error 로그 후 종료한다(`LeaguePointRetryTarget`의 재시도 불가 패턴).

**`LeagueRankSyncListener`** (`LeagueRankSyncService`, `RetryEventPublisher`)
```java
@TransactionalEventListener(phase = AFTER_COMMIT)
public void handleLeagueRankChanged(LeagueRankChangedEvent event) {
    try {
        leagueRankSyncService.apply(event);
    } catch (Exception e) {
        queueRankSyncRetry(event, e);
    }
}

private void queueRankSyncRetry(LeagueRankChangedEvent event, Exception cause) {
    log.error("랭킹 반영 실패, 재시도 큐 적재: userId={}, seasonId={}", ..., cause);
    try {
        retryEventPublisher.publish(LeagueRankSyncRetryTarget.QUEUE_KEY, Map.of(FIELD_SEASON_ID, ..., FIELD_USER_ID, ...));
    } catch (Exception e) {
        log.error("랭킹 반영 재시도 적재 실패, 정기 대조로 복구 대상: userId={}, seasonId={}", ..., e);
    }
}
```
- 기존 `public void apply(event)`는 서비스로 옮기고 리스너에서는 지운다.

### STEP 4. 정기 대조 (Repository / Service / Scheduler)
**Repository**
- `UserLeagueRepository.findRankStatesAfterId(long seasonId, long lastUserLeagueId, Pageable pageable)` → `List<LeagueRankStateDto>`
  ```java
  @Query("""
          SELECT new gravit.code.userLeague.dto.internal.LeagueRankStateDto(
                     ul.id, u.id, ul.season.id, ul.league.id, ul.lp,
                     CASE WHEN u.deletedAt IS NULL THEN true ELSE false END)
          FROM UserLeague ul
          JOIN ul.user u
          WHERE ul.season.id = :seasonId AND ul.id > :lastUserLeagueId
          ORDER BY ul.id
  """)
  ```
  - PK 범위 스캔이라 새 인덱스가 필요 없다(F8의 HOT 유지).
- `UserLeagueRepository.findRankEntriesBySeasonIdAndLeagueId(long seasonId, long leagueId)` → 리그 재구축용. 기존 `findRankEntriesBySeasonId`에 `ul.league.id = :leagueId` 조건을 더한 형태

**Service**: `LeagueRankingReconcileService` (`LeagueRankSyncService`, `UserLeagueRepository`, `SeasonRepository`, `LeagueRankingStore`, `Clock`)
- 상수: `CHUNK_SIZE = 1_000`
- `public LeagueRankReconcileResultDto reconcileActiveSeason()` - 활성 시즌이 없으면 빈 결과
- `public LeagueRankReconcileResultDto reconcile(long seasonId)` (트랜잭션 없음, 묶음마다 짧은 조회)
  1. `lastId = 0`, 리그별 기대 인원 `Map<Long, Long> leagueIdToExpectedCount`
  2. 반복: `findRankStatesAfterId(seasonId, lastId, PageRequest.of(0, CHUNK_SIZE))`, 비면 종료
     - `active` 행을 리그별로 묶어 `findLeaguePoints(seasonId, leagueId, userIds)`
       - Redis 값이 없거나 DB LP와 다르면 `leagueRankSyncService.syncFromDatabase(seasonId, userId)` → `placed++`
       - 기대 인원 누적
     - `!active` 행은 해당 리그 `findLeaguePoints`에 값이 있으면 `syncFromDatabase` → `evicted++`
     - `lastId = 마지막 행 userLeagueId`
  3. 리그마다 `countRanked(seasonId, leagueId)`와 기대 인원 비교. 다르면 `replaceLeague(seasonId, leagueId, findRankEntriesBySeasonIdAndLeagueId(...))` → `rebuiltLeagues++`
  4. 결과 로그: 어긋남이 0이면 info, 하나라도 있으면 warn(누락 발생 감시용)
- 비교와 수정 사이에 실시간 반영이 끼어도, 수정은 DB를 다시 읽고 `place`의 순서 보호를 거치므로 새 점수를 덮지 않는다.

**Scheduler**: `LeagueRankingReconcileScheduler`
- `@Scheduled(cron = "0 30 * * * *", zone = "Asia/Seoul", scheduler = "retrySweepScheduler")` → `reconcileActiveSeason()`
- 시즌 롤오버(자정)와 겹치지 않는 시각으로 둔다. 롤오버 중 대조는 `reconcileActiveSeason`이 그 순간의 활성 시즌을 읽으므로 정합성 문제는 없지만, 재구축과 부하가 겹치지 않게 하기 위해서다.

### STEP 5. Redis 데이터 유실 감지 (Port / Service / Scheduler)
**Port, Store**
- `void markReady(long seasonId)` → `SET league:rank-ready:{seasonId} 1`
- `boolean isReady(long seasonId)` → `EXISTS league:rank-ready:{seasonId}`
- `deleteSeason(seasonId)`는 시즌 리그 키와 함께 준비 표시 키도 `UNLINK`한다(롤오버 뒤 지난 시즌 표시가 남지 않게)
- 상수: `READY_KEY_PREFIX = "league:rank-ready:"`

**Service**: `LeagueRankingRebuildService`
- `rebuild(seasonId)`: `replaceAll` 다음에 `markReady(seasonId)`
- `rebuildIfStale(seasonId)`: 인원이 일치해 재구축을 건너뛸 때도 `markReady(seasonId)`. 배포 직후 기존 운영 데이터에는 표시 키가 없는데, 기동 시 인원이 맞으면 여기서 표시가 생겨 불필요한 재구축 1회를 피한다
- `public boolean rebuildIfLost(long seasonId)` - `isReady`면 false, 아니면 warn 로그 "랭킹 준비 표시가 없어 재구축(Redis 데이터 유실 추정)" 후 `rebuild`, true

**Scheduler**: `LeagueRankingLossDetectScheduler`
- `@Scheduled(fixedDelay = 30_000, initialDelay = 30_000, scheduler = "retrySweepScheduler")`
- 활성 시즌을 읽어 `rebuildIfLost(seasonId)`. Redis 예외는 잡아 warn 로그만 남긴다(Redis가 아직 죽어 있는 동안 30초마다 error가 쌓이지 않게)
- 비용: 정상일 때 30초마다 `EXISTS` 1회와 활성 시즌 조회 1회. 재구축은 100만 명 기준 2.17초(10월 `R-B-1m-after-run2`)

### STEP 6. 정책 문서
- `league-season.md`
  - "시즌 중 리그 점수는 줄지 않는다. 점수가 내려가는 것은 시즌이 바뀔 때의 소프트 리셋뿐이다" (순서 보호가 이 규칙에 기댄다. 점수 차감 기능이 생기면 순서 보호를 다시 설계해야 한다)
  - "리그 점수 변경은 랭킹 목록에 즉시 반영된다. 반영이 실패하면 재시도로 다시 반영하고, 재시도까지 실패하면 매시 30분 정기 대조에서 맞춘다"

### Facade / DTO / Controller
- Facade: 불필요. 반영과 대조 모두 userLeague 도메인 안이고, 다른 도메인은 Repository 조회(`LeagueRepository`, `SeasonRepository`)뿐이다(`UserLeaguePointService`의 `LeagueRepository` 선례).
- DTO: `LeagueRankStateDto(long userLeagueId, long userId, long seasonId, long leagueId, int leaguePoint, boolean active)` (JPQL 생성자 대상이라 표준 생성자), `LeagueRankReconcileResultDto`
- Controller: 변경 없음

## 결정 필요 (Decisions needed)
- [x] D1. 정기 대조 주기 - **매시 30분, `CHUNK_SIZE`(1,000건) 단위로 끊어서 점진 처리**. Redis 장애 뒤 어긋남이 남는 최대 시간은 1시간 + 1회 대조 소요 시간이다. M6은 주기 판정용이 아니라 1회 비용과 대조 중 조회 p95 영향을 기록하는 용도로 남긴다
- [x] D2. 순서 보호(더 큰 점수가 있으면 건너뜀) - **포함**. 스크립트 안에서 `ZSCORE` 15회가 늘지만 서버 내부 연산이라 왕복은 늘지 않는다. 시즌 중 LP 비감소 규칙을 정책에 명시한다
- [x] D3. Redis 장애 중 실패 유저의 앱 메모리 보관 - **하지 않음**. 복구는 매시 대조가 맡고, 충분한지는 M2로 확인한다

## 검증
### 대상 테스트
- `RedisLeagueRankingStoreIntegrationTest`
  - `place`는 다른 리그 키에 있던 같은 유저를 지우고 목표 리그에만 넣는다
  - `place`는 더 큰 점수가 어느 리그에든 있으면 아무것도 바꾸지 않고 false를 반환한다
  - `evict`는 시즌의 모든 리그 키에서 지운다
  - `findLeaguePoints`는 없는 유저를 결과에서 뺀다
  - `replaceLeague`는 기존 멤버를 대상 목록으로 통째로 바꾼다. 대상이 0명이면 키가 사라진다
- `LeagueRankSyncServiceIntegrationTest`
  - 점수 120 반영 뒤 늦게 온 점수 100 이벤트는 무시된다
  - `syncFromDatabase`는 DB의 현재 리그, LP로 반영하고, 탈퇴 유저는 제외하고, 시즌이 바뀌었으면 지난 시즌 키에서만 정리한다
- `LeagueRankSyncListenerIntegrationTest`
  - 반영이 실패하면 `league-rank-sync-retry`에 `seasonId`, `userId`가 적재된다
  - 큐 적재까지 실패해도 예외를 전파하지 않는다
- `LeagueRankingRebuildServiceIntegrationTest`
  - 재구축 뒤, 그리고 인원이 일치해 건너뛸 때 준비 표시가 생긴다
  - 준비 표시가 없으면 `rebuildIfLost`가 재구축하고, 있으면 아무것도 하지 않는다
  - 시즌 삭제 시 준비 표시도 지워진다
- `LeagueRankingReconcileServiceIntegrationTest`
  - 점수가 틀린 유저, Redis에 없는 유저, 다른 리그에 있는 유저를 DB 기준으로 고친다
  - 탈퇴 유저가 남아 있으면 지운다
  - DB에 없는 유저가 Redis 리그 키에 있으면 그 리그를 재구축한다
  - 어긋남이 없으면 아무것도 쓰지 않는다(쓰기 호출 0회, `@MockitoSpyBean`으로 확인)

### 측정 계획 (이력서 수치용)
기록 위치는 `.claude/resources/perf/609/`이고, 숫자는 측정 대장에 ID와 로그를 함께 올린 것만 쓴다. 성능 항목(M5, M6)은 10월 재측정 조건(합성 시드 100만, 로컬 docker, 앱 HTTP 8클라이언트, ABBA 5회 중앙값)을 따른다.

| ID | 무엇을 | 방법 | 전 | 후 목표 |
|---|---|---|---|---|
| M1 | 일시 실패 뒤 어긋남 | LP 변경 100건마다 랭킹 반영 실패 주입 | 어긋남 100건, 시즌 끝까지 남음 | 0건, 해소까지 걸린 시간(스윕 1~2회 기대) 기록 |
| M2 | Redis 장애 뒤 어긋남 | 제출을 계속 보내면서 Redis 컨테이너 60초 정지 후 재기동 | 장애 중 변경분이 그대로 남음 | 대조 1회 뒤 0건, 해소 시간 = 대조 주기 |
| M3 | 순서 역전 | 같은 유저의 점수 100, 120 이벤트를 120 → 100 순서로 반영 | 최종 100(DB는 120) | 최종 120 |
| M4 | 리그 이동 부분 실패 | 리그가 바뀌는 반영에서 두 번째 명령 실패 주입 | 유저가 랭킹에서 빠짐 | 빠지지 않음(스크립트 단위 원자 실행) |
| M5 | 쓰기 비용 | `V-R-W` 프로토콜로 제출 p95, TPS를 같은 세션에서 ABBA 측정 | 현재 코드 측정값(10월 기준 18.4ms) | 증가 없음 또는 증가분 기록 |
| M6 | 대조 비용 | 100만 명, 어긋남 0건과 1%에서 1회 대조 시간, DB 읽은 페이지, Redis CPU. 대조 중 조회(`V-R-H`) p95 변화 | - | 1회 비용과 조회 영향 기록 (매시 실행이 감당 가능한지 근거) |

| M7 | Redis 데이터 유실 뒤 빈 랭킹 | 앱은 켠 채 Redis를 AOF 없이 재시작(또는 `FLUSHALL`)하고 랭킹 목록이 다시 채워질 때까지 시간 측정 | 앱 재기동 전까지 빈 목록 | 30초 + 재구축 시간 이내 |

- M1, M3, M4는 결정적 장애 주입 테스트라 1회로 충분하다. 실행 스크립트를 남긴다.

## Deviation Log
- `RedisLeagueRankingStore.place`: 목표 리그 키가 넘겨받은 리그 목록에 없어도 키 목록에 더한다 — 이유: 스크립트에 목표 키 위치를 넘겨야 하는데, 목록에 없으면 위치를 정할 수 없다
- `LeagueRankSyncService`: 캐시한 리그 목록에 목표 리그가 없으면 DB에서 다시 읽는다 — 이유: 기동 뒤 리그가 추가되면(테스트는 매번 새 id로 만든다) 캐시가 낡아 이전 리그 키를 지우지 못한다. 운영에서는 처음 1회만 읽는다
- `LeagueRankingReconcileService`: `LeagueRepository` 주입 추가 — 이유: 리그별 인원 비교 대상이 전체 리그여야 한다. DB 기대 인원이 0인 리그에 Redis 멤버가 남은 경우도 재구축해야 하기 때문이다
- `LeagueRankingLossDetectScheduler`, `LeagueRankingReconcileScheduler`: 유실 감지를 `fixedDelay` 30초에서 cron `*/30 * * * * *`로 바꾸고, 두 cron을 `scheduler.league-ranking.loss-detect-cron`, `scheduler.league-ranking.reconcile-cron` 속성으로 뺐다. 테스트 프로필(`application-test.yml`)은 `"-"`로 끈다 — 이유: 테스트 컨텍스트에서도 스케줄이 돌아, 활성 시즌을 만든 다른 테스트의 Redis 랭킹을 도중에 재구축할 수 있다. 시즌 롤오버 cron(`scheduler.season.rollover-cron`) 선례를 따랐다
- `LeagueRankReconcileResultDto`: `empty()`(활성 시즌 없음), `hasMismatch()`(로그 수준 판정) 추가, `LeagueRankScripts`: 성공 반환값 `PLACED` 상수 추가 — 이유: 호출부에서 0, 1과 합산식을 직접 쓰지 않기 위해
- 기존 테스트: `RedisLeagueRankingStoreIntegrationTest`의 `move` 두 시나리오를 같은 내용의 `place` 시나리오로 바꿨고, `LeagueRankSyncListenerIntegrationTest`는 리그를 픽스처로 만들게 바꿨다(반영이 DB의 리그 목록을 읽으므로 가짜 리그 id 10, 20으로는 이전 리그 키를 지우지 못한다). 검증 섹션의 새 시나리오와 신규 테스트 클래스는 `write-test`에서 작성한다
- `LeagueRankSyncService.syncFromDatabase`: 참여 기록이 없거나 시즌이 다를 때 캐시 대신 DB에서 리그 목록을 다시 읽어 제외한다 — 이유: 캐시가 낡으면 유저가 있는 리그 키를 빠뜨린다(테스트에서 재현). 재시도와 대조에서만 타는 경로라 비용이 작다
- `LeagueRankStateDto`, `UserLeagueRepository`, `LeagueRankSyncService`, `LeagueRankingReconcileService`, `LeagueRankReconcileResultDto`: `active` 필드와 비활성 분기, `evicted` 집계를 뺐다(#624) — 이유: `User`의 `@SQLRestriction("deleted_at IS NULL")` 때문에 `JOIN ul.user u` 조회가 탈퇴 유저를 반환하지 않아 `active`가 항상 참이고 분기가 실행되지 않는다. 탈퇴 유저는 `syncFromDatabase`에서 참여 기록 없음으로 잡혀 `evict`되고, 정기 대조에서는 리그 인원 비교에서 어긋나 `replaceLeague`로 빠진다. 대조에서 남은 탈퇴 유저 한 명이 리그 하나 재구축으로 이어지지만, 탈퇴 반영과 재시도 큐 적재가 모두 실패한 경우(Redis 장애)에만 생긴다
