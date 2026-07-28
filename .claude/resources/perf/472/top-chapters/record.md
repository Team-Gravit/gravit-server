# [PERF-472] GET /api/v1/my-pages/learning/top-chapters

> 이슈: #472
> 브랜치: refactor/472-mypage-learning-performance
> 대상 디렉토리: `.claude/resources/perf/472/top-chapters/`

이 파일은 대상 엔드포인트 하나만 다룬다. 같은 이슈의 다른 엔드포인트는 각자의 디렉토리에 각자의 `record.md`를 가진다.

## 진행 상태

> ⏳ 미완 / ✅ 완료 / ⏭️ 건너뜀
> 재진입 시 ⏳로 표기된 가장 이른 Phase부터 재개한다.

**준비 (대상당 1회)**

| 1. 대상 | 2. 환경 | 3. 조건 | 4. 기준선 |
|---|---|---|---|
| ✅ | ⏭️ | ✅ | ✅ |

**사이클 (반복)**

| # | 기법 | 5. 설계 | 6. 스냅샷 | 7. 적용 | 8. 검증 |
|---|---|---|---|---|---|
| 1 | `lesson_submission (user_id, created_at) INCLUDE (lesson_id)` 커버링 인덱스 | ✅ | ✅ | ✅ | ✅ |

## 대상

- 엔드포인트: `GET /api/v1/my-pages/learning/top-chapters`
- 실행 경로: `MyPageController:61-64` → (Facade 없음) → `LessonSubmissionQueryService:69-91` → `LessonSubmissionRepository` (메서드 2개)
- 예상 쿼리 목록 (요청 1회 기준)
  1. `LessonSubmissionRepository.findTopChaptersByUserIdInWeek` (`:98-117`) - `lesson_submission → lesson → unit → chapter` 조인 후 챕터 단위 집계. `GROUP BY c.id, c.title`, `ORDER BY COUNT(DISTINCT l.id) DESC, c.id ASC`, `LIMIT 3`
  2. `LessonSubmissionRepository.countSolvedLessonsByUserIdInWeek` (`:119-130`) - `SELECT COUNT(DISTINCT ls.lessonId)`. 조인 없음
  - **두 쿼리는 `WHERE ls.userId = ? AND ls.createdAt >= ? AND ls.createdAt < ?`를 공유한다.** 같은 파라미터(`Service:71-72`의 `weekStart`, `nextWeekStart`)로 같은 행 집합을 두 번 훑는다
  - 지연 로딩 지점 없음. 둘 다 DTO projection과 스칼라를 반환한다
  - `Service:82-88`의 응답 조립 루프는 메모리 작업이다
- 트랜잭션: 두 Repository 호출이 `getTopChapters`의 `@Transactional(readOnly = true)`(`Service:69`) 하나 안에 있다. 대상 트랜잭션은 1개다
- 대상 밖에서 붙는 쿼리 (진단 시 대상 쿼리와 분리해 읽는다)
  - `users` SELECT 2회 - `JwtAuthFilter:78`, `:81`이 각각 `AuthTokenProvider:71`의 `userRepository.findById`를 탄다
  - `users` UPDATE 1회 - `LastAccessInterceptor.preHandle` → `UserAccessService.updateLastAccessed` → `UserRepository.updateLastAccessedAt`
- 요청당 총 쿼리 예상: 5개 (대상 2 + `users` SELECT 2 + `users` UPDATE 1). 트랜잭션은 4개 (`BEGIN READ ONLY` 3 + `BEGIN` 1)

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf |
| 커넥션 풀 크기 | 10 (`application-perf.yml:14`) |
| 데이터 규모 | `lesson_submission` 300,000 (유저 1,000명 × 300행) / `lesson` 130 / `unit` 65 / `chapter` 5 / `users` 1,000 (id 1001~2000) |
| 카디널리티 | `ls.user_id` 1,000 (유저당 300행) / 유저당 서로 다른 레슨 100개 / `created_at` 180일 / 유저당 최근 7일 구간 100행 |
| 주간 구간 실측 | 유저 1500 기준 30행 / 서로 다른 레슨 30개 / 서로 다른 챕터 5개. 시드가 최근 7일에 100행을 뿌리는데 이번 주는 월, 화 이틀뿐이라 그중 2/7이 걸린다. 레슨 중복 제출이 없어 `COUNT(DISTINCT l.id)`가 단순 `COUNT`와 같은 값을 낸다. 챕터 5개 중 `LIMIT 3`이 2개를 잘라낸다 |
| 기존 인덱스 | `lesson_submission_pkey` PRIMARY KEY btree (id) **하나뿐**. `user_id`, `created_at` 어디에도 인덱스가 없다 |
| 부하 조건 | VU 50, duration 1m (ramp-up 30s + 1m + ramp-down 30s). 이슈 내 3개 대상 공통 |
| 캐시 상태 | cold (measure 직전 FLUSHDB). 현재 실행 경로에 캐시 없음 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` |
| DB 접속 | `PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d mydb` |
| 시드 SQL | `../seeds.sql` (이슈 공용, `weak-concepts` 대상에서 적재 완료) |
| 시드 모듈과 변수 | `learning.sql`의 `lesson_sub_per_user 300`, `distinct_lessons 100`, `recent_days 7`, `recent_count 100`, `window_days 180`, `user_start 1001`, `user_count 1000` |
| 선행 대상의 코드 변경 | `weak-concepts` 사이클 1의 `V32__add_problem_submission_user_index.sql`이 적용된 상태다. 대상 테이블이 `problem_submission`이라 이번 쿼리(`lesson_submission`)와 무관하다. `weekly-report`는 사이클을 돌지 않아 코드 변경이 없다 |

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| med | 1146.894 ms |
| p95 | 2150.9488 ms |
| p99 | 3078.142259999996 ms |
| max | 5049.652 ms |
| RPS | 33.043953155652545 |
| 요청 수 | 3967 (측정 구간 실경과 120.05초) |
| 에러율 | 0 |
| check 통과율 | 1 (3항목 전부 3967/3967) |
| 요청당 쿼리 수 | 5 (대상 2 + `users` SELECT 2 + `users` UPDATE 1), 트랜잭션 4 (`BEGIN READ ONLY` 3 + `BEGIN` 1) |

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.txt` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 1.00 | 118.14 | 468657.82 | 50.8% | `LessonSubmissionRepository.countSolvedLessonsByUserIdInWeek` |
| 1.00 | 114.19 | 453005.32 | 49.1% | `LessonSubmissionRepository.findTopChaptersByUserIdInWeek` |
| 2.00 | 0.10 | 802.04 | 0.1% | `AuthTokenProvider.parseUser` |

### 진단

- 병목 성격: 같은 조건절을 쓰는 두 대상 쿼리가 `lesson_submission`을 각각 훑는 데서 오는 스캔 비용. 커넥션 풀 포화는 그 증상이다.
- 근거
  - 두 대상 쿼리가 요청당 각각 1.00회로 전체 DB 시간의 **99.9%**(50.8% + 49.1%)를 차지한다. 호출 수는 예상과 일치하므로 N+1이 아니다.
  - 두 쿼리는 `WHERE ls.user_id = ? AND ls.created_at >= ? AND ls.created_at < ?`를 같은 파라미터로 공유한다. 같은 행 집합을 요청당 두 번 훑는다.
  - **두 쿼리의 mean이 118.14와 114.19로 3.95 ms(3.3%)밖에 차이나지 않는다.** 쿼리 2는 쿼리 1이 하는 일을 전부 하고 그 위에 `lesson`, `unit`, `chapter` 3단 조인과 `GROUP BY`와 `ORDER BY` + `LIMIT`을 더 하는데도 오히려 3.95 ms 빠르다. 조인 상대가 각각 130, 65, 5행으로 작아서 조인, 집계, 정렬의 비용이 측정 노이즈에 묻힌다. 두 쿼리의 시간은 사실상 전부 공유하는 스캔에서 나온다. 따라서 조인 축소나 집계 재작성은 살 것이 없다.
  - `lesson_submission`의 인덱스는 `lesson_submission_pkey`(PK, id) 하나뿐이다. `user_id`, `created_at` 어디에도 인덱스가 없다. (전체 스캔 여부는 Phase 6의 `EXPLAIN`에서 확정한다)
  - 요청당 DB 시간 232.67 ms는 측정 구간에 쓸 수 있는 커넥션-시간 총량(풀 10 × 120,050 ms = 1,200,500 ms)의 **76.9%**를 점유한다.
  - 풀이 허용하는 최대 처리량은 10 ÷ 0.23267s = 42.98 RPS이고 실측은 33.043953155652545다. 요청당 커넥션 점유 시간은 10 ÷ 33.044 = 302.7 ms로 쿼리 실행 시간 232.67 ms보다 70 ms 길다. 두 쿼리가 하나의 `@Transactional(readOnly = true)`(`LessonSubmissionQueryService:69`) 안에 묶여 있어 커넥션을 그만큼 더 붙잡는다.
  - Little's Law로 계산한 평균 응답시간은 50 ÷ 33.044 = 1513.1 ms이고 실측 med 1146.894 ~ p95 2150.9488 구간과 부합한다.
  - 규모 교차 검증: `weak-concepts`(2,000,000행)의 쿼리 mean 563.81 ms 대비 이 대상(300,000행)은 116.17 ms다. 행 수 6.67배에 시간 4.85배로 대략 비례하며, 비용이 테이블 전체 스캔에 붙어 있다는 추론과 부합한다.
- 예상 쿼리 목록과 어긋난 지점: 없음. 대상 쿼리 2개가 각각 1.00회, `rows_per_call` 3.0과 1.0, `BEGIN READ ONLY` 3.00, 요청당 총 5개로 전부 예상과 일치했다.

---

## 사이클 1: `lesson_submission` 커버링 인덱스 추가

### 설계 결정

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 대상 컬럼과 순서 | `(user_id, created_at) INCLUDE (lesson_id)` | 두 대상 쿼리가 `lesson_submission`에서 쓰는 컬럼이 `user_id`, `created_at`, `lesson_id` 셋으로 정확히 같다. 인덱스 하나가 두 쿼리를 동시에 덮는다 |
| 등호와 범위의 순서 | `user_id`(등호)를 `created_at`(범위)보다 앞 | B-tree는 선두 키부터 탐색한다. `(created_at, user_id)`였다면 7일 구간에 걸리는 전 유저의 행(180일 중 7일 = 약 4%, 12,000행)을 훑고 30행만 남겨야 한다 |
| 커버링 여부 | 커버링 | `user_id` correlation −0.0068836696로 한 유저의 300행이 테이블 전역에 흩어져 있다. 커버링이 아니면 쿼리당 힙 랜덤 접근 30회, 요청당 두 쿼리 합쳐 60회가 발생한다 |
| 부분 인덱스 조건 | 없음 | `created_at`이 nullable이지만 `null_frac`이 0이라(`V29`가 NULL을 채웠다) 걸러낼 행이 없다. 최근 N주로 제한하면 주기적 재생성이 필요해진다 |
| 생성 방식 | `CREATE INDEX` (CONCURRENTLY 아님) | Flyway가 PostgreSQL 마이그레이션을 트랜잭션으로 감싼다. `weak-concepts` 사이클 1과 동일 |
| 감수할 쓰기 비용 | INSERT당 인덱스 엔트리 삽입 1회 추가 | 이 테이블의 인덱스는 PK 1개뿐이었다. `V29`로 제출마다 행을 쌓는 이력 구조가 되어 INSERT 빈도가 높다 |

- 검토했지만 택하지 않은 안
  - `(user_id, created_at, lesson_id)` — `lesson_id`가 범위 컬럼 뒤 세 번째 키라 `created_at`이 같은 행들 사이에서만 정렬된다. 그런데 `created_at`의 n_distinct가 300이고 유저당 행 수도 300이라 `(user_id, created_at)` 조합이 유저당 유일하다. 정렬할 대상이 없어 얻는 것 없이 인덱스만 커진다
  - `(user_id, created_at)` (커버링 없음) — 인덱스가 가장 작지만 요청당 힙 랜덤 접근 60회를 남긴다
  - `(created_at, user_id)` — 선택도에서 탈락. `created_at`의 correlation −0.788로 물리적 지역성은 좋지만 읽는 행이 12,000행이 된다
  - 두 쿼리를 하나로 합치기 — 사이클 2 후보. 한 사이클에 한 기법만 적용한다
  - 전체 카운트를 메모리에서 계산 — `LIMIT 3`이 걸려 상위 3개 챕터의 합은 주간 전체 레슨 수가 아니다. `TopChapterResponse.of`의 `ratio` 분모가 바뀌어 결과값이 달라진다
- 호출자가 예상한 효과: `Seq Scan` → `Index Only Scan`, 검사 행 300,000 → 30
- 범위 밖 사실: `LessonSubmissionRepository`의 다른 메서드(`countDistinctLessonByUserId`, `getTotalLearningTime`, `getAverageAccuracy`, `getPeakLearningHour`)도 `user_id`로 거르므로 이 인덱스를 쓸 수 있다. 그 엔드포인트들은 기준선을 잡지 않았으므로 효과를 주장하지 않는다

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 2150.9488 ms / 3078.142259999996 ms |
| RPS | 33.043953155652545 |
| 요청당 쿼리 수 | 5 (대상 2 + `users` SELECT 2 + `users` UPDATE 1) |
| 대상 쿼리 ① `countSolvedLessonsByUserIdInWeek` calls / mean_ms / total_ms | 3967 / 118.14 / 468657.82 |
| 대상 쿼리 ② `findTopChaptersByUserIdInWeek` calls / mean_ms / total_ms | 3967 / 114.19 / 453005.32 |

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`). 대상 쿼리가 2개이므로 한 파일에 두 계획을 덧붙인다.

- EXPLAIN 파라미터: `user_id` = 1500, `weekStart` = `'2026-07-27 00:00:00'`, `nextWeekStart` = `'2026-08-03 00:00:00'`, `LIMIT` = 3 (이후 모든 사이클에서 동일하게 사용)
- 스캔 방식: 두 쿼리 모두 `lesson_submission`에 `Parallel Seq Scan` (Workers Planned 2 / Launched 2). 사용 인덱스 없음
- actual rows 대 반환 행 수: [1] 30 / 1, [2] 30 / 3
- Rows Removed by Filter: 두 쿼리 각각 99,990 × loops 3 = **299,970**. 요청당 두 쿼리 합쳐 599,940행을 읽고 버린다
- shared hit / read: 스캔 노드가 두 쿼리 각각 6,186 / 0. 전체는 [1] 6,194 / 0, [2] 6,250 / 0. 요청당 12,372 페이지(약 97 MB)를 훑는다. 전부 `shared hit`이라 디스크 I/O가 아니라 CPU 필터링 비용이다
- 플래너 추정 대 실측: 스캔 노드 rows=19 / actual rows=10 (loops당). [2]의 `GroupAggregate` rows=5 / actual rows=5로 정확
- 노드별 자기 몫 ([2], 자식 총 시간을 뺀 값): `Parallel Seq Scan` 8.331 ms, `Gather` 5.494 ms → 둘이 13.825 ms로 Execution 14.547 ms의 **95.0%**. 나머지는 `Nested Loop`(바깥) 0.201 ms, `Materialize` 0.086 ms, `Sort` 0.069 ms, `GroupAggregate` 0.045 ms로 합쳐 0.42 ms다. [1]은 `Gather` 41.143 ms가 Execution 41.696 ms의 98.7%
- 조인 비용이 없다는 증거: [2]의 `Rows Removed by Join Filter`는 바깥 Nested Loop 1,920(조합 65 × 30 = 1,950 중), 안쪽 260(조합 5 × 65 = 325 중)으로 전수 검사를 하지만 자기 몫은 0.201 ms와 0.074 ms다. `Materialize`의 `loops=65`는 총 14.105 ms로 보이나 그중 14.019 ms가 자식(스캔)의 시간이다
- 단독 실행 대 부하 중 mean: [1] 41.696 → 118.14 ms (2.83배), [2] 14.664 → 114.19 ms (7.79배). `weak-concepts`의 1.19배보다 격차가 크다. 두 계획 모두 워커 2개를 띄우는데, 부하 중에는 커넥션 10개가 동시에 워커를 요청하고 `max_parallel_workers` 기본값이 8이라 대부분의 쿼리가 워커 없이 단독으로 300,000행을 훑게 된다

### 적용 내용

- `src/main/resources/db/migration/V33__add_lesson_submission_user_week_index.sql` 신규 — `CREATE INDEX IF NOT EXISTS ix_lesson_submission_user_created_at ON lesson_submission (user_id, created_at) INCLUDE (lesson_id);`
- 자바 코드 변경 없음. 두 쿼리(`countSolvedLessonsByUserIdInWeek`, `findTopChaptersByUserIdInWeek`)는 그대로 두고 인덱스만 추가했다.
- 생성된 인덱스 크기: 12 MB (같은 테이블의 `lesson_submission_pkey`는 13 MB)
- 테스트: `./gradlew test` 통과

### 개선 후 지표

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | med | 1146.894 ms | 52.525000000000006 ms | −95.4% |
| | p95 | 2150.9488 ms | 204.26199999999992 ms | −90.5% |
| | p99 | 3078.142259999996 ms | 602.1914799999989 ms | −80.4% |
| | RPS | 33.043953155652545 | 473.3459528921028 | 14.3배 |
| 하드웨어 독립 | 요청당 쿼리 수 | 5 | 5 | 변화 없음 |
| | 대상 쿼리 ① `countSolvedLessonsByUserIdInWeek` mean_ms | 118.14 | 0.04 | −99.97% |
| | 대상 쿼리 ② `findTopChaptersByUserIdInWeek` mean_ms | 114.19 | 0.29 | −99.75% |
| | 요청당 DB 시간 | 232.67 ms | 0.4316 ms | −99.81% |
| | 커넥션 풀 점유율 | 76.9% | 2.04% | |
| | 검사 행 / 반환 행 | 300,000 / 1 (100,000:1), 300,000 / 3 | 30 / 1 (30:1), 30 / 3 (10:1) | Rows Removed by Filter 599,940 → 0 |
| | 스캔 방식 | `Parallel Seq Scan` ×2 | `Index Only Scan using ix_lesson_submission_user_created_at` ×2 (Heap Fetches 0) | |
| | 쿼리 전체 버퍼 | 12,444 페이지 (약 97 MB) | 25 페이지 (약 0.2 MB) | −99.8% |
| | 단독 Execution Time | [1] 41.696 ms, [2] 14.664 ms | [1] 0.628 ms, [2] 0.952 ms | −98.5%, −93.5% |
| | 캐시 hit / miss, 적중률 | - | - | - |

### 판정

- 개선 여부 (하드웨어 독립 증거 기준): **있음**
  - 두 쿼리 모두 `Parallel Seq Scan` → `Index Only Scan`으로 전환됐고 `Index Cond`에 `user_id` 등호와 `created_at` 범위가 함께 들어갔다. 등호를 선두 키로 둔 설계가 의도대로 동작했다.
  - `Rows Removed by Filter` 599,940 → 0. 필요한 30행만 읽는다.
  - `Heap Fetches: 0` (두 쿼리 모두) — `INCLUDE (lesson_id)` 커버링이 성립해 힙 접근이 없다. `user_id` correlation −0.0069에서 우려한 요청당 랜덤 접근 60회가 발생하지 않았다.
  - 쿼리 전체 버퍼 12,444 → 25 페이지.
  - 플래너 추정이 정확해졌다: 스캔 노드 rows=28 / actual rows=30.
  - 계획 구조가 세 군데 바뀌었다. `Nested Loop` + `Join Filter`(조합 1,950개·325개 전수 검사) → `Hash Join` + `Hash Cond`(Rows Removed 0), `Materialize`(loops=65) 제거, 병렬 실행 제거(loops 3 → 1). 이는 설계한 것이 아니라 인덱스의 결과다. 입력 행 추정이 45 → 28로 내려가자 플래너가 해시 조인을 골랐다.
- 예상과의 대조: 예상은 `Seq Scan` → `Index Only Scan`, 검사 행 300,000 → 30이었고 둘 다 정확히 맞았다.
- 예상하지 못했던 것: 두 대상 쿼리의 순위가 뒤바뀌었다. 개선 전 ① 118.14 / ② 114.19(0.97배)에서 개선 후 ① 0.04 / ② 0.29(7.25배)가 됐다. Phase 4에서 "두 쿼리 시간 차이가 3.3%뿐이므로 조인, 집계 비용은 노이즈에 묻혀 있고 시간은 전부 공유 스캔에서 나온다"고 판정했는데, 공유 스캔을 걷어내자 그 아래 있던 차이가 드러났다. 그 판정에 대한 사후 확인이다.
- 남은 위험 신호 (Phase 6 표 기준)
  - 단일 쿼리 시간 비중 66.4% — 30% 기준을 여전히 초과한다
  - 해소됨: 검사 행 / 반환 행(100,000:1 → 30:1, 10:1), 플래너 추정 괴리(28 / 30), `lesson_submission`의 Seq Scan
- 병목의 이동: 요청당 DB 시간 0.4316 ms는 Little's Law 기준 평균 응답시간 105.63 ms(50 VU ÷ 473.346 RPS)의 0.41%다. 커넥션 풀 점유율도 76.9% → 2.04%로 내려갔다. `weekly-report`(0.18%)와 같은 상태에 도달했다.
- 다음 사이클 진행 여부: 종료. 남은 위험 신호는 시간 비중 66.4% 하나이고, 그 분모인 전체 DB 시간이 이미 풀 용량의 2.04%, 응답시간의 0.41%까지 내려왔다. 사이클 2 후보였던 "두 쿼리 합치기"는 쿼리 ①(0.04 ms)을 제거해 요청당 DB 시간을 0.4316 → 0.39 ms로 줄이는 것이라, 응답시간 105.63 ms 기준 0.04% 개선에 그친다.

---

## 최종 요약

| 구분 | 지표 | 최초 | 최종 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | med | 1146.894 ms | 52.525000000000006 ms | −95.4% |
| | p95 | 2150.9488 ms | 204.26199999999992 ms | −90.5% |
| | p99 | 3078.142259999996 ms | 602.1914799999989 ms | −80.4% |
| | RPS | 33.043953155652545 | 473.3459528921028 | 14.3배 |
| 하드웨어 독립 | 요청당 쿼리 수 | 5 | 5 | 변화 없음 |
| | 요청당 대상 쿼리 시간 합 | 232.33 ms | 0.33 ms | −99.86% |
| | 요청당 DB 시간 | 232.67 ms | 0.4316 ms | −99.81% |
| | 검사 행 / 반환 행 | 300,000 / 1 (100,000:1), 300,000 / 3 | 30 / 1 (30:1), 30 / 3 (10:1) | Rows Removed by Filter 599,940 → 0 |
| | 스캔 방식 | `Parallel Seq Scan` ×2 | `Index Only Scan using ix_lesson_submission_user_created_at` ×2 (Heap Fetches 0) | |
| | 쿼리 전체 버퍼 | 12,444 페이지 (약 97 MB) | 25 페이지 (약 0.2 MB) | −99.8% |
| | 커넥션 풀 점유율 | 76.9% | 2.04% | |
| | 캐시 hit / miss, 적중률 | - | - | - |

적용한 기법: 사이클 1 — `lesson_submission (user_id, created_at) INCLUDE (lesson_id)` 커버링 인덱스 추가 (`V33__add_lesson_submission_user_week_index.sql`, 12 MB)

종료 사유: 하드웨어 독립 증거로 개선이 확인되었고, DB 쿼리가 응답시간의 0.41%까지 내려와 병목이 DB 밖으로 이동했다. 남은 위험 신호(시간 비중 66.4%)는 호출자 판단으로 남긴다.

## 인계 사항

- 두 대상 쿼리가 같은 `WHERE ls.user_id = ? AND ls.created_at >= ? AND ls.created_at < ?`를 공유하며 요청당 각각 1회씩 수행되는 구조는 그대로다. 인덱스로 각 스캔이 30행으로 줄어 실익이 사라졌을 뿐, 구조 자체는 남아 있다. 데이터 규모가 크게 늘면 다시 후보가 된다.
- 이 인덱스는 `LessonSubmissionRepository`의 다른 메서드(`countDistinctLessonByUserId`, `getTotalLearningTime`, `getAverageAccuracy`, `getPeakLearningHour`)도 쓸 수 있다. 그 엔드포인트들은 기준선을 잡지 않았으므로 효과를 주장하지 않는다.
