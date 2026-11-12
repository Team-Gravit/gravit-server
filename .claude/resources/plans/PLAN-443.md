# [PLAN-443] 리그 랭킹 조회 인덱스, 쿼리 성능 개선

> 이슈: #443
> 브랜치: refactor/443-league-ranking

## 목표

리그 랭킹 조회 4개 경로가 매 요청마다 티어 파티션 전체(또는 시즌 전체)를 훑는 구조를 걷어낸다.
순위 계산을 Redis Sorted Set으로 옮긴다. 인덱스 재구성은 완료됐고, 남은 것은 Redis 이관이다.

이 계획서는 **STEP 1~6으로 나눠 각 단계를 리뷰 가능한 크기로** 재작성한 버전이다.

### 왜 단계를 나누는가

첫 시도는 26개 파일을 한 번에 구현했고, 그 결과 기존 테스트 8개가 깨진 채로 남아 리뷰가
불가능했다. 무엇이 어떤 변경 때문에 깨졌는지 분리되지 않았다. 그 구현은 폐기하고 다시 쌓는다.

단계를 자르는 기준은 **"기능이 먼저, 장애 대응은 나중"**이다.
STEP 1~3은 Redis에 데이터를 쌓기만 하고 읽지 않으므로 사용자 영향이 0이다.
STEP 4~5가 읽기 경로를 Redis로 바꿔 기능을 완성하고, **폴백과 재시도는 STEP 6으로 모았다.**

앞선 설계는 폴백을 STEP 4~5에 섞어 두었는데, 그러면 한 단계에서
"어디서 읽는지"와 "실패하면 어디로 빠지는지"를 동시에 봐야 해서 리뷰가 어려워진다.

### 배포 전제

**STEP 6까지 완료한 뒤 한 번에 배포한다.** 개발은 단계별로 하되 배포는 묶는다.

폴백이 STEP 6에 있으므로 STEP 5까지만 배포하면 Redis 장애 시 랭킹 API가 500이 된다.
STEP 0에서 `ix_ul_league_rank`를 이미 제거해 예전 쿼리로 돌아갈 길도 없다.
단계 분할의 목적은 리뷰 가능성이므로 배포를 묶어도 목적은 지켜진다.

**현재 진행 상태**: STEP 1~5와 STEP 6-1, 6-2 완료. **남은 것은 6-3 재시도 큐뿐이다.**
위 문단이 걱정한 "폴백 없이 배포"는 해소됐다. 자세한 내용은 Deviation Log의 "STEP 6 (마무리)" 참조.

### 측정 근거 (측정 1~4단계 완료)

측정 상세는 `benchmark/league-ranking/RESULTS.md`, 설계는 `docs/league-ranking-benchmark-plan.md`.
아래는 유저 100만 규모 실측값이다.

| 관측 | 결과 |
|---|---|
| 페이지 번호와 비용의 관계 | **무관.** 1페이지와 500페이지가 51,146페이지로 동일 |
| 비용과 파티션 크기 | **정확히 선형** (유저 10배 → 9.94~10.14배) |
| `ix_ul_user_id` 부재 | 쓰기 최대 TPS **315 → 32,100 (102배)**, p95 165.9 → 1.31 ms |
| `ix_ul_league_rank`의 조회 기여 | R1, R2 **기여 없음**(51,146 → 51,106), R4 **93배 악화**, R3 상위권에만 기여 |
| `league_point`를 인덱스에 두는 비용 | HOT **0%**, WAL 787.5 B/건, 인덱스 증가 49.0 B/건 |
| 인덱스 제거 후 | HOT **95.46%**, WAL 355.5 B/건, 인덱스 증가 **0.0 B/건**, dead tuple 17배 감소 |
| 동시 부하 (읽기 8 + 쓰기 8) | 조회 11.1 → **9,493 TPS**, p95 1,086 → **1.55 ms** / 적립 130.5 → **2,736 TPS** |
| 인덱스만 추가했을 때 | 조회 p95 1,086 → **800.9 ms** - **읽기는 인덱스로 안 고쳐진다** |
| Redis 순위 정확성 | 동점 11명 전원 케이스, `ZREVRANK` 3지점, 깊은 페이지 경계 **SQL과 완전 일치** |

위 표는 **프로토타입 측정**이다(애플리케이션 계층 없음). 구현 완료 후 HTTP로 다시 잰 값은 아래다.
프로토타입 수치를 배포 후 기대값으로 쓰면 안 된다 — 절대값이 3.9배 다르다.

| 관측 (HTTP end-to-end, 유저 100만, c=8) | 결과 |
|---|---|
| 개선 전(현재 배포 상태) | 23.4 TPS, p95 **737.5 ms** |
| 개선 후 | **2,449.5 TPS**, p95 **4.13 ms** — TPS 104.7배, p95 178.6배 |
| 경로별 p95 개선 | R1 134배 / R2 123배 / R3 106배 / R4 175배 |
| 인덱스만 추가했을 때(HTTP) | R1~R3 p95 차이 없음 — **읽기는 인덱스로 안 고쳐진다** 재확인 |
| Redis 몫 | `ZREVRANGE` 12.20 µs, `ZREVRANK` 6.65 µs, 메모리 86.99 MB |
| 기동 시 백필 | 1.77초 (`replaceAll` 배치화 이후) |

`/ranking/me`(R3)가 랭킹 화면 최초 노출 API라 호출이 가장 많고, 이 경로는
"나보다 위인 사람 수 세기"가 O(내 등수)라 **쿼리 재작성으로는 못 고친다.** Redis를 택한 결정적 근거다.

### 완료된 것 (STEP 0)

인덱스 재구성은 이미 머지됐다. 이 계획서의 남은 범위에 마이그레이션은 없다.

| 항목 | 상태 |
|---|---|
| `V35__add_user_league_user_id_index.sql` (`ix_ul_user_id` 추가) | PR #478 머지, #479로 버전 정정 |
| `V36__drop_user_league_rank_index.sql` (`ix_ul_league_rank` 제거) | 동일 |

인덱스 제거가 이미 반영됐으므로 **`/ranking/me` 상위권 경로는 지금 느린 상태다.**
STEP 4가 그 손실을 회수한다. STEP 4의 우선순위가 높은 이유다.

## 영향 범위

### 신규 파일

| STEP | 경로 | 역할 |
|---|---|---|
| 1 | `userLeague/service/port/LeagueRankingStore.java` | 랭킹 저장소 포트 |
| 1 | `userLeague/infrastructure/RedisLeagueRankingStore.java` | Sorted Set 구현체 |
| 1 | `userLeague/infrastructure/LeagueRankScore.java` | 점수 인코딩, 복호 값 객체 (결정 4) |
| 1 | `userLeague/dto/internal/LeagueRankEntry.java` | 저장소가 돌려주는 (순위, userId, lp, leagueId) |
| 2 | `userLeague/service/LeagueRankingRebuildService.java` | 시즌 전체 재구축 |
| 2 | `userLeague/infrastructure/LeagueRankingWarmupRunner.java` | 기동 시 백필 |
| ~~2~~ | ~~`userLeague/repository/sql/LeagueRankProfileQuerySql.java`~~ | 만들지 않음. JPQL로 대체 (Deviation Log 참조) |
| 3 | `global/event/LeagueRankChangedEvent.java` | 랭킹 반영 이벤트 |
| 3 | `userLeague/listener/LeagueRankSyncListener.java` | 커밋 후 Redis 반영 |
| 4 | `userLeague/dto/internal/MyLeagueProfileDto.java` | 순위 없는 내 리그 정보 |
| 5 | `userLeague/dto/internal/LeagueRankProfileDto.java` | 프로필 배치 조회 결과 |
| 6 | `userLeague/support/LeagueRankFinder.java` | 폴백 전환 지점 (결정 13). 순위·페이지 조회를 감싼다 |
| 6 | `userLeague/repository/sql/LeagueRankQuerySql.java` | 폴백 전용 SQL (단건 순위, 순위 페이지) |
| 6 | `userLeague/repository/custom/LeagueRankQueryRepository.java` / `Impl` | 위 SQL 실행 |
| 6 | `userLeague/infrastructure/LeagueRankSyncRetryTarget.java` | 반영 실패 재시도. **미구현** |

### 수정 파일

| STEP | 경로 | 변경 |
|---|---|---|
| 1 | `global/config/RedisConfig.java` | 랭킹 전용 커넥션 분리 (커맨드 타임아웃 100 ms), 기존 빈에 `@Primary` |
| 2 | `userLeague/repository/UserLeagueRepository.java` | `findRankEntriesBySeasonId` 추가 (JPQL 생성자 프로젝션) |
| 3 | `userLeague/service/UserLeaguePointService.java` | LP 변경 후 이벤트 발행 |
| 3 | `userLeague/service/UserLeagueService.java` | `initUserLeague`에서 이벤트 발행 |
| 3 | `user/service/UserDeletionService.java` | 탈퇴 시 랭킹에서 제거 |
| 3 | `user/service/UserService.java` | 복구 시 랭킹에 재등록 |
| 3 | `season/batch/SeasonBatchService.java` | 롤오버 후 전체 재구축, 이전 시즌 키 정리 (결정 3) |
| 4 | `userLeague/repository/custom/MyLeagueProfileQueryRepository.java` / `Impl` | `findLeagueProfile` 추가 |
| 4 | `userLeague/service/UserLeagueQueryService.java` | `getMyLeagueRankWithProfile` 전환 |
| 4 | `userLeagueHistory/service/LeagueHistoryService.java` | 현재 순위를 저장소에서 조회 |
| 4 | `.claude/spec/service-policy/league-season.md` | **정책 변경**: 동점 기준, 탈퇴 유저 취급 |
| 5 | `userLeague/repository/custom/LeagueRankingQueryRepository.java` / `Impl` | `findProfilesByUserIds` 추가 |
| 5 | `userLeague/service/UserLeagueQueryService.java` | 목록 2개 경로 전환 |
| ~~6~~ | ~~`userLeague/repository/sql/LeagueRankingPagingQuerySql.java`~~ | 폴백 전용 표기가 아니라 **삭제** (Deviation Log 참조) |
| ~~6~~ | ~~`userLeague/repository/sql/MyLeagueRankWithProfileQuerySql.java`~~ | 동일하게 **삭제** |
| ~~6~~ | ~~`userLeague/repository/custom/LeagueRankingQueryRepository.java` / `Impl`~~ | 개명이 아니라 **삭제** |
| 6 | `userLeague/repository/UserLeagueRepository.java` | `findCurrentRankByUserId` **삭제** (결정 9 폐기) |
| 6 | `userLeague/service/UserLeagueQueryService.java` | 목록 2경로를 `LeagueRankFinder` 경유로 전환, `LeagueRankingStore` 직접 의존 제거 |
| 6 | `userLeagueHistory/service/LeagueHistoryService.java` | 폴백 연결 (STEP 4에서 이미 `LeagueRankFinder` 경유) |

## 구현 계획

### STEP 1 - 랭킹 저장소 (아무도 쓰지 않는 상태)

가장 어려운 부분인 **점수 인코딩을 격리해서 먼저 검증한다.** 이 단계가 끝나도 어떤 서비스도
저장소를 호출하지 않으므로 배포 영향이 없다.

**1. DTO**: `LeagueRankEntry` - `record (int rank, long userId, int leaguePoint, long leagueId)`

**2. 값 객체**: `LeagueRankScore`

```java
public static double encode(int leaguePoint, long userId)   // leaguePoint * BASE + (BASE - userId)
public static int toLeaguePoint(double score)
```

Sorted Set은 동점 시 member 사전순으로 정렬하고("100" < "99") 그 순서가 이 서비스의 동점 기준인
`user_id ASC`와 다르다. 그래서 동점 기준을 점수에 인코딩한다. `BASE = 10^9`이고 상한은
`9999 * 10^9 + 10^9`으로 double 정수 정밀도(`2^53`) 안이다. **`userId`가 `[1, 10^9)`를 벗어나면
인코딩이 깨지므로 이 클래스에서 검증한다.** 배경 설명은 코드 주석이 아니라 정책 문서에 남긴다.

**3. 포트**: `LeagueRankingStore` (`userLeague/service/port/`)

```java
void put(long seasonId, long leagueId, long userId, int leaguePoint);
void move(long seasonId, long fromLeagueId, long toLeagueId, long userId, int leaguePoint);
void remove(long seasonId, long leagueId, long userId);
Optional<Integer> findRank(long seasonId, long leagueId, long userId);   // 1-based
List<LeagueRankEntry> findPage(long seasonId, long leagueId, int offset, int limit);
void replaceAll(long seasonId, List<LeagueRankEntry> entries);
void deleteSeason(long seasonId);
boolean hasRanking(long seasonId);
```

**4. 구현체**: `RedisLeagueRankingStore`

- 키 `league:rank:{seasonId}:{leagueId}`, member는 `userId` 문자열
- `findRank`는 `ZREVRANK` 결과에 `+1`
- `findPage`는 `ZREVRANGE offset ~ offset+limit-1`, 순위는 `offset + 1`부터 순차 부여
- `replaceAll`, `deleteSeason`은 `KEYS` 대신 `SCAN`으로 시즌 키만 걷는다 (`KEYS`는 Redis를 블로킹한다)
- `@Qualifier("rankingRedisTemplate")` 주입

**5. 설정**: `RedisConfig`

- `rankingRedisConnectionFactory`, `rankingRedisTemplate` 추가. `commandTimeout`과
  `SocketOptions.connectTimeout` 모두 100 ms
- 기존 `redisConnectionFactory`, `redisTemplate`에 `@Primary` (기존 사용처 영향 차단)
- 짧은 타임아웃을 STEP 1에 두는 이유: STEP 6의 폴백이 이 설정을 전제한다.
  Lettuce 기본 60초로는 장애 시 폴백이 무의미해진다

**배포 영향**: 없음. 빈만 등록된다.

**가독성 포인트**: 인코딩 로직을 `LeagueRankScore`로 빼면 저장소는 Redis 명령 호출만 남는다.
첫 구현은 이 계산이 저장소의 private static 메서드로 섞여 있어 클래스가 두 가지 일을 했다.

### STEP 2 - DB 기준으로 랭킹 채우기

이제 Redis에 데이터가 쌓이지만 **여전히 아무도 읽지 않는다.**

**1. Repository**: `UserLeagueRepository.findRankEntriesBySeasonId(long seasonId)` → `List<LeagueRankEntry>`

JPQL 생성자 프로젝션으로 리포지토리에 직접 둔다. 순위는 저장소가 점수로 정하므로 `rank`는 `0`이다.

```java
@Query("""
        SELECT new gravit.code.userLeague.dto.internal.LeagueRankEntry(0, u.id, ul.lp, ul.league.id)
        FROM UserLeague ul
        JOIN ul.user u
        WHERE ul.season.id = :seasonId
          AND u.deletedAt IS NULL
        """)
```

`u.deletedAt IS NULL`은 `User`의 `@SQLRestriction`과 중복이지만 명시한다. 나중에 조인을
`ul.user.id`로 바꾸면 조인이 사라지면서 애노테이션 필터도 함께 사라진다.

**2. Service**: `LeagueRankingRebuildService`

```java
@Transactional(readOnly = true) public int rebuild(long seasonId);
@Transactional(readOnly = true) public int rebuildIfAbsent(long seasonId);
```

`rebuildIfAbsent`는 `hasRanking`이면 건너뛴다. 없으면 롤링 배포마다 인스턴스 수만큼
시즌 전체를 다시 읽는다.

**3. Runner**: `LeagueRankingWarmupRunner implements ApplicationRunner`

- ACTIVE 시즌이 없으면 로그만 남기고 종료
- 재구축 실패는 로그만 남기고 삼킨다. **랭킹을 못 채워도 애플리케이션은 떠야 한다**

**배포 영향**: 기동 시 Redis에 키가 생긴다. 읽는 쪽이 없어 사용자 영향 0.
100만 명 기준 구축 1초(실측), 메모리 약 95 MB.

**검증 포인트**: 재구축 결과가 DB와 일치하는지, 두 번째 기동에서 건너뛰는지.

### STEP 3 - 쓰기 동기화

Redis가 실시간으로 최신 상태를 유지하게 한다. **읽기는 아직 DB이므로 사용자 영향은 여전히 0이다.**
이 단계를 읽기 전환보다 먼저 두는 이유는, 읽기를 바꾸는 시점에 이미 데이터가 정확해야 하기 때문이다.

**1. 이벤트**: `LeagueRankChangedEvent`

```java
record LeagueRankChangedEvent(long userId, long seasonId, Long oldLeagueId,
                              long newLeagueId, int leaguePoint, boolean removed)

static joined(userId, seasonId, leagueId, leaguePoint)          // oldLeagueId = null
static pointsChanged(userId, seasonId, oldLeagueId, newLeagueId, leaguePoint)
static removed(userId, seasonId, leagueId)                      // removed = true
```

**2. 리스너**: `LeagueRankSyncListener`

```java
@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
public void handleLeagueRankChanged(LeagueRankChangedEvent event);

public void apply(LeagueRankChangedEvent event);
```

`AFTER_COMMIT`인 이유는 롤백된 변경이 랭킹에 남으면 순위가 DB와 영구히 어긋나기 때문이다.
**실패 시 이 단계에서는 로그만 남기고 예외를 삼킨다.** 이미 커밋된 트랜잭션이라 되돌릴 것이 없고,
여기서 던지면 요청 스레드만 죽는다. 재시도 큐 연결은 STEP 6이다.

`apply`를 `public`으로 두는 것은 STEP 6의 재시도 스윕이 이벤트 재발행 없이 반영 로직만
다시 태우기 위한 것이다.

**3. 발행 지점 4곳** (모두 트랜잭션 안)

| 클래스 | 지점 | 팩토리 |
|---|---|---|
| `UserLeaguePointService.addLeaguePoints` | `updateLeagueIfDifferent` 직후 | `pointsChanged` |
| `UserLeagueService.initUserLeague` | `save` 직후 | `joined` |
| `UserDeletionService.confirmDeleteByMailAuthCode` | 소프트 삭제 직후 | `removed` |
| `UserService.restoreUser` | `restoreUser` 직후 | `joined` |

`UserLeaguePointService`는 승급 여부와 무관하게 LP가 오르면 항상 발행한다.
티어가 안 바뀌면 `move`가 점수만 갱신한다. `oldLeague.getId()`를 엔티티 변경 **전에** 뽑아 둔다.

**4. 시즌 롤오버**: `SeasonBatchService.rollOver`

소프트 리셋 직후, `nextSeason.activate()` 전에 `rebuild(nextSeasonId)` 호출.
전원의 티어와 점수가 한 번에 바뀌므로 증분 반영이 무의미하다.
이어서 `deleteSeason(currentSeasonId)`로 이전 시즌 키를 정리한다 (결정 11).

**배포 영향**: 사용자 영향 0. LP 적립 경로에 Redis `ZADD` 지연 약 0.087 ms가 더해진다.

### STEP 4 - 내 순위 조회 전환 (R3, R4)

**여기서 처음 사용자 동작이 바뀐다.** 단건 조회 2개만 다루므로 STEP 5보다 작고,
STEP 0에서 인덱스를 제거해 지금 가장 느려진 경로가 이것이라 먼저 회수한다.

**1. DTO**: `MyLeagueProfileDto` - `(seasonId, leagueId, leagueName, maxLp, userId, lp, nickname, profileImgNumber, xp, level)`

순위가 빠져 있다. Redis 조회 키(`seasonId`, `leagueId`)를 얻는 것이 주 목적이다.

**2. SQL**: `LeagueRankProfileQuerySql.FIND_MY_LEAGUE_PROFILE_SQL`
`user_league` + `users` + `league` 조인 1행, `ul.user_id = :userId AND u.deleted_at IS NULL`.
`user_league`는 유저당 1행이고 롤오버가 그 행을 UPDATE하므로 시즌 조건이 불필요하다.

**3. Repository**: `Optional<MyLeagueProfileDto> findLeagueProfile(long userId)`

`queryForObject` → `query(...).stream().findFirst()`로 바꿔 0행을 예외가 아닌 `Optional`로 다룬다.
서비스가 `USER_LEAGUE_NOT_FOUND`로 변환한다.

**4. Service**: `UserLeagueQueryService.getMyLeagueRankWithProfile(long userId)`

`findLeagueProfile` → `store.findRank` → 응답 조립. 폴백은 STEP 6에서 붙인다.

**5. Service**: `LeagueHistoryService.buildLeagueHistory`

이미 조회한 `currentUserLeague`를 재사용해 `store.findRank`로 현재 순위를 얻는다.
기존 `findCurrentRankByUserId` 호출을 걷어내되 **메서드는 지우지 않는다.** STEP 6이 이를
폴백으로 재사용한다.

이 전환으로 **순위 불일치 버그가 사라진다.** 기존 쿼리만 동점 기준이 `updated_at ASC` 우선이고
탈퇴 유저를 걸러내지 않아, 같은 유저가 랭킹 목록 1등, 히스토리 218등으로 보였다.

**6. 정책 문서**: `league-season.md`

- "리그 내 순위는 리그 점수 내림차순, 같으면 **먼저 가입한 순서**다"
- 추가: "탈퇴한 유저는 리그 순위에서 빠지고, 복구하면 탈퇴 직전의 티어와 점수로 순위에 다시 들어간다"
- 추가: 점수 인코딩 제약(`userId < 10^9`)

**동작**: `/ranking/me`와 `/league-history`가 Redis 순위를 쓴다.

`findRank`가 비면 순위 `0`을 반환한다(`RANK_UNKNOWN`). 히스토리는 지금도 `orElse(0)`이라
새로운 값이 아니지만, `/ranking/me`에는 새로 생기는 값이다. 도달하는 경우는 워밍업 전,
온보딩 이벤트 유실, 롤오버 재구축 중이다. **프론트에 "0은 순위 미집계"를 전달해야 한다.**

### STEP 5 - 랭킹 목록 조회 전환 (R1, R2)

가장 복잡한 단계다. 프로필 배치 조회, 순서 유지, 페이지 경계가 한꺼번에 걸린다.

**1. DTO**: `LeagueRankProfileDto` - `(userId, nickname, profileImgNumber, xp, level)`

**2. SQL**: `LeagueRankProfileQuerySql.FIND_PROFILES_BY_USER_IDS_SQL`
`WHERE u.id IN (:userIds) AND u.deleted_at IS NULL`

**3. Repository**: `findProfilesByUserIds(List<Long> userIds)` → `List<LeagueRankProfileDto>`.
**빈 목록을 먼저 막는다.** `IN ()`은 문법 오류가 된다.

**4. Service**: `UserLeagueQueryService`

```java
SliceResponse<LeagueRankRowDto> findLeagueRanking(long leagueId, int page);
SliceResponse<LeagueRankRowDto> findLeagueRankingByUser(long userId, int page);
private SliceResponse<LeagueRankRowDto> findRankingPage(long seasonId, long leagueId, int safePage);
private List<LeagueRankRowDto> toRankRows(List<LeagueRankEntry> entries);
```

`findPage(offset = page * 10, limit = 11)`로 조회해 `size() > 10`으로 `hasNextPage`를 판정하고
앞 10개만 쓴다. `toRankRows`는 저장소가 정한 순서를 유지한 채 프로필만 채우고,
프로필이 없는 유저(조회 시점 탈퇴)는 제외한다.

**5. 없을 때의 동작** - 둘 다 예외를 던지지 않고 빈 결과를 준다 (결정 10, 14).

| 상황 | 응답 |
|---|---|
| `findLeagueRanking`에 ACTIVE 시즌이 없다 | `SliceResponse.empty()` |
| `findLeagueRankingByUser` 호출자에게 `user_league` 행이 없다 | `SliceResponse.empty()` |

`seasonRepository.findByStatus`와 `findLeagueProfile`의 `Optional`을 그대로 흘려보내
`map`으로 처리한다. 목록 조회는 "없으면 빈 목록"이 기존 계약이고, 여기서 404를 던지면
프론트 수정이 필요해진다.

**동작**: 목록 조회가 Redis를 쓴다. 조회 p95 800.9 → 1.55 ms(실측)로 가장 큰 이득이 여기서 나온다.

응답의 `LeagueRankRowDto`에 `userId`가 그대로 있으므로 **프론트가 내 row를 강조하는 방식은
바뀌지 않는다.** 강조는 클라이언트가 `userId`로 매칭하는 일이고 이관과 무관하다.

**주의**: `hasNextPage`는 Redis 원소 수로 판정하고 행 제외는 `deleted_at` 필터로 일어난다.
제거 이벤트가 유실된 탈퇴 유저가 페이지에 있으면 그 페이지만 10개 미만이 될 수 있다.
프론트가 "10개가 아니면 마지막 페이지"로 판단하지 않는지 확인이 필요하다.

### STEP 6 - 장애 대응 (폴백, 재시도)

여기까지 오면 기능은 완성된 상태다. 이 단계는 **Redis가 죽었을 때와 반영이 실패했을 때**만 다룬다.
기능 변경이 없어서 리뷰할 때 "정상 경로는 안 건드렸다"만 확인하면 된다.

**1. 폴백 쿼리 정리**

기존 SQL을 지우지 않고 폴백 전용으로 남긴다. 상수명에 `_FALLBACK` 접미사를 붙여
파티션 전체에 랭크를 매기는 축퇴 모드 전용임을 이름으로 드러낸다.

| 대상 | 조치 |
|---|---|
| `LeagueRankingPagingQuerySql` | 상수 2개에 `_FALLBACK` |
| `MyLeagueRankWithProfileQuerySql` | 상수에 `_FALLBACK` |
| `UserLeagueRepository.findCurrentRankByUserId` | `league_point DESC, user_id ASC` + `deleted_at IS NULL`로 기준 통일 (결정 9) |
| `*QueryRepository` / `Impl` | 기존 조회 메서드를 `...Fallback`으로 개명 |

`findCurrentRankByUserId`의 기준 통일이 필요한 이유는, 고치지 않으면 폴백으로 떨어질 때만
히스토리 순위가 다시 어긋나기 때문이다.

**2. 폴백 전환** - `UserLeagueQueryService`, `LeagueHistoryService`의 4개 경로

잡는 예외는 `RedisConnectionFailureException`, `RedisSystemException`, `QueryTimeoutException` 셋.
**전환 코드는 한 곳으로 모은다** (결정 13). 경로마다 `try/catch`를 복사하면 4곳이 된다.

**3. 재시도** - `LeagueRankSyncRetryTarget implements RetrySweepTarget`, `maxAttempts = 10`

`LeagueRankSyncListener`가 STEP 3에서 로그만 남기던 실패를 `RetryEventPublisher`로
`league-rank-sync-retry` 큐에 적재하게 바꾼다. `oldLeagueId`는 `Map`이 null을 못 담아
빈 문자열로 직렬화하고 복원 시 되돌린다.

**동작**: 정상 경로는 변화 없음. Redis 장애 시 500 대신 느린 정상 응답(조회 p95 약 1초)이 된다.

### Facade

**불필요** - 단일 도메인(`userLeague`) 내 Service 조합이다. `LeagueHistoryService`는
`userLeagueHistory` 도메인이지만 포트(`LeagueRankingStore`)에만 의존하므로 도메인 결합이 아니다.

### Controller

**변경 없음.** 3개 엔드포인트의 경로, 시그니처, 응답 필드가 그대로다. 클라이언트 영향 0.

## 결정 사항 (확정됨)

- [x] **1. Redis 장애 시 → DB 폴백.** 기존 윈도우 함수 쿼리를 폴백 전용으로 남긴다
- [x] **2. 리그 히스토리의 현재 순위(R4) → Redis로 이관.** 순위 불일치 버그를 원천 제거한다
- [x] **3. 인덱스 재구성 → 별도 PR로 선행 완료** (#478, #479)
- [x] **4. 시즌 롤오버 → 배치 트랜잭션 내 동기 재구축.** 100만 구축 1초(실측)
- [x] **5. 동점 처리 기준 → `user_id ASC`로 통일하고 정책 문서를 고친다**
- [x] **6. 탈퇴 유저 → 현행 유지(`users` 조인 필터). 스키마와 복구 경로를 건드리지 않는다**
- [x] **7. 랭킹 신선도 → 실시간(지연 허용 0). 스냅샷 배치안 제외**
- [x] **8. 구현을 STEP 1~6으로 분할.** STEP 3까지는 사용자 영향이 없고,
  STEP 4~5가 기능을 완성하며, 장애 대응은 STEP 6에 모은다

## 결정 사항 (계획 단계에서 확정)

- [x] **9. 리그 히스토리(R4)의 Redis 장애 시 → 폴백 유지.**
  `findCurrentRankByUserId`를 동점 기준(`user_id ASC`)과 탈퇴 필터를 맞춰 폴백으로 남긴다.
  4개 조회 경로의 축퇴 동작이 일관되게 유지된다. STEP 6에서 처리한다
- [x] **10. ACTIVE 시즌이 없을 때 리그별 랭킹 조회 → 빈 결과.**
  기존 계약을 유지한다. `findLeagueRanking`이 시즌을 `Optional`로 다루고, 시즌이 없으면
  `SliceResponse.empty()`를 반환한다. 예외를 던지지 않는다
- [x] **11. 지난 시즌 Redis 키 → 롤오버 시 삭제.**
  `SeasonBatchService.rollOver`에서 `rebuild(nextSeasonId)` 이후 `deleteSeason(currentSeasonId)`를 호출한다
- [x] **12. 점수 인코딩 → `LeagueRankScore` 값 객체로 분리.**
  인코딩, 복호, `userId` 상한 검증을 한곳에 모은다. 저장소는 Redis 명령 호출만 남는다
- [x] **13. 폴백 전환 → 공통화.**
  4개 경로에 반복될 `try / catch(3종 예외) / 폴백` 블록을 한 곳으로 모은다. STEP 6에서 정리한다
- [x] **14. 기능 우선, 장애 대응 후순위.**
  폴백과 재시도를 STEP 4~5에서 떼어 STEP 6으로 모은다. 한 단계에서 "어디서 읽는지"와
  "실패하면 어디로 빠지는지"를 같이 보면 리뷰가 어려워진다.
  **배포는 STEP 6 완료 후 한 번에 한다**
- [x] **15. 목록 조회에서 대상이 없으면 빈 결과.**
  ACTIVE 시즌 부재와 `user_league` 행 부재 모두 `SliceResponse.empty()`다. 404를 던지지 않는다.
  단건 조회(`/ranking/me`)만 `USER_LEAGUE_NOT_FOUND`를 쓴다
- [x] **16. read-repair, `hasRanking` 폴백 → 도입하지 않는다(보류).**
  검토했으나 기능 완성이 우선이라 뺐다. 유실 회수는 워밍업과 재시도 큐(STEP 6)에 맡긴다.
  운영에서 유실이 실제로 관측되면 다시 판단한다

## 검증

각 STEP은 **자기 단계의 테스트가 통과한 상태로 끝난다.** 다음 단계로 넘어가기 전에
기존 테스트가 깨진 채로 두지 않는다. 첫 시도가 실패한 지점이 이것이다.

| STEP | 대상 테스트 | 시나리오 |
|---|---|---|
| 1 | `RedisLeagueRankingStoreTest` | 점수 인코딩(동점 시 `user_id ASC`), `findRank` 1-based, `findPage` 순위 유도, `move` 시 옛 리그 제거, `userId` 상한 위반 |
| 2 | `LeagueRankingRebuildServiceTest` | 재구축 결과가 DB와 일치, `rebuildIfAbsent`가 기존 랭킹을 건드리지 않음, 탈퇴 유저 제외 |
| 3 | `LeagueRankSyncListenerTest` | 커밋 후에만 반영, 롤백 시 미반영, 실패 시 예외를 삼키는지 |
| 3 | 통합 | LP 적립 → 반영, 티어 변경 시 옛 리그 제거, 탈퇴 → 제거, 복구 → 재등록, 롤오버 후 재구축 |
| 4 | `UserLeagueQueryServiceIntegrationTest` | `/ranking/me` 순위 일치, 멤버 부재 시 순위 0 |
| 4 | `LeagueHistoryServiceTest` | 현재 순위 |
| 4 | 통합 | **경로 간 순위 일치** (`/ranking/me`와 히스토리가 같은 유저에게 같은 순위) |
| 5 | `UserLeagueQueryServiceIntegrationTest` | 목록 순서 유지, 페이지 경계(9→10, 마지막), 동점 다수 구간, 탈퇴 유저 포함 구간, 대상 부재 시 빈 결과 |
| 6 | `LeagueRankFinderIntegrationTest` | 저장소 예외 시 폴백 전환 (예외 3종) ✅ |
| 6 | `LeagueRankSyncRetryTargetTest` | `oldLeagueId` null 왕복 — 6-3 미구현이라 없음 |
| 6 | `LeagueRankFinderIntegrationTest` | **폴백 정합성** - 저장소를 내린 상태에서 4경로가 `(rank, userId)`까지 일치 ✅ (탈퇴 유저 케이스는 예외, Deviation Log 참조) |

기존 테스트 픽스처는 DB에만 쓰고 Redis에 쓰지 않는다. STEP 4에서 처음 문제가 되므로
그 시점에 픽스처가 `rebuild()`를 호출하도록 고친다(실제 백필 경로를 그대로 태운다).

~~구현체 대상 부하 재측정은 STEP 6 완료 후 `benchmark/league-ranking/run-after.sh`로 수행한다.~~
→ **`run-after.sh`가 애플리케이션을 타지 않아 방식을 바꿨다.** 실제 엔드포인트를 HTTP로
때리는 `run-http.sh`로 개선 전/후를 같은 조건에서 측정했다. Deviation Log의 「측정」 참조.

## 남는 한계 (이 계획서 범위 밖)

- **강제 재구축 트리거가 없다.** 기동 시 백필은 "비어 있을 때만" 동작하므로
  Redis **부분 손상**은 기동만으로 복구되지 않는다. 어드민 엔드포인트가 별도로 필요할 수 있다
- **재시도 10회를 넘긴 항목은 버려진다.** 그 유저의 순위는 다음 롤오버까지 틀어진 채 남는다.
  단 `put`과 `move`는 upsert이므로 LP 적립 유실은 **멤버를 없애지 않고 점수만 옛 값으로 남긴다.**
  멤버가 아예 없어지는 경우는 온보딩(`joined`) 유실뿐이다 (결정 16의 근거)
- ~~**STEP 5까지만 배포하면 Redis 장애 시 랭킹 API가 500이다.**~~ 해소됨. 4개 조회 경로 전부
  `LeagueRankFinder`를 거쳐 저장소 예외를 DB 폴백으로 받는다. **남은 미구현은 6-3 재시도 큐뿐이고,
  이건 500을 만들지 않는다** — 반영 실패가 로그로만 남아 순위가 낡은 채 유지되는 문제다.
  배포 가부는 이 손실을 감수할지의 판단이 된다 (결정 14의 전제는 바뀌었다)
- **Redis 장애 = 사실상 장애.** 폴백은 현행 성능(조회 p95 약 1초, 11~18 TPS)이라 완충이지 이중화가 아니다
- **목록의 LP는 Redis에서, `/ranking/me`의 LP는 DB에서 온다.** 반영이 유실되면 같은 유저의
  LP가 두 화면에서 다르게 보일 수 있다

## Deviation Log

### STEP 1

- `global/exception/domain/CustomErrorCode.java`: `LEAGUE_RANK_USER_ID_OUT_OF_RANGE` 추가 —
  이유: 계획서는 `LeagueRankScore`에서 `userId` 상한을 검증하라고만 했고 예외 수단을 정하지 않았다.
  `common.md`가 `RestApiException(CustomErrorCode.XXX)` 패턴을 요구하므로 에러코드를 신설했다.
  영향 범위에 없던 파일이라 기록한다
- `userLeague/infrastructure/RedisLeagueRankingStore.java`: `deleteSeasonKeys` private 메서드를
  포트의 `deleteSeason`으로 승격 — 이유: 결정 11(롤오버 시 이전 시즌 키 삭제)이 STEP 3에서
  이 동작을 외부에서 호출해야 한다. 계획서 포트 시그니처에 이미 `deleteSeason`이 있어 그대로 따랐고,
  `replaceAll`이 이를 재사용한다
- `LeagueRankScore`: `record`가 아닌 `@UtilityClass` + 정적 메서드로 구현 — 이유: 계획서가 명시한
  시그니처(`static double encode`, `static int toLeaguePoint`)가 정적 유틸 형태다. 인스턴스를
  들고 다닐 이유가 없어 계획 그대로 뒀다

### STEP 2

- `userLeague/repository/sql/LeagueRankProfileQuerySql.java`: **만들지 않고 JPQL로 대체** —
  이유: 계획서는 이 쿼리를 `repository/sql/` 홀더에 두라고 했지만, 컨벤션의 조건은
  "**복잡한** 쿼리"다. 기존 홀더들이 54~160줄(윈도우 함수, 다중 전략 검색)인데 이 쿼리는 6줄이다.
  프로젝트에 이미 `UnitRepository`의 JPQL 생성자 프로젝션 선례가 있어 그쪽을 따랐다.
  결과로 SQL 홀더 파일, 커스텀 리포지토리 메서드, `RowMapper`, `RANK_NOT_ASSIGNED` 상수가 사라졌다
- `userLeague/repository/custom/LeagueRankingQueryRepository.java` / `Impl`: 변경하지 않음 —
  이유: 위 결정으로 `findRankEntriesBySeasonId`가 `UserLeagueRepository`로 옮겨갔다.
  계획서의 "영향 범위 - 수정 파일"에서 이 항목을 교체했다
- `LeagueRankingWarmupRunner` 전용 테스트 미작성 (STEP 2) — 이유: `ApplicationRunner`라 컨텍스트 기동
  시점에만 동작하고, 모든 통합 테스트가 이미 "활성 시즌 없음" 분기를 태우고 있다.
  위임 대상(`rebuildIfAbsent`)은 별도로 검증했다. 대신 관련 도메인 테스트 99건을 함께 돌려
  러너가 기존 컨텍스트를 깨지 않는지 확인했다

### STEP 3

- `userLeague/dto/internal/LeagueRankKey.java` **신규**, `UserLeagueRepository.findRankKeyByUserId` **추가** —
  이유: 탈퇴 시 랭킹 좌표(`seasonId`, `leagueId`)를 얻는 방법이 계획서에 없었고, 엔티티 조회로는
  두 가지가 동시에 막혔다. **(1)** `findByUserId`(엔티티)는 `users`를 조인해 `User`의
  `@SQLRestriction("deleted_at IS NULL")`이 걸리므로 소프트 삭제 **뒤에는** 행을 찾지 못한다.
  **(2)** 삭제 **앞에서** 조회하면 `UserLeague`가 영속성 컨텍스트에 올라가고, 커밋 시점에 이미
  삭제된 `User`를 참조해 `TransientObjectException`이 터진다.
  스칼라 프로젝션(`ul.user.id`는 FK 컬럼이라 조인이 없다)으로 둘 다 회피했다.
  **통합 테스트가 이 결함을 잡았다** — 구현만 보고는 드러나지 않았다
- `UserDeletionService.confirmDeleteByMailAuthCode`: 좌표를 먼저 확보한 뒤 삭제하고 이벤트를 발행하는
  순서로 정리 — 이유: 위 (1)을 피하려면 읽기가 삭제보다 앞서야 한다
- `SeasonBatchService`: 계획서가 지시한 단계 주석을 넣지 않음 — 이유: `common.md`가 메인 코드의
  설명 주석을 금지한다. 기존 파일이 단계별 주석을 쓰고 있으나 STEP 1, 2와 일관되게 맞췄다
- 발행 지점 테스트를 새 클래스가 아니라 기존 서비스 테스트 4곳에 추가 — 이유: 테스트 패키지가
  메인 구조를 미러링하는 컨벤션에 맞고, 발행 지점이 3개 도메인에 걸쳐 있어 한 클래스로 모으면
  소속이 모호해진다

### STEP 4

- `findLeagueProfile`을 `MyLeagueProfileQueryRepository`(네이티브 SQL)가 아니라
  `UserLeagueRepository`의 **JPQL 생성자 프로젝션**으로 구현 — 이유: 계획서가 지시한
  `LeagueRankProfileQuerySql`은 STEP 2에서 제거했고, STEP 2, 3이 이미 랭킹 관련 프로젝션을
  `UserLeagueRepository`에 JPQL로 두는 패턴을 만들었다. 일부만 네이티브로 두면 같은 성격의
  조회가 두 곳에 흩어진다. `User.level`이 `@Embedded`라 `u.level.xp`, `u.level.level`로 접근한다.
  기존 `MyLeagueProfileQueryRepository`는 손대지 않았다(STEP 6이 폴백으로 개명한다)
- `LeagueHistoryService.findCurrentRank` private 메서드 추출 — 이유: `Optional` 두 겹
  (`currentUserLeague`, `findRank`)을 인라인으로 펼치면 `buildLeagueHistory`의 흐름이 끊긴다
- 정책 문서에 항목 2개 추가 — 이유: 계획서는 인코딩 제약만 지시했으나, `rank = 0`(미집계)이
  응답 계약이 되었으므로 함께 명시했다. 동점 기준과 탈퇴 항목은 이미 반영돼 있었다
- 기존 테스트 3건이 깨져 `rebuild()` 호출을 추가 — 계획서가 예고한 지점이다(검증 절).
  픽스처가 DB에만 쓰고 Redis에 쓰지 않아 STEP 4에서 처음 드러났다.
  실제 백필 경로를 그대로 태우는 쪽(계획서 방침)으로 고쳤다

### STEP 6 (일부 선행)

STEP 5보다 먼저 폴백을 붙였다 — 이유: `rank = 0`(미집계) 응답이 STEP 4에서 정상 경로의
퇴행으로 드러났다. 리그에 참여한 유저인데 저장소에만 없으면 이전 구현이 정확히 주던 순위를
0으로 돌려준다. 배포 전제가 "STEP 6까지 완료 후 한 번에"이므로 단계 순서만 바뀌었다.

- 폴백 쿼리를 `_FALLBACK` 개명이 아니라 **랭크 전용 신규 쿼리로 교체** — 이유: 계획서는
  `MyLeagueRankWithProfileQuerySql`을 폴백으로 남기라고 했으나, STEP 4가 프로필을 JPQL
  `findLeagueProfile`로 분리해 폴백에 필요한 것은 순위뿐이 되었다. 프로필까지 다시 읽는 쿼리를
  남기면 조회가 중복된다. `LeagueRankQuerySql.FIND_RANK_IN_LEAGUE_SQL`(순위만)로 바꾸고
  `MyLeagueProfileQueryRepository` / `Impl` / `MyLeagueRankWithProfileQuerySql`은 삭제했다.
  참조가 `UserLeagueRepository`의 `extends` 한 곳뿐이었다
- 결정 9(`findCurrentRankByUserId` 기준 통일)가 **불필요해짐** — 이유: 새 폴백 쿼리가 동점 기준
  (`user_id ASC`)과 탈퇴 필터를 맞춘 채로 R3, R4 공용이다. 해당 메서드는 미사용으로 남았다가
  STEP 6 마무리에서 삭제했다
- 결정 13(전환 코드 한 곳)은 `userLeague/support/LeagueRankFinder`로 구현 — 이유: 두 호출처가
  `userLeague`와 `userLeagueHistory` 두 도메인에 걸쳐 있어 Service로 두면 도메인 간 직접 호출이
  된다. 포트 조회와 DB 폴백을 감싼 `@Component`로 두어 `service.md` 규칙을 지켰다
- 이 시점의 폴백은 `Optional.empty`(멤버 없음)에서만 걸렸다. 예외 기반 폴백(6-2)과 재시도 큐(6-3)는
  아래 "STEP 6 (마무리)"에서 6-2만 처리했다
- `rebuildIfAbsent` → `rebuildIfStale`로 판정 기준 교체 — 이유: `hasRanking`이 "시즌 키가 하나라도
  있는가"만 봐서 부분 유실(일부 리그 키 소실, 멤버 누락, 탈퇴 반영 실패)을 전부 "정상"으로 판정했다.
  폴백은 "내가 없을 때"만 걸리므로 "남이 없어 내 순위가 당겨지는" 오류는 덮지 못한다.
  `countRanked`(시즌 ZCARD 합) 대 `countRankEntriesBySeasonId`(DB) 대조로 바꿨다.
  인원이 같고 값만 낡은 경우는 여전히 못 잡는다(값 대조는 재구축과 비용이 같아 제외)

### STEP 5

- `findProfilesByUserIds`를 `LeagueRankingQueryRepository` / `Impl`이 아니라
  `UserLeagueRepository`의 **JPQL 생성자 프로젝션**(`findRankProfilesByUserIds`)으로 구현 —
  이유: STEP 2가 `LeagueRankProfileQuerySql`을 만들지 않기로 확정했고 STEP 4도 같은 방침을
  따랐다. `User`에 `@SQLRestriction("deleted_at IS NULL")`이 걸려 있어 계획서가 지시한
  `AND u.deleted_at IS NULL`이 자동으로 적용된다
- `UserLeagueQueryService`에 `SeasonRepository` 주입 — 이유: 저장소 키가 시즌 스코프인데
  `findLeagueRanking(leagueId, page)`에는 시즌이 없다. 계획서 결정 10의 "ACTIVE 시즌이 없으면
  빈 결과"를 구현하려면 활성 시즌 조회가 필요하다
- `findLeagueRankingByUser`의 `USER_NOT_FOUND` 검사 유지 — 이유: 계획서 결정 14는 `user_league`
  행이 없을 때를 빈 결과로 정했을 뿐 유저 부재는 다루지 않았다. 기존 계약(404)을 그대로 뒀다
- `LeagueRankingQueryRepository`의 목록 조회 2개는 미사용 상태로 남김 — STEP 6이 폴백으로 쓸
  예정이었으나, 마무리에서 신규 쿼리로 대체하고 삭제했다
- 정책 문서에 항목 2개 추가, 1개 정정 — 이유: 페이지가 10명 미만일 수 있다는 점과 빈 결과 계약이
  응답 계약이다. `rank = 0`을 "미집계"로 적은 항목은 폴백 도입으로 사실과 달라져 "리그 미참여"로 고쳤다

### STEP 6 (마무리)

계획서 6-1(폴백 쿼리 정리)과 6-2(폴백 전환)를 끝냈다. **6-3(재시도 큐)은 남아 있다.**

- 목록 2경로(R1, R2)의 폴백 쿼리를 `LeagueRankQuerySql.FIND_RANK_PAGE_IN_LEAGUE_SQL`로 **신규 작성** —
  이유: 계획서는 `LeagueRankingPagingQuerySql`을 `_FALLBACK`으로 개명해 재사용하라고 했으나,
  그 쿼리는 `DENSE_RANK()`로 파티션 전체에 순위를 매긴 뒤 잘라낸다. 순위는 `offset + 행 번호`로
  결정되므로 계산할 필요가 없다. `ORDER BY ... LIMIT/OFFSET`으로 바꿔 `RedisLeagueRankingStore.findPage`와
  같은 방식으로 순위를 부여했다. `FIND_RANKING_BY_USER_SQL`은 아예 불필요해졌다 — STEP 5에서
  서비스가 `findLeagueProfile`로 유저 → `(seasonId, leagueId)`를 먼저 풀기 때문이다
- 폴백이 `List<LeagueRankEntry>`를 반환 — 이유: 저장소와 **같은 타입**이라 조회 이후 로직
  (`hasNextPage` 판정, 프로필 배치 조회, `toRankRows`)이 두 경로에서 하나로 유지된다.
  대가로 폴백은 쿼리를 2번 쓴다(순위 페이지 + 프로필). 기존 조인 쿼리를 살리면 1번이지만
  서비스에 `LeagueRankRowDto`를 직접 만드는 두 번째 경로가 생긴다
- 결정 13을 `LeagueRankFinder.withFallback`으로 완결 — 3종 예외
  (`RedisConnectionFailureException`, `RedisSystemException`, `QueryTimeoutException`) 목록이
  코드 전체에서 한 번만 등장한다. `findRank`, `findPage` 둘 다 이 helper를 거친다
- `findPage`는 **예외에서만** 폴백한다(`findRank`는 예외 + 멤버 없음) — 이유: 빈 리스트는
  "참여자 없는 리그"이거나 "마지막 페이지 이후"라는 정상 응답이다(정책 문서). 여기서 폴백하면
  빈 페이지 요청마다 DB를 때린다
- `UserLeagueQueryService`의 `LeagueRankingStore` 직접 의존 제거 — 4개 조회 경로가 전부
  `LeagueRankFinder`를 거친다
- **죽은 코드 4건 삭제**: `LeagueRankingQueryRepository` / `Impl`,
  `LeagueRankingPagingQuerySql`, `UserLeagueRepository.findCurrentRankByUserId`.
  넷 다 호출처가 0이었고, 뒤의 둘은 옛 동점 기준(`updated_at ASC`)을 담고 있어 남겨두면
  STEP 4가 없앤 순위 불일치가 되살아날 수 있었다
- `LeagueRankFinderIntegrationTest` 신규 14건 — `@MockitoBean`으로 `LeagueRankingStore`가
  예외를 던지게 하고 4개 경로의 폴백, 동점 기준, 페이지 경계, 경로 간 순위 일치, 예외 3종을 검증한다.
  테스트 클래스를 경로별로 쪼개지 않은 이유는 폴백이 `LeagueRankFinder` 한 곳에서 갈리기 때문이다

**기록해 둘 동작 차이**: 탈퇴 유저가 저장소에 남아 있을 때 폴백과 정상 경로의 순위가 다르다.
정상 경로는 ZSET에 탈퇴자가 남아 뒷사람 순위가 밀리고 행만 응답에서 빠지지만, 폴백 쿼리는
`deleted_at IS NULL`로 걸러 순위가 당겨진다. 폴백이 더 정확하다. 제거 이벤트가 유실됐을 때만
생기는 상황이라 이번에는 맞추지 않았다(계획서가 이미 알려진 한계로 둔 지점이다).

### 측정 (HTTP end-to-end)

계획서 검증 절은 "구현체 대상 부하 재측정은 STEP 6 완료 후 `run-after.sh`로"라고만 정했다.
그 스크립트가 **애플리케이션을 타지 않는다는 것**이 확인되어 방식을 바꿨다.

- **`run-after.sh` / `mixed_client.py`로 재측정하지 않았다** — 이유: 둘 다 PG·Redis 프로토콜을
  직접 구현해 서비스 로직을 Python으로 다시 쓴 것이라 스프링·JPA·커넥션 풀·시큐리티 필터가
  측정에서 빠진다. `run-after.sh` 헤더도 "데이터 경로 프로토타입을 재는 것"이라고 밝히고 있다.
  게다가 키 프리픽스(`lr:` 대 `league:rank:`), member 형식(12자리 제로패딩 대 평문),
  `SCORE_BASE`(10^7 대 10^9)가 구현과 전부 달라 그대로 돌리면 프로토타입을 다시 재게 된다.
  대신 실제 엔드포인트를 HTTP로 때리는 `run-http.sh`를 새로 만들었다
- **개선 전 수치도 같은 방식으로 다시 쟀다** — 이유: 프로토타입 수치(개선 전 11.1 TPS,
  개선 후 9,493 TPS)와 HTTP 수치(23.4 → 2,449.5 TPS)는 절대값이 달라 섞어 쓸 수 없다.
  HEAD(`15af2667`)를 git worktree로 떠서 빌드해 `before_s0`, `before_s4`를 같은 부하
  생성기로 측정했다. **배수 비교는 같은 방식끼리만 성립한다**
- 결과: `before_s4`(현재 배포 상태) 대비 **TPS 104.7배, p95 178.6배**.
  경로별 p95는 R1 134배 / R2 123배 / R3 106배 / R4 175배.
  상세는 `benchmark/league-ranking/RESULTS.md`의 「HTTP end-to-end 측정」

### 측정이 잡은 결함 — `replaceAll` 배치화

**계획서에 없던 소스 수정이다.** 100만 규모에서 랭킹 백필이 **항상 실패**했다.

STEP 1이 `RedisConfig`에 건 랭킹 커맨드 타임아웃 100 ms와, `RedisLeagueRankingStore.replaceAll`이
리그당 `ZADD` 한 번에 전원을 넣는 구현이 충돌한다. 최대 리그가 270,138명이라 100 ms 안에
끝날 수 없다. 15개 리그 중 1개만 만들어지고 `QueryTimeoutException`으로 중단됐다.

파급은 워밍업보다 시즌 롤오버가 크다. `LeagueRankingWarmupRunner`는 예외를 삼키지만
`SeasonBatchService.finalizeAndRollover`는 `@Transactional` 안에서 try/catch 없이 `rebuild`를
호출하므로 **롤오버 전체가 롤백된다.** `QueryTimeoutException`이 `TransientDataAccessException`
하위라 메서드에 걸린 `@Retryable`이 재시도하는데, 원인이 데이터 크기라 매번 같은 곳에서 죽는다.

- `replaceAll` → 1,000건 배치로 분할 (`addInBatches`)
- `deleteSeason` → `DEL`을 `UNLINK`로 교체. 27만 멤버 zset 15개를 한 `DEL`로 지우는 것도
  같은 이유로 100 ms를 넘길 수 있다. `UNLINK`는 클라이언트 입장에서 O(1)이다

수정 후 백필 **1.77초**, 970,114명 전원 반영, 리그별 인원이 DB 집계와 일치.

결정 4("시즌 롤오버 → 배치 트랜잭션 내 동기 재구축. 100만 구축 1초(실측)")의 근거였던
"1초"는 `redis-cli --pipe`로 잰 값이다. 파이프라인으로 잘게 쪼개 보낸 것이라 조건이 달랐다.
**결정 자체는 유지되지만 근거는 이 수정이 있어야 성립한다.**

### 범위 밖으로 분리한 발견

측정 과정에서 나왔으나 리그 랭킹과 무관하다. `docs/improvement-backlog.md`로 옮겼다.

| 항목 | 근거 |
|---|---|
| `JwtAuthFilter`가 같은 유저를 2번 조회 | 요청당 `users` PK 조회 2.03회 |
| `V34` 마이그레이션 중복(#475, #478) | `flywayValidate` 실패로 빌드 차단 |
| `existsById`가 필터 조회와 중복 | 합쳐서 요청당 유저 조회 3회 |
| 조회 요청마다 `users` UPDATE | `LastAccessInterceptor`. 벤치가 과대표현하는 값이다 |
| ~~시즌 최종 순위의 동점 기준 불일치~~ | **이 브랜치에서 수정.** `insertFromCurrent`의 `updated_at ASC` 제거 |
| 최종 순위가 탈퇴 유저를 포함 | `users` 조인 필터는 **넣으면 안 된다** — `softResetForNextSeason`이 이력 행을 구동원으로 써서 롤오버가 깨진다 |
| `user_league_history`에 `user_id` 인덱스 없음 | 시드 0행이라 **판정 불가** |
