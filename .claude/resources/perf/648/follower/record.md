# [PERF-648] GET /api/v1/friends/follower

> 이슈: #648
> 브랜치: refactor/648-follower-feed-scan
> 대상 디렉토리: `.claude/resources/perf/648/follower/`

이 파일은 대상 엔드포인트 하나만 다룬다. 같은 이슈의 다른 엔드포인트는 각자의 디렉토리에 각자의 `record.md`를 가진다.

## 진행 상태

> ⏳ 미완 / ✅ 완료 / ⏭️ 건너뜀
> 재진입 시 ⏳로 표기된 가장 이른 Phase부터 재개한다.

**준비 (대상당 1회)**

| 1. 대상 | 2. 환경 | 3. 조건 | 4. 기준선 |
|---|---|---|---|
| ✅ | ✅ | ✅ | ✅ |

**사이클 (반복)**

| # | 기법 | 5. 설계 | 6. 스냅샷 | 7. 적용 | 8. 검증 |
|---|---|---|---|---|---|
| 1 | 인덱스 추가 (`friends (followee_id, created_at DESC) INCLUDE (follower_id)`) | ✅ | ✅ | ✅ | ✅ |

## 대상

- 엔드포인트: `GET /api/v1/friends/follower?page={n}`
- 실행 경로: `JwtAuthFilter`(`AuthTokenProvider.parseUser` → `UserRepository.findById`, Phase 4 측정에서 확인) → `LastAccessInterceptor` → `FriendController.getFollowers` → (Facade 없음) → `FriendService.getFollowers` → `FriendRepository.findFollowersByFolloweeId`
- 예상 쿼리 목록 (요청 1회 기준)
  1. `UserRepository.updateLastAccessedAt` - `UPDATE users SET last_accessed_at WHERE id = ? AND (last_accessed_at IS NULL OR last_accessed_at < 오늘 0시)`. 매 요청 실행, 그날 두 번째 요청부터 0행 갱신
  2. `UserDailyActivityRepository.insertIfAbsent` - `INSERT INTO user_daily_activity ... ON CONFLICT DO NOTHING`. 1번이 1행을 갱신했을 때만 실행 (사용자별 그날 첫 요청)
  3. `FriendRepository.findFollowersByFolloweeId` - `friends f` JOIN `users u`(팔로워 프로필) LEFT JOIN `friends f2`(맞팔 여부), `WHERE f.followee_id = ?`, `ORDER BY f.created_at DESC`, `OFFSET ? LIMIT 11` (Slice라 count 쿼리 없음)
  - 지연 로딩 없음 (생성자 프로젝션)
  - 정상 상태 요청당 2개(1, 3), 사용자별 그날 첫 요청만 3개
- 부수 관측 (PLAN-648 결정 1): 같은 인덱스로 영향을 받는 아래 두 쿼리는 부하 테스트 없이 Phase 6과 Phase 8에서 같은 파라미터로 `EXPLAIN (ANALYZE, BUFFERS)`만 남긴다
  - `FriendRepository.countByFolloweeId` (`GET /api/v1/friends/count`)
  - `FriendRepository.findFollowerIdsByFolloweeId` (`SocialFacade` 피드 배포)
- 인덱스 현황: 미확인 (Phase 2의 6에서 실측)

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application=gravit-perf` 확인, 히스토그램 버킷 146개 노출). 베이스 `application.yml`은 로컬에 없어 `application-local.yml`을 복사하고, 빠진 설정 키(`oauth.ios`, `oauth.apple`, `discord`, `aws.s3.download-expiry`, `metric-report`, `auth.cookie`, `spring.ai`)를 `application-test.yml`의 더미 값으로 채움. 디스코드 리포트와 지표 요약은 꺼 둠 |
| 커넥션 풀 크기 | 60 (`application-perf.yml`의 `maximum-pool-size`, 풀 이름 `gravit-perf-pool` 기동 로그로 확인) |
| 데이터 규모 | 목표와 검증값 일치. `users` 시드 100,000 (id 1001~101000, 기존 3행 별도), `friends` 시드 범위 2,128,000 (기본 1,998,000 + 측정 사용자 팔로워 100,000 + 맞팔 30,000, 기존 4행 별도), `user_daily_activity`는 대상 규모 무관이라 시드하지 않음 |
| 카디널리티 | `friends.followee_id` 100,000, `friends.follower_id` 100,000. 측정 사용자(id 1001~1100, 100명) 1명당 팔로워 정확히 1,000 (min = max = 1000), 그중 맞팔 300 (min = max = 300). 나머지 사용자는 20명 팔로우, 팔로워 평균 약 20. `created_at`은 365일 구간(2025-11-25 ~ 2026-11-25)에 분산. 자기 팔로우 0, 중복 쌍 0 |
| 부하 조건 | VU 50, 유지 1m (ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m). 요청은 `page=0` 고정, 측정 사용자 100명(id 1001~1100) 토큰을 반복 번호로 순환. #492 측정과 같은 조건 |
| Redis 캐시 상태 | 해당 없음. 대상 API가 Redis를 읽지 않음 (그래도 Phase 4, 8 절차의 FLUSHDB는 그대로 수행) |
| DB 캐시 상태 | 제어하지 않음. warmup(VU 5, 30s) 후 측정 |
| 캐시 제어 수단 | `docker exec gravit-redis-local redis-cli` (로컬에 redis-cli 없음) |
| 실행 방식 | Windows. 앱은 PowerShell에서 `bootRun`, 측정 명령은 Git Bash에서 `export MSYS_NO_PATHCONV=1` 후 실행(경로 자동 변환 방지). psql은 컨테이너 안에서(`docker exec gravit-postgres-local psql -U postgres -d mydb`), 시드와 EXPLAIN 파일은 `docker cp` 또는 stdin(`docker exec -i ... < 파일`)으로 넘김. Windows `jq` 출력의 `\r`은 `tr -d '\r'`로 제거. k6는 winget으로 설치 |
| 스키마 드리프트 | 이번 대상 테이블(`friends`, `users`, `user_daily_activity`)은 없음. 6)이 출력한 7개(`ix_interview_answer_concept_result_answer`, `ix_interview_answer_session`, `ix_interview_answer_wrong_concept_answer`, `ix_interview_question_category_difficulty`, `ix_interview_question_concept_question`, `ix_interview_stack_axis_stack`, `ix_interview_tech_stack_job_role`)는 V40에서만 만들어지고 V41이 해당 테이블을 `DROP TABLE`로 재생성하며 함께 사라진 것이라 실제 누락이 아님(검사가 `DROP INDEX`만 대조하는 한계). 모두 이번 대상이 읽지 않는 `interview_*` 테이블. 그 밖에: Phase 2 직전 기동에서 로컬 DB가 V47 → V53으로 마이그레이션됨, `pg_stat_statements` 확장을 이번에 생성함 |
| 시드 SQL | `../seeds.sql` (이슈 공용). 컨테이너 안 psql로 실행 (`docker cp` 후 `docker exec -w /tmp/perf ... -f`), 약 66초 |
| 시드 모듈과 변수 | `user.sql`, `friend.sql`(이번 이슈에서 신규). `user_start=1001`, `user_count=100000`, `hot_user_count=100`, `hot_followers=1000`, `follows_per_user=20`, `follow_stride=4999`, `mutual_pct=30`, `follow_window_days=365` |

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| p95 | 3859.106279999999 ms (중앙값 2481.5101, max 4938.4427) |
| p99 | 4376.4299280000005 ms |
| RPS | 15.238976961834608 (요청 1829건) |
| 에러율 | 0 |
| check 통과율 | 1 (데이터 검증 포함 3개 항목 1829/1829) |
| 요청당 쿼리 수 | SELECT 2 + UPDATE 1, 트랜잭션 3 (읽기 전용 2, 쓰기 1) |

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.md` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 1.00000000000000000000 | 2427.539571606886 | 4439969.8764689965 | 99.97469471204874% | `FriendRepository.findFollowersByFolloweeId` (행/호출 11) |
| 1.00000000000000000000 | 0.16546498578458171 | 302.6354589999999 | 0.006814435337256732% | `AuthTokenProvider.parseUser` → `UserRepository.findById` |

### 진단

- 병목 성격: 쿼리 자체 비효율 (친구 조회 쿼리 1건)
- 근거: 요청당 1회라 N+1이 아니다. 이 쿼리가 DB 시간의 99.97%이고 mean 2427.5ms로 나머지 쿼리(0.2ms 미만)와 4자리 이상 차이 난다. 반환은 11행뿐이라 읽는 양이 반환량보다 훨씬 많다고 볼 수 있다. API 중앙값 2481.5ms가 이 쿼리 mean과 거의 같아 응답시간 대부분이 이 쿼리다. 단, mean은 VU 50 동시 실행 중 값이라 단건 비용과 읽은 행 수는 Phase 6 실행계획으로 확인한다
- 예상 쿼리 목록과 어긋난 지점: `JwtAuthFilter`가 `AuthTokenProvider.parseUser`로 `users`를 매 요청 1회 조회한다 (Phase 1에서 누락). 조건부 INSERT(`user_daily_activity`)는 warmup에서 소진되어 측정 구간에 없다. 친구 조회의 `users` 조인에는 `@SQLRestriction`의 `deleted_at IS NULL`이 붙는다

---

## 사이클 1: 인덱스 추가

### 설계 결정

> Phase 5-B에서 호출자와 확정한 내용.

```sql
CREATE INDEX IF NOT EXISTS ix_friends_followee_created
    ON friends (followee_id, created_at DESC) INCLUDE (follower_id);
```

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 기법 | 인덱스 추가 | 쓰기(팔로우, 언팔로우, 팔로워 거절)는 빈도가 낮고, 같은 인덱스로 읽기 세 경로(팔로워 목록, 팔로워 수, 피드 배포)가 함께 좋아진다 |
| 대상 컬럼과 순서 | `followee_id`, `created_at DESC` | 같음 조건 컬럼을 앞에 두면 한 사용자의 팔로워가 한 구간에 모이고, 그 안이 `created_at` 순이라 정렬 없이 11행에서 멈출 수 있다. 실측 인덱스는 `friends_pkey (id)`, `ix_friends_follower_followee (follower_id, followee_id)`뿐이었다 |
| 부분 인덱스 | 없음 (전체) | 세 쿼리 모두 추가 필터가 없다. `friends`에는 soft delete가 없고, 탈퇴자는 `users` 조인 쪽에서 걸러진다 |
| 커버링 | `INCLUDE (follower_id)` | `follower_id`는 조인 키와 반환값으로만 쓰이고 정렬과 검색에는 안 쓰인다. `correlation`이 `followee_id` -0.13, `created_at` -0.04라 heap 왕복은 랜덤 접근이 되고, 팔로워 수와 피드 배포는 1,000행을 읽는다 |
| 쓰기 비용 | 감수 (`friends` 인덱스 2 → 3, 팔로우 INSERT마다 항목 1개) | 쓰기 빈도가 낮다. 회원 정리 배치의 `followee_id = ?` 삭제는 오히려 빨라진다 |
| 생성 방식 | 일반 `CREATE INDEX IF NOT EXISTS` | 기존 마이그레이션 방식과 맞춘다. 생성 중 `friends` 쓰기가 잠기므로 배포 전 운영 행 수를 확인해 PR에 남긴다 |
| 기존 인덱스 | `ix_friends_follower_followee` 유지 | 팔로잉 목록, 맞팔 조인(`f2`), 중복 팔로우 확인이 쓴다 |

- 검토했지만 택하지 않은 안: 쿼리 재작성 - `followee_id` 인덱스 없이는 첫 단계가 여전히 전체 스캔이다 / 캐싱 - 팔로우, 언팔로우, 프로필 변경, 탈퇴, 맞팔 변경까지 무효화 경로가 많다 / 부분 인덱스 - 쿼리에 대응하는 조건이 없어 플래너가 쓸 수 없다 / `follower_id`를 키 컬럼으로 - 검색과 정렬에 쓰지 않는다
- 호출자가 예상한 효과: 실행계획이 Index Scan으로 바뀌고 Sort 노드가 사라진다. 친구 조회 mean이 수 ms로, p95가 크게 감소한다

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 3859.106279999999 / 4376.4299280000005 ms |
| RPS | 15.238976961834608 |
| 요청당 쿼리 수 | SELECT 2 + UPDATE 1, 트랜잭션 3 |
| 대상 쿼리 calls / mean_ms / total_ms | 1829 / 2427.539571606886 / 4439969.8764689965 (DB 시간의 99.97469471204874%) |

부하 조건: VU 50, 유지 1m (총 2m), `friends` 시드 범위 2,128,000행, 커넥션 풀 60. Phase 4 측정과 같다.

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`)

- EXPLAIN 파라미터: `$1 = 1050`, `$2 = 1050`, `$3 = 11` (측정 사용자 범위 1001~1100의 가운데. 이후 모든 사이클에서 동일하게 사용). 부수 관측 [B] `countByFolloweeId`, [C] `findFollowerIdsByFolloweeId`는 부하에서 실행되지 않아 SQL을 JPQL로부터 재구성했고 같은 값 1050을 쓴다
- 스캔 방식: [A] `friends f1_0`에 Parallel Seq Scan (워커 2) → Sort(`created_at DESC`, quicksort 42kB) → Gather Merge, 사용 인덱스: 없음. `users`는 `users_pkey` Index Scan, 맞팔 `f2_0`은 `ix_friends_follower_followee` Bitmap Index Scan
- actual rows 대 반환 행 수: Parallel Seq Scan 333 × loops 3 = 999행 내보냄, 최종 반환 11행
- Rows Removed by Filter: 709001 × loops 3 = 약 2,127,003행 (검사 약 2,128,000 / 내보냄 999, 약 2130:1)
- shared hit / read: 16410 / 1726 (쿼리 전체 18,136페이지, 약 141.7MB). 그중 Parallel Seq Scan이 16010 / 1724 = 17,734페이지(97.8%)
- 플래너 추정 대 실측: Parallel Seq Scan rows=591 / actual rows=333 (loops당), Bitmap Index Scan rows=23 / actual rows=300 (13배)
- Execution Time 156.051 ms (단건, 부하 중 mean 2427.5ms와 별개), Planning Time 8.415 ms
- 부수 관측: [B] Execution 160.566 ms, Parallel Seq Scan Rows Removed 709001 × 3, `users_pkey` Index Scan loops 1000, shared 19035 / 1701. [C] Execution 144.444 ms, Parallel Seq Scan Rows Removed 709001 × 3, 1000행 반환, shared 16053 / 1681
- 해석: 비용은 `friends` Parallel Seq Scan에 있다. 약 212.8만 행을 읽고 999행만 내보낸다(약 2130:1). 쿼리 시간 156.051ms 중 135.828ms까지가 이 노드이고, 쿼리가 만진 페이지의 97.8%가 이 노드다. Sort는 자식 제외 약 0.2ms, Materialize는 11회 합계 약 1.5ms로 작다

> 캐싱 사이클이 아니면 개선 후 지표의 캐시 행은 `-`로 둔다.

### 적용 내용

- `src/main/resources/db/migration/V54__add_friends_followee_index.sql` 신규 - `CREATE INDEX IF NOT EXISTS ix_friends_followee_created ON friends (followee_id, created_at DESC) INCLUDE (follower_id)`. 애플리케이션 코드 변경 없음
- 테스트 (2026-11-27): `./gradlew test` 1641건 중 1건 실패 → 이번 변경과 무관하다고 판단, 단독 재실행 통과
  - 실패: `RetryQueueSweeperIntegrationTest$ReprocessFailed.재적재에_실패하면_원본_항목이_큐에_남는다` (기대: 원본 항목 1건, 실제: 빈 큐)
  - 근거: 같은 리포트에서 `Test worker`가 아닌 `retry-sweep-3` 스레드가 `userId=3, lessonId=1, errorCode=USER_LEAGUE_NOT_FOUND`로 "재시도 종료"를 남겼다. 이 테스트 컨텍스트의 `pointService`는 `RuntimeException`을 던지도록 스텁되어 있으니, 다른 캐시된 컨텍스트의 스케줄러가 처리한 것이다. Redis 테스트 컨테이너는 static 하나를 모든 컨텍스트가 공유하고(`RedisTestContainerConfig`), 컨텍스트마다 `RetryQueueSweeper.sweep()`이 30초 간격으로 같은 키 `league-points-retry`를 스윕한다. V54는 `friends` 인덱스 추가뿐이라 이 경로와 관계없다
  - 확인: `./gradlew test --tests "gravit.code.global.event.retry.RetryQueueSweeperIntegrationTest"` 단독 실행 BUILD SUCCESSFUL
  - 테스트 격리 문제(공유 Redis와 컨텍스트별 스케줄러)는 이번 이슈 범위 밖이라 손대지 않았다
- 마이그레이션 적용 (2026-11-27): `bootRun`(perf) 재기동으로 Flyway가 V54 적용. `\d friends`에서 `ix_friends_followee_created btree (followee_id, created_at DESC) INCLUDE (follower_id)` 확인, 기존 `friends_pkey`, `ix_friends_follower_followee` 유지. 직후 `ANALYZE friends` 실행
  - 재기동 첫 시도는 컨테이너가 이전에 비정상 종료(Exited 255)돼 crash recovery 중이라 Flyway가 `57P03 the database system is starting up`으로 실패했다. 복구 완료 후 재시도로 해소, 코드와 무관

### 개선 후 지표

> 원본: `k6-test-summary-1.json`, `query-stats-summary-1.md`, `query-plan-1.txt`. 조건은 Phase 4와 같다 (VU 50, 총 2m, 시드 동일, 풀 60, warmup 후, VACUUM ANALYZE, FLUSHDB, 통계 리셋). 측정 직전 `users` n_dead_tup 121 (VACUUM 이후 앱 쓰기로 추정, -0 측정 때 값은 기록 없음). 다른 프로젝트 컨테이너(`bayes-*`)는 측정 중 정지. check 45587/45587, 실패 0. EXPLAIN 세 쿼리의 Query Identifier가 -0과 같다

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 3859.106279999999 ms | 166.43054 ms | 약 23.2분의 1 |
| | p99 | 4376.4299280000005 ms | 232.35051 ms | 약 18.8분의 1 |
| | RPS | 15.238976961834608 | 379.8159022565375 | 약 24.9배 |
| 하드웨어 독립 | 요청당 쿼리 수 | SELECT 2 + UPDATE 1, 트랜잭션 3 | SELECT 2 + UPDATE 1, 트랜잭션 3 | 같음 |
| | 대상 쿼리 total_ms | 4439969.8764689965 (mean 2427.539571606886, 99.97469471204874%) | 21206.92993200002 (mean 0.4651968748108025, 62.9697085800219%) | 요청 수가 24.9배인데 total_ms 약 209분의 1, mean 약 5218분의 1 |
| | 검사 행 / 반환 행 | [A] `friends f1_0` 약 2,128,000 검사 / 999 내보냄 (약 2130:1) | [A] Index Cond로 11행 읽고 11행 내보냄 (1:1) | Filter 제거 |
| | 스캔 방식 | [A] Parallel Seq Scan → Sort → Gather Merge, 18,136페이지, Execution 156.051 ms | [A] Index Only Scan `ix_friends_followee_created`, Heap Fetches 0, Sort 없음, 294페이지(전부 hit), Execution 0.993 ms | Sort 노드 소멸 |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클 아님 |

- 부수 관측 [B] `countByFolloweeId`: Parallel Seq Scan + Nested Loop(`users_pkey` loops 1000), 20,736페이지, 160.566 ms → Bitmap Index Scan `ix_friends_followee_created` + Bitmap Heap Scan(833블록, `count(f1_0.id)`의 `id`가 인덱스에 없음) + Hash Join(`users` Seq Scan 100003행), 2,766페이지, 59.074 ms. 남은 시간의 대부분(55.089 ms)은 `users` 해시 생성이다
- 부수 관측 [C] `findFollowerIdsByFolloweeId`: Parallel Seq Scan, 17,734페이지, 144.444 ms → Index Only Scan, Heap Fetches 0, 9페이지, 0.301 ms
- 그 밖의 관측: [A] Planning Time 8.415 → 25.737 ms (단건, Execution 0.993 ms보다 크다). 부하 중 대상 쿼리 원문의 CASE 결과가 `true`/`false`에서 `$4`/`$5`로 정규화되어 기록됨 (코드 변경 없음)
- 호출자 예상(Index Scan 전환, Sort 소멸, mean 수 ms, p95 크게 감소)과 대조: Sort 소멸과 p95 감소는 예상대로. 스캔은 예상한 Index Scan이 아니라 `INCLUDE (follower_id)` 덕에 heap을 읽지 않는 Index Only Scan이 됐고, mean은 수 ms가 아니라 0.4651968748108025 ms였다

### 판정

- 개선 여부 (하드웨어 독립 증거 기준): 있음 - 요청당 쿼리 수는 같고, 대상 쿼리의 `friends` 접근이 약 2130:1 Seq Scan에서 1:1 Index Only Scan으로, 만진 페이지가 18,136에서 294로 줄었다. 계획 변화는 Query Identifier가 같은 쿼리에서 인덱스 유무만 다를 때 나온 것이다
- 남은 위험 신호: (1) 추정 대 실측 10배 이상 - 맞팔 왼쪽 조인 `f2_0` Bitmap Index Scan 추정 21 / 실측 300 (14배, -0도 13배). (2) 검사 행 / 반환 행 - Left Join의 Join Filter가 3000행을 버리고 11행을 낸다 (-0과 같음). `f2_0` 쪽이 쿼리 전체 294페이지 중 254페이지. (3) 단일 쿼리 점유율 62.9697085800219% - 요청당 쿼리가 4종뿐이라 생기는 상대 비중이며 mean은 0.4651968748108025 ms. 해소: `friends` Seq Scan, 약 2130:1 Filter
- 다음 사이클 진행 여부: 종료 (호출자 선택). 요청당 DB 시간 합이 약 0.74 ms(대상 0.465 + `findById` 0.103 + `BEGIN READ ONLY` 2회 0.096 + `updateLastAccessedAt` 0.071 + `BEGIN` 0.004)로 API 중앙값 94.9953 ms의 1% 미만이라, 남은 조인 비용을 줄여도 응답시간에는 측정 편차 이하로만 나타난다고 봤다

---

## 최종 요약

> 하드웨어 의존 증거와 독립 증거를 모두 남긴다.

| 구분 | 지표 | 최초 | 최종 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 3859.106279999999 ms | 166.43054 ms | 약 23.2분의 1 |
| | p99 | 4376.4299280000005 ms | 232.35051 ms | 약 18.8분의 1 |
| | RPS | 15.238976961834608 | 379.8159022565375 | 약 24.9배 |
| 하드웨어 독립 | 요청당 쿼리 수 | SELECT 2 + UPDATE 1, 트랜잭션 3 | SELECT 2 + UPDATE 1, 트랜잭션 3 | 같음 |
| | 검사 행 / 반환 행 | [A] `friends f1_0` 약 2,128,000 / 999 (약 2130:1) | [A] `friends f1_0` 11 / 11 (1:1) | Filter 제거 |
| | 스캔 방식 | [A] Parallel Seq Scan → Sort → Gather Merge (18,136페이지) | [A] Index Only Scan `ix_friends_followee_created`, Heap Fetches 0, Sort 없음 (294페이지) | Seq Scan, Sort 소멸 |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클 없음 |

적용한 기법: 1. 인덱스 추가 (`V54__add_friends_followee_index.sql`, `friends (followee_id, created_at DESC) INCLUDE (follower_id)`)

- 부수 관측: [B] `countByFolloweeId` 160.566 → 59.074 ms (20,736 → 2,766페이지, 남은 시간 대부분은 `users` Seq Scan 기반 Hash), [C] `findFollowerIdsByFolloweeId` 144.444 → 0.301 ms (17,734 → 9페이지, Index Only Scan)
- 종료 사유: 호출자가 종료를 선택. 남은 위험 신호는 사이클 1 **판정** 참고
