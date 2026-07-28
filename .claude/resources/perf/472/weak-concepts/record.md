# [PERF-472] GET /api/v1/my-pages/learning/weak-concepts

> 이슈: #472
> 브랜치: refactor/472-mypage-learning-performance
> 대상 디렉토리: `.claude/resources/perf/472/weak-concepts/`

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
| 1 | `problem_submission (user_id, problem_id) INCLUDE (is_correct)` 커버링 인덱스 | ✅ | ✅ | ✅ | ✅ |

## 대상

- 엔드포인트: `GET /api/v1/my-pages/learning/weak-concepts`
- 실행 경로: `MyPageController:51-54` → (Facade 없음) → `ProblemSubmissionQueryService:22-37` → `ProblemSubmissionRepository:14-36`
- 예상 쿼리 목록 (요청 1회 기준)
  1. `ProblemSubmissionRepository.findWeakUnitsByUserId` - `problem_submission → problem → lesson → unit → chapter` 조인 후 유닛 단위 집계. `GROUP BY u.id, u.title, c.title`, `HAVING` 오답 수 > 0, 오답률·오답 수·유닛 ID 순 정렬, `LIMIT 7`
  2. 지연 로딩 지점 없음. Service의 순위 부여 루프(`:30-34`)는 메모리 작업
- 대상 밖에서 붙는 쿼리 (진단 시 대상 쿼리와 분리해 읽는다)
  - `users` SELECT 2회 - `JwtAuthFilter:78`(`getAuthUser` → `parseUser`)과 `JwtAuthFilter:81`(`parseUser`)이 각각 `AuthTokenProvider:71`의 `userRepository.findById`를 타고, `open-in-view: false` + 두 호출 모두 트랜잭션 밖이라 영속성 컨텍스트를 공유하지 않는다

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application_ready_time_seconds{application="gravit-perf"}` 확인) |
| 커넥션 풀 크기 | 10 (`application-perf.yml:14`) |
| 데이터 규모 | `problem_submission` 2,000,000 / `problem` 3,900 / `lesson` 130 / `unit` 65 / `chapter` 5 / `users` 1,000 (id 1001~2000) |
| 카디널리티 | `ps.user_id` 1,000 (유저당 2,000행) / `ps.problem_id` 전역 3,900, 유저당 700 / 유저당 오답 문제 210개(오답 행 600, 30%) / `GROUP BY` 그룹 12개 중 `HAVING` 통과 9개 → `LIMIT 7`이 7개로 절단 |
| 부하 조건 | VU 50, duration 1m (ramp-up 30s + 1m + ramp-down 30s). 이슈 내 3개 대상 공통 |
| 캐시 상태 | cold (measure 직전 FLUSHDB). 현재 실행 경로에 캐시 없음 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` |
| DB 접속 | `PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d mydb` |
| 응답시간 히스토그램 | `http_server_requests_seconds_bucket` 146개 노출 |
| 시드 SQL | `../seeds.sql` (이슈 공용) |
| 시드 모듈과 변수 | `content.sql`(`content_id_base 900000`, `chapter_count 5`, `units_per_chapter 13`, `lessons_per_unit 2`, `problems_per_lesson 30`) / `user.sql`(`user_start 1001`, `user_count 1000`) / `learning.sql`(`problem_sub_per_user 2000`, `distinct_problems 700`, `wrong_pct 30`, `lesson_sub_per_user 300`, `distinct_lessons 100`, `window_days 180`, `recent_days 7`, `recent_count 100`, `daily_record_days 180`) |
| 초기화 이력 | 최초 적재 시 DB에 이전 세션 데이터가 남아 재실행 가드가 열리지 않았고, 앱 시드 콘텐츠(chapter 5 / unit 69 / lesson 205 / problem 1,414)를 참조하는 제출 200만 건이 있었다. 제출 전량과 앱 콘텐츠(id < 900000) 및 그 참조 행(`answer`, `option`, `bookmark`, `wrong_answered_note`, `report`)을 삭제한 뒤 재적재해, 현재 제출은 perf 콘텐츠만 참조한다 (`content_cardinality` 3,900 = perf 문제 전량) |

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| med | 2746.709 ms |
| p95 | 3598.58125 ms |
| p99 | 4014.4301499999997 ms |
| max | 4379.747 ms |
| RPS | 16.373709003628573 |
| 요청 수 | 1966 (측정 구간 실경과 120.07초) |
| 에러율 | 0 |
| check 통과율 | 1 (3항목 전부 1966/1966) |
| 요청당 쿼리 수 | 4 (대상 1 + `users` SELECT 2 + `users` UPDATE 1), 트랜잭션 4 (`BEGIN READ ONLY` 3 + `BEGIN` 1) |

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.txt` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 1.00 | 563.81 | 1108458.43 | 100.0% | `ProblemSubmissionRepository.findWeakUnitsByUserId` |
| 1.00 | 0.12 | 231.43 | 0.0% | `UserRepository.updateLastAccessedAt` |
| 2.00 | 0.04 | 151.13 | 0.0% | `AuthTokenProvider.parseUser` |

### 진단

- 병목 성격: 대상 쿼리 자체의 비효율. 커넥션 풀 포화는 그 증상이다.
- 근거
  - 요청당 1.00회뿐인 `findWeakUnitsByUserId`가 전체 DB 시간의 100.0%를 차지한다. 호출 수는 예상과 일치하므로 N+1이 아니다.
  - 이 쿼리가 점유한 커넥션-시간 1,108,458.43 ms는 측정 구간에 쓸 수 있는 총량(풀 10 × 120,070 ms = 1,200,700 ms)의 92.3%다.
  - 풀이 허용하는 최대 처리량은 10 ÷ 0.56381s = 17.74 RPS이고 실측 RPS는 16.373709다. Little's Law로 계산한 평균 응답시간 50 ÷ 16.374 = 3053.7 ms가 실측 med 2746.709 ~ p95 3598.58125 구간에 들어온다. 즉 응답시간은 커넥션 대기가 지배한다(p95 기준 대기 3034.77 ms, 84.3%).
  - `waiting_ms` p95 3598.34075가 `duration_ms` p95 3598.58125와 거의 같아 대기가 전부 서버 내부에서 발생한다.
  - 유저당 `problem_submission` 2,000행을 읽어 7행을 반환한다(`rows_per_call` 7.0).
  - mean 563.81 ms는 동시 10개 실행 중의 값이므로 경합이 섞여 있다. 단독 실행 비용은 Phase 6의 `EXPLAIN (ANALYZE, BUFFERS)`에서 확인한다.
- 예상 쿼리 목록과 어긋난 지점: `UserRepository.updateLastAccessedAt`(요청당 1.00회)이 목록에 없었다. `LastAccessInterceptor.preHandle` → `UserAccessService.updateLastAccessed` 경로로 인터셉터가 붙인다. 시간 비중은 0.0%(231.43 ms)다.

---

## 사이클 1: `problem_submission` 인덱스 추가

### 설계 결정

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 대상 컬럼과 순서 | `(user_id, problem_id) INCLUDE (is_correct)` | `user_id`는 이 테이블의 유일한 필터(`WHERE ps.user_id = ?`)이므로 선두 키다. `problem_id`를 키에 두어 `COUNT(DISTINCT ps.problem_id)`의 중복 제거 정렬이 생략될 여지를 만든다. `is_correct`는 `WHERE`·`ORDER BY` 어디에도 쓰이지 않고 값만 읽히므로 키에서 빼 내부 노드 크기를 줄인다 |
| 커버링 여부 | 커버링 (쿼리가 읽는 세 컬럼을 모두 담음) | `user_id` correlation 0.008813548 — 한 유저의 2,000행이 20,344 페이지 전역에 흩어져 있다. 커버링이 아니면 Index Scan 후 힙 랜덤 접근이 최대 2,000회 발생한다 |
| 부분 인덱스 조건 | 없음 | `WHERE`에 `user_id` 등호 하나뿐이라 걸 조건이 없다. `is_correct = false`로 부분 인덱스를 만들면 `COUNT(DISTINCT ps.problem_id)`(전체 풀이 수)를 셀 수 없어 쿼리가 인덱스를 쓰지 못한다 |
| 생성 방식 | `CREATE INDEX` (CONCURRENTLY 아님) | Flyway는 PostgreSQL 마이그레이션을 트랜잭션으로 감싸므로 `CONCURRENTLY`는 별도 설정이 필요하다 |
| 감수할 쓰기 비용 | INSERT당 인덱스 엔트리 삽입 1회 추가 | 이 테이블의 인덱스는 PK 1개뿐이었다. 쓰기 경로는 문제 풀이 시 INSERT이고 UPDATE·DELETE는 사실상 없다 |

- 검토했지만 택하지 않은 안
  - `(user_id, problem_id, is_correct)` — `is_correct`가 검색·정렬에 쓰이지 않는데 키로 두면 내부 노드까지 커진다
  - `(user_id) INCLUDE (problem_id, is_correct)` — 힙 접근은 똑같이 없애지만 `problem_id` 정렬을 얻지 못한다
  - 인덱스 외 기법(쿼리 재작성, 조인 축소, 사전 집계 테이블, Redis 캐싱) — 사이클 1에서는 한 기법만 적용한다
- 호출자가 예상한 효과: 스캔 비용 감소 — `Parallel Seq Scan` → `Index Only Scan`, 검사 행 2,000,000 → 2,000
- 유보 사항: 인덱스가 주는 `problem_id` 정렬이 `GroupAggregate`까지 살아남는지는 별개다. 중간의 `Sort Key: l1_0.unit_id`가 순서를 깨므로, 플래너가 `(unit_id, chapter_title, problem_id)` 복합 정렬을 고르지 않으면 중복 제거 정렬은 그대로 남는다. 이 구간이 걸린 비용은 1.159 ms(전체의 0.25%)다

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 3598.58125 ms / 4014.4301499999997 ms |
| RPS | 16.373709003628573 |
| 요청당 쿼리 수 | 4 (대상 1 + `users` SELECT 2 + `users` UPDATE 1) |
| 대상 쿼리 calls / mean_ms / total_ms | 1966 / 563.81 / 1108458.43 |

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`)

- EXPLAIN 파라미터: `$1` = 1500, `$2` = 7 (이후 모든 사이클에서 동일하게 사용)
- 스캔 방식: `Parallel Seq Scan` (Workers Planned 2 / Launched 2), 사용 인덱스: 없음. 테이블의 유일한 인덱스는 `problem_submission_pkey`이고 이 쿼리는 쓰지 않는다
- actual rows 대 반환 행 수: 2,000 (667 × loops 3) / 7
- Rows Removed by Filter: 666,000 × loops 3 = 1,998,000
- shared hit / read: 전체 16,428 / 3,916 (20,344 페이지, 약 159 MB). 그중 스캔 노드가 15,960 / 3,916 = 19,876 페이지(97.7%)
- 플래너 추정 대 실측: 스캔 노드 rows=878 / actual rows=667 (loops당, 1.3배로 양호). `GroupAggregate` rows=108 / actual rows=9 (12배 괴리)
- 노드별 자기 몫(자식 시간을 뺀 값): `Parallel Seq Scan` 454.043 ms(96.0%), `Gather Merge` 13.156 ms, `GroupAggregate` 0.672 ms, `Sort`(unit_id) 0.487 ms
- 단독 실행 Execution Time 472.901 ms / Planning Time 16.181 ms. 부하 중 mean 563.81 ms와의 차이 90.91 ms(16.1%)가 경합분이다

### 적용 내용

- `src/main/resources/db/migration/V32__add_problem_submission_user_index.sql` 신규 — `CREATE INDEX IF NOT EXISTS ix_problem_submission_user_problem ON problem_submission (user_id, problem_id) INCLUDE (is_correct);`
- 자바 코드 변경 없음. 쿼리(`ProblemSubmissionRepository.findWeakUnitsByUserId`)는 그대로 두고 인덱스만 추가했다.
- 생성된 인덱스 크기: 77 MB (같은 테이블의 `problem_submission_pkey`는 86 MB)
- 테스트: `./gradlew test` 통과

### 개선 후 지표

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | med | 2746.709 ms | 73.341 ms | −97.3% |
| | p95 | 3598.58125 ms | 348.1099 ms | −90.3% |
| | p99 | 4014.4301499999997 ms | 786.4780999999994 ms | −80.4% |
| | RPS | 16.373709003628573 | 316.7888023679119 | 19.3배 |
| 하드웨어 독립 | 요청당 쿼리 수 | 4 | 4 | 변화 없음 |
| | 대상 쿼리 mean_ms | 563.81 | 4.60 | −99.2% |
| | 대상 쿼리 total_ms | 1108458.43 (요청 1966건) | 174706.22 (요청 38015건) | 요청당 563.81 → 4.60 |
| | 검사 행 / 반환 행 | 2,000,000 / 7 (285,714:1) | 2,000 / 7 (286:1) | Rows Removed by Filter 1,998,000 → 0 |
| | 스캔 방식 | `Parallel Seq Scan` | `Index Only Scan using ix_problem_submission_user_problem` (Heap Fetches 0) | |
| | 쿼리 전체 버퍼 | 20,344 페이지 (약 159 MB) | 119 페이지 (약 0.93 MB) | −99.4% |
| | 단독 Execution Time | 472.901 ms | 6.653 ms | −98.6% |
| | 캐시 hit / miss, 적중률 | - | - | - |

### 판정

- 개선 여부 (하드웨어 독립 증거 기준): **있음**
  - `Rows Removed by Filter` 1,998,000 → 0. 필요한 2,000행만 읽는다.
  - `Heap Fetches: 0` — `INCLUDE (is_correct)` 커버링이 성립해 힙 접근이 없다. correlation 0.0088에서 우려한 랜덤 접근 2,000회가 발생하지 않았다.
  - 쿼리 전체 버퍼 20,344 → 119 페이지.
  - 병렬 실행이 사라졌다(loops 3 → 1). `Gather Merge`, `Incremental Sort` 노드가 계획에서 제거됐다.
  - 플래너 추정이 정확해졌다: 스캔 노드 rows=1992 / actual rows=2000.
- 예상과의 대조
  - 맞은 것: `Parallel Seq Scan` → `Index Only Scan`, 검사 행 2,000,000 → 2,000. 예상 그대로다.
  - 빗나간 것: Phase 5-B에 유보로 적어둔 대로 `problem_id` 정렬이 집계까지 살아남지 못했다. `Sort Key: u1_0.id, c1_0.title`가 여전히 2,000행을 정렬하고(quicksort 220kB) `GroupAggregate`가 `COUNT(DISTINCT)` 중복 제거를 그대로 한다. 복합 키(`user_id, problem_id`)로 기대한 정렬 생략은 실현되지 않았다.
- 남은 위험 신호 (Phase 6 표 기준)
  - 검사 행 / 반환 행 286:1 — 100:1 기준을 여전히 초과한다
  - 플래너 추정 대 실측 괴리 — `GroupAggregate` 108 / 9 = 12배로 그대로다
  - 단일 쿼리 시간 비중 97.1% — 30% 기준을 여전히 초과한다
  - 해소됨: `problem_submission`의 Seq Scan
- 병목의 이동: DB 쿼리 시간의 합은 요청당 4.733 ms로, Little's Law 기준 평균 응답시간 157.8 ms(50 VU ÷ 316.789 RPS)의 3.0%다. 커넥션 풀 점유율도 92.3% → 15.0%로 내려갔다. 응답시간을 지배하는 것은 더 이상 DB 쿼리가 아니다.
- 다음 사이클 진행 여부: 종료. 남은 위험 신호 세 개는 모두 "DB 쿼리 안에서의 비율"이고, DB 쿼리는 이미 응답시간의 3.0%까지 내려왔다. 더 깎아도 157.8 ms 중 4.733 ms를 대상으로 하는 작업이 된다.

---

## 최종 요약

| 구분 | 지표 | 최초 | 최종 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | med | 2746.709 ms | 73.341 ms | −97.3% |
| | p95 | 3598.58125 ms | 348.1099 ms | −90.3% |
| | p99 | 4014.4301499999997 ms | 786.4780999999994 ms | −80.4% |
| | RPS | 16.373709003628573 | 316.7888023679119 | 19.3배 |
| 하드웨어 독립 | 요청당 쿼리 수 | 4 | 4 | 변화 없음 |
| | 요청당 대상 쿼리 시간 | 563.81 ms | 4.60 ms | −99.2% |
| | 검사 행 / 반환 행 | 2,000,000 / 7 (285,714:1) | 2,000 / 7 (286:1) | Rows Removed by Filter 1,998,000 → 0 |
| | 스캔 방식 | `Parallel Seq Scan` (Workers 2) | `Index Only Scan using ix_problem_submission_user_problem` (Heap Fetches 0) | |
| | 쿼리 전체 버퍼 | 20,344 페이지 (약 159 MB) | 119 페이지 (약 0.93 MB) | −99.4% |
| | 단독 Execution Time | 472.901 ms | 6.653 ms | −98.6% |
| | 커넥션 풀 점유율 | 92.3% | 15.0% | |
| | 캐시 hit / miss, 적중률 | - | - | - |

적용한 기법: 사이클 1 — `problem_submission (user_id, problem_id) INCLUDE (is_correct)` 커버링 인덱스 추가 (`V32__add_problem_submission_user_index.sql`)

종료 사유: 하드웨어 독립 증거로 개선이 확인되었고, DB 쿼리가 응답시간의 3.0%까지 내려와 병목이 DB 밖으로 이동했다. 남은 위험 신호(검사 행 286:1, `GroupAggregate` 추정 괴리 12배, 시간 비중 97.1%)는 호출자 판단으로 남긴다.
