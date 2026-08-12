# [PERF-492] GET /api/v1/bookmarks/{unitId}

> 이슈: #492
> 브랜치: refactor/492-bookmark-wrong-note-query-performance
> 대상 디렉토리: `.claude/resources/perf/492/bookmarks/`

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
| 1 | `bookmark (user_id, problem_id)` UNIQUE 인덱스 추가 | ✅ | ✅ | ✅ | ✅ |

## 대상

- 엔드포인트: `GET /api/v1/bookmarks/{unitId}`
- 실행 경로: `JwtAuthFilter` → `BookmarkController` → `BookmarkFacade` → (`UnitQueryService`, `BookmarkService`, `ProblemFactory`) → 각 Repository
- 트랜잭션 경계: `BookmarkFacade.getAllBookmarkedProblemInUnit`에 `@Transactional(readOnly = true)` 단일
- 예상 쿼리 목록 (요청 1회 기준, 고정 3~5개)
  1. `UserRepository.findById` - `users` PK 단건 조회. 인증 필터(`AuthTokenProvider:70`)에서 발생. 대상 API 밖에서 붙는 쿼리
  2. `UnitRepository.findUnitSummaryById` - `Unit` 단일 테이블 PK 조회, DTO 프로젝션
  3. `BookmarkRepository.findBookmarkedProblemDetailByUnitIdAndUserId` - `Bookmark ⋈ Problem ⋈ Lesson ⋈ Unit` 4테이블 조인, `WHERE u.id = ? AND b.userId = ?`, `ORDER BY b.createdAt ASC`
  4. `AnswerRepository.findByProblemIdIn` - 결과에 SUBJECTIVE 문제가 있을 때만 1회 (`ProblemFactory:25`)
  5. `OptionRepository.findAllByProblemIdIn` - 결과에 OBJECTIVE 문제가 있을 때만 1회 (`ProblemFactory:26`)

- 지연 로딩 추가 쿼리 후보: 없음. 2~5번 모두 `SELECT new ...Response(...)` DTO 프로젝션이라 엔티티를 반환하지 않는다
- N+1 후보: 없음. `ProblemFactory.create`가 문제 타입별로 ID를 모아 `IN` 절 배치 조회 2회로 끝낸다. 북마크된 문제 개수가 늘어도 쿼리 수는 늘지 않는다
- 사전 관찰(미검증): `bookmark` 테이블에 `user_id` 인덱스가 없다(`V1__init_tables.sql:43`). `wrong_answered_note`는 `V34`에서 `(user_id, problem_id)` 유니크 인덱스가 추가되어 있다

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application="gravit-perf"` 확인) |
| 커넥션 풀 크기 | 60 (`application-perf.yml` `maximum-pool-size`) |
| 데이터 규모 | `bookmark` 156,000 / `problem` 6,900 / `option` 13,800 / `answer` 3,450 / `lesson` 230 / `unit` 66 / `users` 1,002. 대상 유닛 900002는 문제 60건(OBJECTIVE 30, SUBJECTIVE 30) |
| 카디널리티 | `bookmark.user_id` 1,000 (유저당 156행) / `bookmark.problem_id` 6,870 / `bookmark.created_at` 행마다 다른 값 (유저 내 1초 간격). 요청당 결과 30건 (OBJECTIVE 15, SUBJECTIVE 15) |
| 부하 조건 | VU 50, 유지 1m (ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m). #490과 동일 조건 |
| Redis 캐시 상태 | cold (measure 직전 FLUSHDB). 단 이 API는 Redis를 쓰지 않는다 |
| DB 캐시 상태 | 제어하지 않음. Redis FLUSHDB는 PostgreSQL의 `shared_buffers`와 OS page cache를 비우지 않는다 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` (PONG 확인) |
| 시드 SQL | `../seeds.sql` (이슈 공용) |
| 시드 모듈과 변수 | `review.sql` (신규 모듈, `answer`/`option`/`bookmark`). `user_start` 1001, `user_count` 1000, `target_unit_id` 900002, `bookmarks_per_user` 156, `target_unit_bookmarks_per_user` 30, `options_per_problem` 4. `content.sql`, `user.sql`은 이미 목표 규모라 부르지 않음 |
| DB 접속 | `PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d mydb` (5433은 컨테이너 5432 매핑) |
| 관측 도구 | `pg_stat_statements` 유효 (49행), 히스토그램 버킷 146개 노출 |

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| p95 | 473.056ms |
| p99 | 719.1027999999997ms |
| RPS | 166.1613138464495 |
| 에러율 | 0 |
| check 통과율 | 1 (19941/19941, 3개 항목 전부) |
| 요청당 쿼리 수 | 6 (트랜잭션 제어문 제외). 트랜잭션은 요청당 3개 (`BEGIN READ ONLY` 2 + `BEGIN` 1.0046) |

- med 219.35ms / max 1784.57ms / 요청 19941건

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.md` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 1.00 | 101.58188398951914 | 2025644.3486349937 | 91.2000115838526% | `BookmarkRepository.findBookmarkedProblemDetailByUnitIdAndUserId` |
| 1.00 | 7.867449813650273 | 156884.8167340002 | 7.063380653722835% | `OptionRepository.findAllByProblemIdIn` |
| 1.00 | 1.5959442353944158 | 31824.723998000096 | 1.432835531679759% | `AnswerRepository.findByProblemIdIn` |

### 진단

- 병목 성격: 쿼리 자체 비효율. 호출 횟수가 아니라 단일 쿼리 1건의 실행 비용이 문제다
- 근거:
  - `findBookmarkedProblemDetailByUnitIdAndUserId` 1건이 총 실행시간의 91.2%(2,025,644ms)를 차지한다. 나머지 11개 쿼리의 합이 8.8%다
  - 그 쿼리의 요청당 호출 수는 1.00으로 예상과 같다. N+1이 아니다
  - 행/호출이 30으로 시드한 결과 크기와 정확히 일치한다. 30행을 반환하는 데 mean 101.58ms를 쓴다. 반환 행 수 대비 실행시간이 과도하므로 내부에서 만지는 행이 30행보다 훨씬 많다고 볼 근거가 된다 (검사 행 수는 Phase 6 실행계획에서 확인)
  - 2위 `option` 조회는 mean 7.87ms로 1위와 12.9배 차이다
- 예상 쿼리 목록과 어긋난 지점:
  - `UPDATE users SET last_accessed_at`이 요청당 1.00회 나간다. 예상 목록에 없었다. 출처는 `LastAccessInterceptor.preHandle` → `UserAccessService.updateLastAccessed`로, Controller보다 앞단의 인터셉터라 실행 경로 추적에서 빠졌다. 읽기 엔드포인트에 쓰기가 1회 섞인다. 비중은 0.057%
  - `BEGIN READ ONLY`가 요청당 2.00회다. 트랜잭션 경계를 `BookmarkFacade` 하나로 봤으나 실제로는 둘이다

---

## 사이클 1: `bookmark (user_id, problem_id)` UNIQUE 인덱스 추가

### 설계 결정

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 대상 컬럼, 순서 | `(user_id, problem_id)` | `user_id`를 선두 키로 두면 156,000행이 156행으로 좁는다(선택도 0.1%). `problem_id`는 조인 키라 인덱스에 있으면 힙까지 가지 않고 꺼낼 여지가 생긴다 |
| 유니크 여부 | UNIQUE | 북마크는 유저와 문제 단위로 하나만 존재하는 도메인 제약이다. 코드도 이미 그 전제로 동작한다 - `addBookmark`가 중복 시 `BOOKMARK_DUPLICATED`를 던지고 `deleteByProblemIdAndUserId`가 그 쌍으로 단건을 지운다. 검사와 저장 사이의 경쟁으로 중복 행이 생기는 것을 DB가 막는다 |
| 부분 인덱스 조건 | 없음 | `bookmark`에 soft delete도 상태 컬럼도 없어(`id`, `created_at`, `problem_id`, `user_id`가 전부) 항상 걸리는 필터 조건이 없다 |
| 커버링 | 없음 | `INCLUDE (created_at)`은 힙 접근만 줄이고 Sort 노드는 남긴다. 힙 접근 156회가 실제로 비싼지 모르는 상태에서 컬럼을 늘리지 않는다. Phase 6의 `shared hit/read`를 보고 크다고 판단되면 사이클 2에서 다룬다 |
| 감수할 쓰기 비용 | 북마크 추가, 삭제 시 인덱스 갱신 1건 | 북마크 쓰기는 사용자당 산발적이고, 같은 인덱스가 `existsByProblemIdAndUserId`와 `deleteByProblemIdAndUserId`의 순차 스캔을 없애 쓰기 경로 자체도 빨라진다 |

- 검토했지만 택하지 않은 안:
  - `(user_id, created_at, problem_id)` - Sort 노드까지 없앨 수 있으나, 91.2%를 만든 원인은 정렬이 아니라 156,000행 스캔이다. 정렬 비용을 재보지 않은 상태에서 컬럼을 늘리지 않는다
  - 조인 축소(`unit` 조인 제거) - 사이클 2 이후 후보
  - 결과 캐싱 - 무효화 경로가 둘(추가, 삭제)이고 복잡도가 크다. 쿼리 튜닝으로 부족할 때 꺼낸다
  - `LastAccessInterceptor`의 `UPDATE users` 제거 - 비중 0.057%로 이번 병목과 무관하다. 별도 이슈 사안
- 대상 API 밖의 부수 효과: `existsByProblemIdAndUserId`, `deleteByProblemIdAndUserId`, `countByUnitIdAndUserId`가 모두 `user_id`로 걸러 이 인덱스를 탄다
- 호출자가 예상한 효과: `bookmark`의 스캔 방식이 Seq Scan에서 Index Scan으로 바뀐다

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 473.056ms / 719.1027999999997ms |
| RPS | 166.1613138464495 |
| 요청당 쿼리 수 | 6 (트랜잭션 제어문 제외) |
| 대상 쿼리 calls / mean_ms / total_ms | 19941 / 101.58188398951914 / 2025644.3486349937 (91.2%) |

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`)

- EXPLAIN 파라미터: `$1` = 900002 (대상 유닛), `$2` = 1500 (유저 1001~2000의 중앙값). 이후 모든 사이클에서 동일하게 사용
- 스캔 방식: `bookmark`는 Seq Scan, 사용 인덱스 없음 (Filter `user_id = 1500`). `problem`, `lesson`, `unit`도 Seq Scan
- actual rows 대 반환 행 수: `bookmark` 노드가 156행을 내보내고 쿼리는 30행을 반환한다. 노드가 읽은 행은 156,000
- Rows Removed by Filter: `bookmark` 155,844 (읽은 것의 99.9%), `unit` 회당 65 (loops 30이므로 총 1,950), `lesson` 228
- shared hit / read: 최상단 누적 1306 / 0 (10.2MB). 이 중 `bookmark` 노드 몫이 1148 (87.9%, 9.18MB)
- 플래너 추정 대 실측: `bookmark` Seq Scan은 rows=155 대 실측 156으로 정확하다. Hash Join(b⋈p)이 rows=1로 추정했으나 실측 30으로 30배 괴리다. 유닛 필터와 유저 필터의 상관관계를 플래너가 독립으로 가정한 결과이고, 이번 인덱스와는 별개 사안이다
- Planning Time 3.020ms / Execution Time 14.585ms (단건). 부하 중 mean 101.582ms와의 차이는 VU 50의 경합분이다

**노드별 자기 몫** (누적 actual time에서 자식 몫을 뺀 값, loops 반영)

| 노드 | 자기 몫 (ms) | Execution Time 대비 |
|---|---|---|
| Seq Scan `bookmark` | 12.258 | 84.0% |
| Hash Join (p⋈l) | 1.069 | 7.3% |
| Seq Scan `problem` | 0.889 | 6.1% |
| Seq Scan `unit` | 0.09 (0.003 × loops 30) | 0.6% |
| 나머지 전부 | 0.170 | 1.2% |

**위험 신호 판정**

| 지표 | 값 | 기준 | 판정 |
|---|---|---|---|
| 검사 행 / 반환 행 | 156,000 / 30 = 5,200:1 | 100:1 초과 | 초과 |
| 단일 쿼리 total_exec_time 점유율 | 91.2% | 30% 이상 | 초과 |
| 1만 행 이상 테이블의 Seq Scan | `bookmark` 156,000행 | 신호 | 해당 |
| 플래너 추정 대 실측 | Hash Join 1 대 30 | 10배 이상 | 초과 |
| 동일 쿼리의 요청당 호출 횟수 | 1.00 | 1회 초과면 N+1 | 해당 없음 |

- 확정 해석: `bookmark`의 Seq Scan이 비용을 먹는 노드다. 시간 기준 84.0%, 페이지 기준 87.9%로 두 지표가 같은 노드를 가리킨다. 156,000행을 읽어 155,844행(99.9%)을 버리고 156행만 남긴다

### 적용 내용

- `src/main/resources/db/migration/V38__add_bookmark_user_problem_unique_index.sql` 신규 - `bookmark (user_id, problem_id)` UNIQUE 인덱스 추가
- 코드 변경은 마이그레이션 1건뿐이다. Repository, Service, Facade는 손대지 않았다. 쿼리 원문이 그대로여야 Phase 6의 실행계획과 같은 조건에서 비교된다
- 테스트: `./gradlew test` 통과

### 개선 후 지표

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 473.056ms | 442.3124999999996ms | -6.5% |
| | p99 | 719.1027999999997ms | 968.1165ms | +34.6% (악화) |
| | med | 219.35ms | 125.126ms | -43.0% |
| | max | 1784.57ms | 1898.165ms | +6.4% (악화) |
| | RPS | 166.1613138464495 | 221.21615110025436 | +33.1% |
| 하드웨어 독립 | 요청당 쿼리 수 | 6 | 6 | 변화 없음 |
| | 대상 쿼리 mean_ms | 101.58188398951914 | 7.549862536326318 | -92.6% |
| | 대상 쿼리 total 비중 | 91.2000115838526% (1위) | 32.318545126437755% (2위) | |
| | 요청당 DB 시간 합 | 111.39ms | 23.36ms | -79.0% |
| | 검사 행 / 반환 행 | 156,000 / 30 = 5,200:1 | 인덱스 탐색 60 / 30 = 2:1 | |
| | Rows Removed by Filter (`bookmark`) | 155,844 | 0 | |
| | 스캔 방식 | Seq Scan | Index Scan using `ix_bookmark_user_problem` | |
| | 쿼리 전체 shared hit | 1306 (10.2MB) | 371 (2.9MB) | -71.6% |
| | 단건 Execution Time | 14.585ms | 1.875ms | -87.1% |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클 아님 |

- 에러율 0, check 통과율 1로 전후 동일하다. 응답 내용은 달라지지 않았다
- 계획 변화: 조인 순서가 뒤집혔다. 개선 전에는 `bookmark` 156,000행을 훑어 유저 것 156행을 고른 뒤 `problem`과 해시 조인했다. 개선 후에는 유닛의 문제 60건을 바깥에 두고 문제마다 `(user_id, problem_id)` 인덱스를 찍는다 (Index Scan loops 60, 그중 30건이 매칭)
- 개선 후 비용이 가장 큰 노드는 Hash Join(p⋈l) 0.808ms(46.1%)와 Seq Scan `problem` 0.540ms(30.8%)다

### 판정

- 개선 여부 (하드웨어 독립 증거 기준): **있음**. 스캔 방식이 Seq Scan에서 Index Scan으로 바뀌었고, 버린 행 155,844 → 0, 만진 페이지 1306 → 371, 요청당 DB 시간 111.39ms → 23.36ms다. 측정 편차로는 실행계획이 바뀌지 않는다
- 예상 효과 대조: Phase 5에서 예상한 "Seq Scan → Index Scan"이 그대로 나왔다. 근거였던 `user_id` 선택도 0.1%를 플래너가 인덱스 선택으로 받아들였다
- 남은 위험 신호:
  - 단일 쿼리 total_exec_time 점유율 - `option` 조회가 51.80%로 새 1위다. 대상 쿼리도 32.32%로 30% 기준을 아직 넘는다
  - 플래너 추정 대 실측 - Nested Loop가 rows=1로 추정했으나 실측 30이다. 유닛 필터와 유저 필터의 상관관계를 플래너가 독립으로 가정한 결과로, 이번 인덱스와는 별개 사안이다
  - `problem` Seq Scan(6,900행)이 남아 있다. 1만 행 미만이라 위험 신호 기준에는 걸리지 않는다
  - 해소된 항목: 검사 행 / 반환 행 5,200:1 → 2:1, `bookmark`의 Seq Scan, N+1 해당 없음(요청당 1.00 유지)
- 설명되지 않은 관측: 대상 쿼리 외 나머지가 전부 호출당 느려졌다 (`option` 7.867 → 12.100, `answer` 1.596 → 2.988, `users` 조회 0.090 → 0.235, `unit` 0.099 → 0.129). 상승폭이 처리량 증가분(+33.1%)보다 크고 쿼리마다 제각각이라 부하 증가만으로는 설명되지 않는다.
  유력한 가설은 앱과 PostgreSQL이 같은 머신에 있어, 응답 바이트가 289,985,385 → 386,109,259(+33.1%)로 늘면서 애플리케이션의 직렬화 CPU가 Postgres 몫을 잠식했다는 것이다.
  이번 측정에 CPU 지표가 없어 확증하지 못했다. 확인하려면 측정 중 앱과 postgres의 CPU 점유를 관측하거나 DB를 별도 머신에 두고 재측정해야 한다
- p99, max 악화: p99는 26,551건의 상위 1% 경계이므로 968ms보다 느린 요청이 약 266건 있어야 719 → 968ms로 움직인다. 단발 스파이크로는 설명되지 않는다.
  med -43.0%, p95 -6.5%인데 p99만 +34.6%인 분포는 처리량 33% 증가로 커넥션 풀 60개에 요청이 몰린 대기열 신호로 읽는 편이 관측과 맞는다
- 다음 사이클 진행 여부: 진행하지 않는다 (호출자가 종료를 선택). 규칙상으로는 위험 신호가 남아 계속 조건이었다
- Phase 5에서 사이클 2로 미뤄둔 커버링(`INCLUDE (created_at)`) 건은 근거가 사라져 접는다. Sort 노드 자기 몫이 0.050ms(2.9%), `bookmark` Index Scan이 0.12ms(6.8%)로 없앨 힙 접근 비용이 거의 없다
- 남겨두는 사이클 2 후보: `option` 조회 개선(새 1위, 51.80%, mean 12.100ms에 60행 반환), 조인 축소(`unit` 조인 제거, Seq Scan `unit`이 loops 30으로 자기 몫 0.15ms), `lesson (unit_id)` 인덱스(230행 테이블이라 효과는 미미할 수 있다)

### 측정 조건의 한계

`pg_stats`에서 `bookmark.user_id`의 correlation이 1이다. 시드가 유저 순으로 넣어 물리 순서가 `user_id`와 일치한다.
실서비스는 북마크가 시간순으로 쌓여 `user_id`가 흩어지므로 correlation이 0에 가깝다.
이 조건에서 잰 개선폭은 실서비스보다 낙관적으로 나올 수 있다. Phase 8 판정에서 감안한다.

---

## 최종 요약

> 하드웨어 의존 증거와 독립 증거를 모두 남긴다.

| 구분 | 지표 | 최초 | 최종 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 473.056ms | 442.3124999999996ms | -6.5% |
| | p99 | 719.1027999999997ms | 968.1165ms | +34.6% (악화) |
| | RPS | 166.1613138464495 | 221.21615110025436 | +33.1% |
| 하드웨어 독립 | 요청당 쿼리 수 | 6 | 6 | 변화 없음 |
| | 요청당 DB 시간 합 | 111.39ms | 23.36ms | -79.0% |
| | 대상 쿼리 mean_ms | 101.58188398951914 | 7.549862536326318 | -92.6% |
| | 검사 행 / 반환 행 | 156,000 / 30 = 5,200:1 | 인덱스 탐색 60 / 30 = 2:1 | |
| | 스캔 방식 | Seq Scan | Index Scan using `ix_bookmark_user_problem` | |
| | 쿼리 전체 shared hit | 1306 (10.2MB) | 371 (2.9MB) | -71.6% |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 기법을 쓰지 않았다 |

적용한 기법: 사이클 1 - `bookmark (user_id, problem_id)` UNIQUE 인덱스 추가 (`V38__add_bookmark_user_problem_unique_index.sql`)

---

## 후속 변경 (이 대상 종료 후)

같은 이슈의 두 번째 대상 `GET /api/v1/wrong-answered-notes/{unitId}`의 사이클 1에서 **불필요한 `Unit` 조인 제거**를 적용하면서,
`BookmarkRepository`의 두 쿼리도 함께 고쳤다. 같은 결함을 한쪽만 남기지 않기 위해서다.

- `findBookmarkedProblemDetailByUnitIdAndUserId` (이 대상이 측정한 쿼리)
- `countByUnitIdAndUserId`

```
JOIN Unit u ON u.id = l.unitId ... WHERE u.id = :unitId
→ WHERE l.unitId = :unitId
```

따라서 **위에 적힌 쿼리 원문과 `query-plan-0.txt` / `query-plan-1.txt`는 측정 당시 기록으로는 유효하지만 현재 코드와는 다르다.**
이 변경은 이 대상에서 재측정하지 않았다. 근거와 등가성 검증은 `../wrong-answered-notes/record.md`의 사이클 1을 참조한다.
