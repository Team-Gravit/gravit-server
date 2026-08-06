# [PERF-490] GET /api/v1/units/{chapterId}

> 이슈: #490
> 브랜치: refactor/490-chapter-unit-query-performance
> 대상 디렉토리: `.claude/resources/perf/490/units/`

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
| 1 | 단일 집계 쿼리로 N+1 제거 | ✅ | ✅ | ✅ | ✅ |

## 대상

- 엔드포인트: `GET /api/v1/units/{chapterId}`
- 실행 경로: `UnitController.getAllUnitInChapter` → `UnitFacade.getAllUnitInChapter` → (`ChapterQueryService`, `UnitQueryService`, `LearningProgressRateService`) → (`ChapterRepository`, `UnitRepository`, `LessonSubmissionRepository`, `LessonRepository`)
- 트랜잭션 경계: `open-in-view: false`. 요청 1회가 트랜잭션 3개로 쪼개진다 - 필터의 SELECT, 인터셉터의 UPDATE, 파사드의 `@Transactional(readOnly = true)`
- 예상 쿼리 목록 (요청 1회 기준, `n` = 챕터의 유닛 수, `k` = 그중 제출 이력이 1건 이상인 유닛 수, `0 <= k <= n`)

  **API 밖 (필터, 인터셉터)**
  1. `UserRepository.findById` - SELECT. `JwtAuthFilter:81` → `AuthTokenProvider.parseUser:67`. 1회
  2. `UserRepository.updateLastAccessedAt` - UPDATE. `LastAccessInterceptor:30` → `UserAccessService.updateLastAccessed`. 1회

  **파사드 (`UnitFacade:30~44`)**
  3. `ChapterRepository.findChapterSummaryByChapterId` - 챕터 단건 요약. 1회
  4. `UnitRepository.findAllUnitSummaryByChapterId` - `WHERE u.chapterId = :chapterId`. 1회
  5. `LessonSubmissionRepository.countSolvedLessonByUnitIdAndUserId` - `COUNT(DISTINCT l.id)`, `LessonSubmission` JOIN `Lesson`. 유닛마다 1회, 총 `n`회
  6. `LessonRepository.countTotalLessonByUnitId` - `COUNT(l.id)`, `Unit` JOIN `Lesson`. `solvedLessonCount == 0`이면 조기 반환(`LearningProgressRateService:41`)이라 건너뛴다. 총 `k`회

  **합계: `4 + n + k`** (하한 `4 + n`, 상한 `4 + 2n`)

- 지연 로딩 추가 쿼리 후보: 없음. 4~6은 전부 JPQL 생성자 표현식과 `COUNT` 스칼라 반환이라 엔티티 프록시를 만들지 않는다
- 참고: `UnitRepository.findUnitProgressByChapterIdAndUserId`(`UnitRepository:59`)가 챕터 단위 유닛별 진행 집계를 단일 쿼리로 이미 제공하지만 이 API는 사용하지 않는다

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application="gravit-perf"` 확인) |
| 커넥션 풀 크기 | 60 (`application-perf.yml:17` `maximum-pool-size`) |
| 데이터 규모 | `users` 1,002 / `chapter` 5 / `unit` 66 / `lesson` 230 / `lesson_submission` 317,300. 현재 규모 유지로 확정, 시드 미사용 |
| 카디널리티 | `unit.chapter_id` 5 / `lesson.unit_id` 66 / `lesson_submission.user_id` 1,000 / `lesson_submission.lesson_id` 148 (`lesson` 230개 중 82개는 제출 이력 없음) |
| 부하 조건 | VU 50. ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m. 이슈 472, 475와 동일 조건 |
| Redis 캐시 상태 | cold (measure 직전 FLUSHDB) |
| DB 캐시 상태 | 제어하지 않음. Redis FLUSHDB는 PostgreSQL의 `shared_buffers`와 OS page cache를 비우지 않는다. 둘을 묶어 cold라고 적지 마라 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` (PONG 확인) |
| 시드 SQL | 미사용 (현재 규모로 진행) |
| 시드 모듈과 변수 | - |
| 유저 범위 | `USER_ID_START=1001`, `USER_COUNT=1000`. `users` id는 1~2000, 총 1,002행 |
| chapterId 분산 | `900001 + (iterationInTest % 5)`. 챕터 900001은 유닛 14개, 900002~900005는 13개 |

**요청당 쿼리 수 (Phase 1 예측을 실측 데이터로 확정)**

`n`(챕터당 유닛 수) = 13~14. 챕터 900001 상위 유저의 `k`(제출 이력이 있는 유닛 수) = 14 = `n`이라
`solvedLessonCount == 0` 조기 반환이 걸리지 않는다. 즉 상한이 그대로 실측치가 된다.

| 챕터 | n | k | 요청당 쿼리 (`4 + n + k`) |
|---|---|---|---|
| 900001 | 14 | 14 | 32 |
| 900002~900005 | 13 | 13 (예상) | 30 |

`chapterId`를 5개 순회하므로 요청당 평균은 30~32 사이다. Phase 4의 실측으로 확정한다.

토큰 인덱스(`iterationInTest % 1000`)와 chapterId(`iterationInTest % 5`)가 같은 카운터에서 나오고
1000이 5의 배수라, 한 유저는 항상 같은 챕터만 조회한다. 챕터별로 서로 다른 유저 200명이 균등하게 붙으므로
커버리지 문제는 없고, 사이클 간 재현성이 확보된다.

**Phase 2 게이트 통과 기록**

| 검증 항목 | 관측값 |
|---|---|
| perf 프로파일 기동 | `application="gravit-perf"` |
| 응답시간 히스토그램 버킷 수 | 146 |
| `pg_stat_statements` 행 수 | 51 |
| Redis 응답 | PONG |
| psql 접속 | `-h localhost -p 5433 -U postgres -d mydb`, 비밀번호 `postgres` (`PGPASSWORD` 사용) |

기동 전 `build/`에 Finder식 사본(`V1__init_tables 2.sql` 등 27개)이 남아 Flyway가 `Found more than one migration with version 1`로 실패했다. `rm -rf build out` 후 정상 기동. 소스 트리(`src/main/resources/db/migration/`)에는 사본이 없었다.

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| p95 | 251.16699999999997 ms |
| p99 | 502.76631999999995 ms |
| med | 128.171 ms |
| max | 1101.469 ms |
| RPS | 280.3764562439154 |
| 에러율 | 0 |
| check 통과율 | 1 (33,647/33,647, 3개 항목 전부) |
| 요청당 쿼리 수 | **27.5033** (트랜잭션 제어문 3.0001 별도) |

**커넥션 풀 (부하 종료 후 프로메테우스 누적값, warmup과 토큰 발급 포함)**

| 지표 | 값 |
|---|---|
| `hikaricp_connections_pending` | 0 |
| 획득 횟수 / 시간 총합 / 평균 | 115,405회 / 1.077초 / 9.33 µs |
| 커넥션 점유 시간 총합 | 4,588.165초 |
| 서버측 응답시간 총합 | 4,620.531154398초 (38,103건) |
| 점유 / 응답 비율 | **99.30%** |
| 요청당 체크아웃 | 3.029회 (115,405 ÷ 38,103) |
| 평균 동시 점유 커넥션 | 약 37개 / 풀 60 = 61.7% |

**measure 구간 추정치** (warmup 4,456건을 5 VU ÷ 30초로 분리한 값)

| 구분 | 요청당 | 비율 |
|---|---|---|
| 커넥션 점유 | 131.93 ms | 100% |
| 그중 실제 SQL 실행 | 2.7876 ms | 2.11% |
| 그 외 (왕복, Hibernate 처리, 스레드 스케줄링) | 129.14 ms | 97.89% |
| 서버측 평균 응답 | 132.87 ms | - |
| k6 클라이언트측 평균 응답 (Little's Law, 50 VU ÷ 280.376 RPS) | 178.33 ms | - |

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.md` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 13.2000178321990073 | 0.15408816826638075 | 68436.87314199883 | 72.96558285477879% | `LessonSubmissionRepository.countSolvedLessonByUnitIdAndUserId` |
| 10.3032365441198324 | 0.06126250718977414 | 21238.057155000402 | 22.6434544401578% | `LessonRepository.countTotalLessonByUnitId` |
| 1.00000000000000000000 | 0.03226445582072698 | 1085.602144999997 | 1.1574402748349957% | `AuthTokenProvider.parseUser` (`JwtAuthFilter` 경유) |
| 1.00000000000000000000 | 0.03094173117959992 | 1041.0964290000004 | 1.1099894583493994% | `UnitRepository.findAllUnitSummaryByChapterId` |
| 1.00000000000000000000 | 0.01871428739560719 | 629.6796280000033 | 0.6713477539143252% | `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor` 경유) |
| 1.00000000000000000000 | 0.016008778613249366 | 538.6473740000002 | 0.5742915740109473% | `ChapterRepository.findChapterSummaryByChapterId` |

상위 2건 합계: 요청당 23.5033회(전체 호출의 85.5%), DB 시간 비중 95.609%.

### 진단

- **병목 성격: N+1.** 느린 쿼리 하나가 아니라, 빠른 쿼리를 챕터의 유닛 수만큼 순차 반복하면서 왕복 비용이 누적된다.
- 근거
  - 개별 쿼리는 빠르다. `countSolvedLessonByUnitIdAndUserId` 0.15408816826638075 ms, `countTotalLessonByUnitId` 0.06126250718977414 ms.
  - 호출 수가 유닛 수에 비례한다. 요청당 각각 13.2000178321990073회, 10.3032365441198324회로 두 건이 전체 호출 27.5033회 중 23.5033회(85.5%), DB 시간의 95.609%를 차지한다.
  - 시간이 실행이 아니라 왕복에 있다. 커넥션 점유 131.93 ms 중 실제 SQL 실행은 2.7876 ms(2.11%)뿐이다. 왕복 1회당 131.93 ÷ 27.5 = 약 4.80 ms인데 그중 서버 실행은 0.10 ms다.
  - 커넥션 대기는 아니다. `pending`이 0이고 획득 시간 총합이 115,405회에 1.077초(평균 9.33 µs)다. 평균 동시 점유 약 37개로 풀 60에 미달해 대기열이 생기지 않았다.
  - localhost 왕복 자체는 0.1 ms 안팎이므로 4.80 ms 전부가 통신 시간은 아니다. 한 머신에서 k6 50 VU, 톰캣 스레드, 활성 PostgreSQL 백엔드 37개가 CPU를 나눠 쓰는 스케줄링 지연이 섞여 있다. 다만 두 성분 모두 왕복 횟수에 비례하므로 호출 수를 줄이면 함께 준다.
- 예상 쿼리 목록과 어긋난 지점
  - `k`(제출 이력이 있는 유닛 수)를 Phase 3에서 `n`과 같은 13.2로 예측했으나 실측은 10.3032365441198324였다. 요청당 2.8968개 유닛에서 `solvedLessonCount == 0` 조기 반환이 걸렸다.
  - 원인은 Phase 3의 확인 쿼리가 `ORDER BY units_with_submission DESC LIMIT 5`로 상위 5명만 본 편향 표본이었다는 점이다. 1,000명 전체 평균은 10.30이다.
  - `n`은 예측과 정확히 일치했다. `findAllUnitSummaryByChapterId`의 행/호출이 13.2000178321990073으로 `(14+13+13+13+13)/5 = 13.2`와 맞는다.
  - 그 외 쿼리는 전부 예상 목록과 일치했다. 목록에 없던 것은 시즌 마감 스케줄러(`SeasonRepository.findCloseableActiveByNowForUpdate`, 요청당 0.00011888132671560615회)뿐으로 무시 가능한 수준이다.

### 인덱스 현황 (Phase 5-B 재료)

| 테이블 | 인덱스 | 정의 | 크기 |
|---|---|---|---|
| `lesson` | `lesson_pkey` | `btree (id)` UNIQUE | 16 kB |
| `lesson_submission` | `lesson_submission_pkey` | `btree (id)` UNIQUE | 13 MB |
| `lesson_submission` | `ix_lesson_submission_user_created_at` | `btree (user_id, created_at) INCLUDE (lesson_id)` | 12 MB |

`lesson`에 `unit_id` 인덱스가 없고, `lesson_submission`에 `lesson_id` 선두 인덱스가 없다.

**부하 중 스캔 통계**

| 테이블 | seq_scan | seq_tup_read | idx_scan | 행 수 | 테이블 크기 |
|---|---|---|---|---|---|
| `lesson` | 895,559 | 205,978,570 | 624 | 230 | 24 kB |
| `lesson_submission` | 6 | 1,269,200 | 502,961 | 317,300 | 48 MB |
| `unit` | 430,702 | 28,426,332 | 2 | 66 | 16 kB |
| `chapter` | 38,104 | 190,520 | 0 | 5 | 8,192 bytes |

- `lesson` seq_scan 895,559 ≈ 요청당 23.5회 × 38,103건. 두 count 쿼리가 매번 230행을 전체 스캔한다.
- `lesson_submission`만 인덱스를 탄다. `idx_tup_read` 159,593,077 ÷ `idx_scan` 502,961 = 호출당 317.3행을 읽어 `idx_tup_fetch` 기준 약 2.03행을 쓴다. 요청당 13.2회 반복되어 4,188행을 훑는다.
- `lesson`과 `unit`의 Seq Scan은 테이블이 24 kB, 16 kB로 작아 플래너가 고른 것이다. 인덱스를 추가해도 채택되지 않을 공산이 크다.

**카디널리티 (pg_stats)**

| 테이블 | 컬럼 | n_distinct | correlation |
|---|---|---|---|
| `lesson` | `unit_id` | -0.28695652 (230 × 0.287 = 66) | -0.46198505 |
| `lesson_submission` | `user_id` | 1000 | -0.006640228 |
| `lesson_submission` | `lesson_id` | 148 | -0.14780127 |

---

## 사이클 1: 단일 집계 쿼리로 N+1 제거

### 설계 결정

> Phase 5-B에서 호출자와 확정한 내용.

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 기법 | 로직 개선 - 유닛별 반복 호출을 챕터 단위 집계 쿼리 1회로 대체 | 요청당 23.5033회 호출이 DB 시간 95.609%를 차지하고, 시간이 실행(2.11%)이 아니라 왕복에 있다 |
| 집계 쿼리 | 기존 `UnitRepository.findUnitProgressByChapterIdAndUserId`(`UnitRepository.java:59`)를 **수정 없이** 재사용 | 유닛별 `totalLessons`, `solvedLessons`를 이미 한 쿼리로 준다. 수정하지 않으면 이 쿼리를 공유하는 `LearningFacade:45`, `UserFacade:114`에 영향이 없다 |
| description 공급 | `UnitRepository.findAllUnitSummaryByChapterId` 유지 | 이 쿼리가 이미 `(id, title, description)`을 준다. 집계 쿼리에는 `description`이 없어 추가하려면 `GROUP BY` 확장과 `UnitProgressRowDto` 시그니처 변경이 따르고, 공유 호출부 2곳에 파급된다 |
| 두 목록의 정합 | `unitId`로 결합. `WHERE u.chapterId = :chapterId`가 동일하고 집계는 `Unit` 기준 `LEFT JOIN`이라 유닛 집합이 같다. 같은 `readOnly` 트랜잭션 안에서 동일 스냅샷을 본다 | 레슨이 0개인 유닛도 `totalLessons=0, solvedLessons=0` 행으로 나온다 |
| 진행률 계산 위치 | `LearningProgressRateService.calculateProgressRate(solvedLessons, totalLessons)` 신규. DB를 타지 않으므로 트랜잭션 어노테이션을 붙이지 않는다 | 진행률 규칙을 learning 도메인에 남겨 `getChapterProgress`, `getPlanetConquestRate`와 위치를 일관되게 둔다. Service가 다른 도메인 Service를 호출하지 않는 컨벤션상, 조합은 `UnitFacade`가 맡는다 |
| 0으로 나누기 | `solvedLessons == 0`을 먼저 걸러 `0.0` 반환 | 레슨이 0개면 제출도 0건이라 반드시 이 분기에 걸린다. 현재 `getUnitProgress:39`와 같은 구조 |
| 미사용 메서드 처리 | `LearningProgressRateService.getUnitProgress`와 `LessonSubmissionRepository.countSolvedLessonByUnitIdAndUserId` **제거** | 변경 후 호출부가 0개다. `LessonRepository.countTotalLessonByUnitId`는 `AdminUnitService:31`이 계속 쓰므로 남긴다 |

**변경 대상**

| 클래스.메서드 | 작업 |
|---|---|
| `UnitQueryService.getAllUnitProgressInChapter(chapterId, userId)` | 신규. `unitRepository.findUnitProgressByChapterIdAndUserId`를 그대로 호출해 `List<UnitProgressRowDto>` 반환 |
| `LearningProgressRateService.calculateProgressRate(solvedLessons, totalLessons)` | 신규. 순수 계산 |
| `UnitFacade.getAllUnitInChapter` | `stream().map()` 안의 유닛별 `getUnitProgress` 호출 제거. 집계 1회 + `unitId → progressRate` 맵으로 결합 |
| `LearningProgressRateService.getUnitProgress` | 제거 |
| `LessonSubmissionRepository.countSolvedLessonByUnitIdAndUserId` | 제거 |

**영향 테스트**: `UnitFacadeUnitTest`, `UnitFacadeIntegrationTest`, `UnitQueryServiceUnitTest`, `UnitQueryServiceIntegrationTest`, `LearningProgressRateServiceUnitTest`, `LearningProgressRateServiceIntegrationTest`

- 검토했지만 택하지 않은 안
  - **인덱스 추가**(`lesson(unit_id)`, `lesson_submission(user_id, lesson_id)`) - 호출 수 23.5033회는 그대로 남고, 실행시간은 커넥션 점유 131.93 ms의 2.11%(2.7876 ms)뿐이라 개선 상한이 낮다. `lesson`은 24 kB라 인덱스가 채택되지 않을 공산도 크다
  - **콘텐츠 캐싱**(Redis) - 요청당 27.50 → 14.20으로 줄지만 유저별 진행률 13.20회가 남는다. 무효화 설계 비용이 셋 중 가장 크다. 이번 사이클 이후 추가 사이클로 검토 가능
  - **집계 쿼리에 description 통합**(옵션 2) - 요청당 4.0으로 1회 더 줄지만(기준선 대비 3.6%p), 공유 쿼리를 수정해 `LearningFacade`, `UserFacade` 2곳에 파급된다. 본체 효과(23.5 → 1)에 비해 이득이 작다
- 호출자가 예상한 효과: 요청당 쿼리 수 27.5033 → 5.0

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 251.16699999999997 ms / 502.76631999999995 ms |
| RPS | 280.3764562439154 |
| 요청당 쿼리 수 | 27.5033 |
| `countSolvedLessonByUnitIdAndUserId` calls / mean_ms / total_ms | 444141 / 0.15408816826638075 / 68436.87314199883 (비중 72.96558285477879%) |
| `countTotalLessonByUnitId` calls / mean_ms / total_ms | 346673 / 0.06126250718977414 / 21238.057155000402 (비중 22.6434544401578%) |

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`)

- EXPLAIN 파라미터: `chapterId = 900003`, `unitId = 900033`, `userId = 1500` (이후 모든 사이클에서 동일하게 사용)
  - 전부 분포의 중앙값이다. 챕터 900001~900005의 중앙이 900003, 그 챕터의 유닛 900027~900039의 중앙이 900033, 유저 1001~2000의 중앙이 1500(제출 317건 / 서로 다른 레슨 117개).
- 캡처한 쿼리 2개
  - 계획 A: `countSolvedLessonByUnitIdAndUserId` - 개선 전 지배 쿼리(요청당 13.20회, 72.97%)
  - 계획 B: `findUnitProgressByChapterIdAndUserId` - 개선 후 대체 쿼리. 기준선 부하에서 실행된 적이 없어 `pg_stat_statements`에 Hibernate 생성 원문이 없다. JPQL(`UnitRepository.java:59`)을 손으로 SQL로 옮겨 캡처했으므로 Phase 8에서 실제 생성 SQL로 재확인한다.

| 항목 | 계획 A | 계획 B |
|---|---|---|
| 스캔 방식 | `Index Only Scan` (`ix_lesson_submission_user_created_at`) + `lesson` Seq Scan, Hash Join | 동일 `Index Only Scan` + `lesson`, `unit` Seq Scan, Hash Right Join 2단, Sort, GroupAggregate |
| actual rows 대 반환 행 수 | 317 → 조인 후 6 → 집계 1 (**317:1**) | 317 + 230 + 66 → 78 → 13 (**47:1**) |
| Rows Removed by Filter | `lesson` Seq Scan 228 (230행 중 2행 남김) | `unit` Seq Scan 53 (66행 중 13행 남김). `lesson` Seq Scan은 필터 없음 |
| shared hit / read | 최상단 hit=14 / read=0 (114.7 KB) | 최상단 hit=10 / read=0 (81.9 KB) |
| 플래너 추정 대 실측 | Index Only Scan 465 / 317 = 1.47배 | 동일 1.47배 |
| Heap Fetches | 0 | 0 |
| Planning / Execution Time | 4.455 ms / 2.734 ms | 1.103 ms / 0.822 ms |

**요청 단위 환산**

| 항목 | 개선 전 (A × 13.20 + `countTotalLessonByUnitId` × 10.30) | 개선 후 (B × 1) | 변화 |
|---|---|---|---|
| 만진 버퍼 | 184.8 페이지 (1.44 MB) | 10 페이지 (0.078 MB) | -94.6% |
| 인덱스에서 읽은 행 | 4,184.4 | 317 | -92.4% |
| `lesson` 스캔 행 | 5,405.7 | 230 | -95.7% |

**해석**

- 노드 단위 비율은 두 계획이 같다. `Index Only Scan`은 양쪽 모두 317행을 읽고 추정/실측 1.47배, `Heap Fetches: 0`까지 동일하다. 이번 변경은 노드의 비효율을 고치지 않고, **그 노드를 도는 횟수를 13.20회에서 1회로 줄인다.**
- `lesson` Seq Scan도 같다. 계획 A는 230행을 훑어 228행을 버리기를 13.20회 반복하고, 계획 B는 230행을 한 번 훑되 필터가 없다. 걸러내는 일이 `unit`(66행 중 53행 제거)으로 옮겨간다.
- 위험 신호 대조: 검사/반환 비율 317:1 → 47:1, 동일 쿼리 요청당 호출 13.20회 → 1회, 단일 쿼리 시간 점유율 72.97% → 해당 쿼리 소멸. 플래너 추정 괴리 1.47배는 기준(10배) 안이라 신호가 아니다.
- 노드 자체의 317:1을 줄이려면 `lesson_submission(user_id, lesson_id)` 인덱스로 플래너가 `lesson` 26행을 먼저 잡고 탐침하도록 유도하는 방향이 있으나, 사이클 2 후보이며 이번 범위가 아니다.
- `EXPLAIN ANALYZE`의 절대 시간(2.734 ms, 0.822 ms)은 계측 오버헤드와 미캐시 Planning Time을 포함하므로 `pg_stat_statements` 평균(0.154 ms)과 직접 비교하지 않는다. 비교는 노드 구조와 행 수로 한다.

**로직 개선 기법의 추가 캡처 - 변경 전 요청당 쿼리 수와 호출 스택**

| 쿼리 | 요청당 | 호출 스택 |
|---|---|---|
| `countSolvedLessonByUnitIdAndUserId` | 13.2000178321990073 | `UnitFacade:38` → `LearningProgressRateService.getUnitProgress:38` → `LessonSubmissionRepository` |
| `countTotalLessonByUnitId` | 10.3032365441198324 | `UnitFacade:38` → `LearningProgressRateService.getUnitProgress:44` → `LessonRepository` |

두 호출 모두 `UnitFacade.getAllUnitInChapter`의 `unitSummaries.stream().map(...)`(`UnitFacade.java:34~44`) 안에 있어 유닛 수만큼 반복된다.

### 적용 내용

**메인 코드**

| 파일 | 변경 |
|---|---|
| `unit/facade/UnitFacade.java` | `unitSummaries.stream().map(...)` 안의 유닛별 `learningProgressRateService.getUnitProgress` 호출 제거. `unitQueryService.getAllUnitProgressInChapter`를 1회 호출해 `unitId → progressRate` 맵을 만들고 유닛 목록과 결합. `NOT_STARTED_PROGRESS_RATE = 0.0` 상수 추가 |
| `unit/service/UnitQueryService.java` | `getAllUnitProgressInChapter(chapterId, userId)` 신규. `unitRepository.findUnitProgressByChapterIdAndUserId`를 그대로 위임해 `List<UnitProgressRowDto>` 반환 |
| `learning/service/LearningProgressRateService.java` | `getUnitProgress(unitId, userId)` 제거. `calculateProgressRate(solvedLessonCount, totalLessonCount)` 신규 - DB를 타지 않는 순수 계산이라 트랜잭션 어노테이션을 붙이지 않았다 |
| `lesson/repository/LessonSubmissionRepository.java` | `countSolvedLessonByUnitIdAndUserId` 제거 |

설계대로 `UnitRepository.findUnitProgressByChapterIdAndUserId`와 `findAllUnitSummaryByChapterId`는 수정하지 않았다. 두 쿼리를 공유하는 `LearningFacade:45`, `UserFacade:114`는 무영향이다.
`LessonRepository.countTotalLessonByUnitId`는 `AdminUnitService:31`이 계속 쓰므로 남겼다.

**테스트**

| 파일 | 변경 |
|---|---|
| `UnitFacadeUnitTest` | `getUnitProgress` 스텁을 `getAllUnitProgressInChapter` + `calculateProgressRate` 스텁으로 교체. 유닛이 없는 케이스에도 빈 목록 스텁 추가 |
| `LearningProgressRateServiceUnitTest` | `GetUnitProgress` 중첩 클래스를 `CalculateProgressRate`로 교체. `totalLessonCount = 0` 케이스를 추가해 0으로 나누기 방어선을 검증 |
| `LearningProgressRateServiceIntegrationTest` | `GetUnitProgress` 중첩 클래스 제거(대상 메서드 소멸). 커버리지는 순수 계산(`LearningProgressRateServiceUnitTest`), 집계 쿼리(`UnitQueryServiceIntegrationTest`), 종단 결합(`UnitFacadeIntegrationTest`, progressRate 50.0과 0.0 검증)으로 유지 |

- 테스트: `./gradlew test` 통과
- 컴파일 경고는 기존 `UserFacade.getMainPage` deprecation뿐으로 이번 변경과 무관하다

### 개선 후 지표

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 251.16699999999997 ms | 116.05729999999984 ms | -53.8% |
| | p99 | 502.76631999999995 ms | 254.81243999999998 ms | -49.3% |
| | med | 128.171 ms | 46.713499999999996 ms | -63.6% |
| | max | 1101.469 ms | 1538.989 ms | +39.7% (단일 표본, 아래 참조) |
| | RPS | 280.3764562439154 | 686.0507502892599 | +144.7% |
| | 요청 수 (2m) | 33647 | 82328 | +144.7% |
| | 서버측 평균 응답 | 121.26 ms | 48.89 ms | -59.7% |
| 하드웨어 독립 | 요청당 쿼리 수 | 27.5033 | 5.0000 | **-81.8%** |
| | 요청당 DB 시간 | 2.7876 ms | 0.5757 ms | -79.3% |
| | 총 DB 시간 | 93793.362 ms | 47396.173 ms | -49.5% |
| | 대체된 작업의 요청당 DB 시간 | 2.6652 ms (쿼리 2종) | 0.4259 ms (집계 1회) | -84.0% |
| | 검사 행 / 반환 행 | 317:1 | 47:1 | 해소 |
| | 스캔 방식 | `Index Only Scan` + `lesson` Seq Scan을 요청당 13.20회 반복 | 동일 노드를 요청당 1회 | 반복 소멸 |
| | 플래너 추정 / 실측 | 465 / 317 = 1.47배 | 315 / 317 = 1.006배 | `VACUUM ANALYZE`로 통계 갱신됨 |
| | 캐시 hit / miss, 적중률 | - | - | - |

**쿼리 구성 변화**

| 쿼리 | 전 (요청당) | 후 (요청당) |
|---|---|---|
| `countSolvedLessonByUnitIdAndUserId` | 13.2000178321990073 | 소멸 |
| `countTotalLessonByUnitId` | 10.3032365441198324 | 소멸 |
| `findUnitProgressByChapterIdAndUserId` | 없음 | 1.00000000000000000000 |
| `findAllUnitSummaryByChapterId` | 1.0 | 1.0 |
| `AuthTokenProvider.parseUser` | 1.0 | 1.0 |
| `updateLastAccessedAt` | 1.0 | 1.0 |
| `findChapterSummaryByChapterId` | 1.0 | 1.0 |
| `BEGIN READ ONLY` / `BEGIN` | 2.0 / 1.0001 | 2.0 / 1.0001 |

**max 1538.989 ms의 정체 - 단일 외톨이**

서버측 히스토그램(앱 재기동으로 이번 측정만 담김)으로 꼬리 분포를 대조했다.

| 구간 | 개선 전 건수 / 비율 | 개선 후 건수 / 비율 |
|---|---|---|
| > 0.5s | 346 / 38103 = 0.908% | 264 / 92121 = 0.287% |
| > 0.715827881s | 99 = 0.260% | 84 = 0.091% |
| > 1.0s | 24 = 0.063% | 47 = 0.051% |
| > 1.431655765s | 0 = 0.000% | **1 = 0.0011%** |
| > 2.147483647s | - | 0 = 0% |

- `1.431655765s`를 넘긴 요청이 92,121건 중 **1건**이고 그 위로는 없다. k6의 `max` 1538.989 ms가 그 한 건이다.
- 비율로 보면 꼬리는 모든 구간에서 얇아졌다. 0.5초 초과 0.908% → 0.287%(-68.4%), 1.0초 초과 0.063% → 0.051%(-19.0%).
- 1.0초 초과 절대 건수가 24 → 47로 는 것은 표본이 38,103 → 92,121건으로 2.42배 커진 결과다.
- `max / med` 비율이 8.60배 → 32.94배로 나빠진 것은 분모(med)가 63.6% 줄어 생긴 착시다. 단일 표본을 중앙값으로 나눈 값은 분포 두께를 대표하지 못한다.

**실행계획 (개선 후, `query-plan-1.txt`)**

파라미터는 Phase 6과 동일(`chapterId = 900003`, `userId = 1500`).

| 노드 | 스캔 방식 / 인덱스 | actual time | 추정 rows | 실측 rows | loops | Rows Removed by Filter | shared hit / read |
|---|---|---|---|---|---|---|---|
| GroupAggregate | Group Key: `u1_0.id` | 0.795..0.859 | 13 | 13 | 1 | - | hit=16 / read=0 |
| Sort | quicksort, Memory 31kB | 0.726..0.739 | 62 | 78 | 1 | - | hit=16 / read=0 |
| Hash Right Join | `ls.lesson_id = l.id` | 0.522..0.667 | 62 | 78 | 1 | - | hit=13 / read=0 |
| Index Only Scan | `ix_lesson_submission_user_created_at` | 0.369..0.425 | 315 | 317 | 1 | - | hit=8 / read=0 |
| Hash | - | 0.137..0.141 | 45 | 26 | 1 | - | hit=5 / read=0 |
| Hash Right Join | `l.unit_id = u.id` | 0.101..0.132 | 45 | 26 | 1 | - | hit=5 / read=0 |
| Seq Scan on `lesson` | 필터 없음 | 0.003..0.028 | 230 | 230 | 1 | - | hit=3 / read=0 |
| Hash | - | 0.032..0.033 | 13 | 13 | 1 | - | hit=2 / read=0 |
| Seq Scan on `unit` | Filter: `chapter_id = 900003` | 0.012..0.018 | 13 | 13 | 1 | 53 | hit=2 / read=0 |

Planning Time 2.571 ms / Execution Time 0.982 ms / Heap Fetches 0

**Phase 6의 손 번역 SQL 검증**

Phase 6에서 집계 쿼리를 JPQL에서 손으로 SQL로 옮겨 캡처했고, Phase 8에서 확인하기로 했다.
`query-stats-summary-1.md` 1행의 Hibernate 생성 원문과 대조한 결과 공백과 `$1/$2` 대 리터럴을 빼면 토큰 단위로 동일하다.
조인 순서, 조인 종류(`left join` 2개), 조인 조건 위치(`and ls1_0.user_id`가 `ON` 절), `GROUP BY` 키, `ORDER BY`가 모두 같다.

`query-plan-0.txt`의 계획 B와 `query-plan-1.txt`의 `Query Identifier`가 581384667906442718로 같은 것은 **같은 SQL 텍스트를 두 번 EXPLAIN했기 때문**이며 손 번역의 검증 근거가 아니다.
개선 전 지배 쿼리(`query-plan-0.txt` 계획 A)의 identifier는 8221422339103481763으로 다르다.

### 판정

- **개선 여부 (하드웨어 독립 증거 기준): 있음.**
  - 요청당 쿼리 수 27.5033 → 5.0000(-81.8%). 코드 구조로 결정되는 값이라 측정 편차로 흔들리지 않는다.
  - 요청당 DB 시간 2.7876 ms → 0.5757 ms(-79.3%).
  - 대체된 작업만 떼어 보면 요청당 2.6652 ms(쿼리 13.20회 + 10.30회) → 0.4259 ms(집계 1회)로 -84.0%.
  - 검사 행/반환 행 317:1 → 47:1.
  - 하드웨어 의존 지표도 같은 방향이다. p95 -53.8%, p99 -49.3%, RPS +144.7%.
- 호출자가 예상한 효과와의 대조: Phase 5-B에서 요청당 쿼리 27.5033 → 5.0을 예상했고 실측이 **정확히 5.0**이다. 근거였던 "요청당 23.5033회 호출이 DB 시간 95.609%를 차지하고 시간이 실행이 아니라 왕복에 있다"는 진단이 맞았다.
- 남은 위험 신호
  - **단일 쿼리 시간 점유율 73.97%** (기준 30% 이상). `findUnitProgressByChapterIdAndUserId`가 요청당 0.4259 ms로 DB 시간의 73.97%를 차지한다. 다만 절대 시간은 개선 전 같은 작업의 2.6652 ms보다 84.0% 작고, 다른 쿼리들도 함께 줄어 비율이 유지된 것이다.
  - `Index Only Scan`이 여전히 호출당 317행을 읽어 13행을 만든다(47:1). 노드 자체의 비효율은 이번 사이클이 건드리지 않았다. `lesson_submission(user_id, lesson_id)` 인덱스로 플래너가 `lesson` 26행을 먼저 잡고 탐침하도록 유도하는 방향이 사이클 2 후보다.
  - 콘텐츠 캐싱(Phase 5-A의 3번)도 미적용 상태다. 남은 5개 쿼리 중 `findAllUnitSummaryByChapterId`, `findChapterSummaryByChapterId`가 유저와 무관한 콘텐츠 조회다.
- 다음 사이클 진행 여부: 진행하지 않음. 호출자가 사이클 1에서 종료를 선택했다. 요청당 DB 시간이 응답시간의 0.79%(사이클 1 전 1.563%)로 DB가 더 이상 응답시간을 지배하지 않아, 추가 사이클의 체감 이득이 작다고 판단했다.

---

## 최종 요약

> 하드웨어 의존 증거와 독립 증거를 모두 남긴다.

| 구분 | 지표 | 최초 | 최종 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 251.16699999999997 ms | 116.05729999999984 ms | -53.8% |
| | p99 | 502.76631999999995 ms | 254.81243999999998 ms | -49.3% |
| | med | 128.171 ms | 46.713499999999996 ms | -63.6% |
| | RPS | 280.3764562439154 | 686.0507502892599 | +144.7% |
| | 2분간 처리 요청 수 | 33647 | 82328 | +144.7% |
| | 서버측 평균 응답 | 121.26 ms | 48.89 ms | -59.7% |
| 하드웨어 독립 | 요청당 쿼리 수 | 27.5033 | 5.0000 | **-81.8%** |
| | 요청당 DB 시간 | 2.7876 ms | 0.5757 ms | -79.3% |
| | 총 DB 시간 | 93793.362 ms | 47396.173 ms | -49.5% |
| | 검사 행 / 반환 행 | 317:1 | 47:1 | 해소 |
| | 스캔 방식 | `Index Only Scan` + `lesson` Seq Scan을 요청당 13.20회 반복 | 동일 노드를 요청당 1회 | 반복 소멸 |
| | 요청당 만진 버퍼 | 184.8 페이지 (1.44 MB) | 10 페이지 (0.078 MB) | -94.6% |
| | 캐시 hit / miss, 적중률 | - | - | - |

적용한 기법: 사이클 1 - 단일 집계 쿼리로 N+1 제거

측정 조건은 두 측정이 동일하다. VU 50 / ramp-up 30s + 유지 1m + ramp-down 30s(총 2m) / Redis cold / DB 캐시 미제어 / `USER_ID_START=1001`, `USER_COUNT=1000` / `chapterId = 900001 + (iterationInTest % 5)` / 데이터 규모 변경 없음(시드 미사용) / 커넥션 풀 60. 양쪽 모두 실패율 0, check 통과율 1이다.

남은 개선 여지 (다음 사이클 후보)

- `lesson_submission(user_id, lesson_id)` 인덱스로 집계 쿼리의 호출당 317행 스캔을 줄이는 방향. 요청당 쿼리 수는 5.0 그대로고 실행시간만 준다.
- 콘텐츠 캐싱(Redis)으로 `findAllUnitSummaryByChapterId`, `findChapterSummaryByChapterId`를 걷어내는 방향. 요청당 쿼리 5.0 → 3.0. 무효화 설계 필요.
- 두 방향 모두 DB 시간이 이미 응답시간의 0.79%라 체감 이득은 사이클 1보다 작다.
