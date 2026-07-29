# [PERF-472] GET /api/v1/my-pages/learning/weekly-report

> 이슈: #472
> 브랜치: refactor/472-mypage-learning-performance
> 대상 디렉토리: `.claude/resources/perf/472/weekly-report/`

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
| - | 없음 (Phase 4에서 DB 병목 없음으로 판정) | ⏭️ | ⏭️ | ⏭️ | ⏭️ |

## 대상

- 엔드포인트: `GET /api/v1/my-pages/learning/weekly-report`
- 실행 경로: `MyPageController:56-59` → (Facade 없음) → `DailyLearningRecordService:51-87` → `DailyLearningRecordRepository:40-50`
- 예상 쿼리 목록 (요청 1회 기준)
  1. `DailyLearningRecordRepository.findByUserIdAndSolvedDateBetween` - `SELECT dlr FROM DailyLearningRecord dlr WHERE dlr.userId = :userId AND dlr.solvedDate BETWEEN :thisMonday AND :thisSunday ORDER BY dlr.solvedDate`. 구간은 `threeWeeksAgoMonday ~ thisSunday`로 28일이다
  2. 지연 로딩 지점 없음. `DailyLearningRecord`(`domain/DailyLearningRecord.java:29-40`)는 `id`, `userId`, `solvedDate`, `solvedLessonCount` 네 컬럼뿐이고 연관관계 필드가 없다
  3. Service의 집계(`:61-86`)는 전부 메모리 작업이다 - 이번 주 요일별 `Map`, 주 시작일별 합계 `Map`, 지난 3주 대비 델타 3개
- 대상 밖에서 붙는 쿼리 (진단 시 대상 쿼리와 분리해 읽는다)
  - `users` SELECT 2회 - `JwtAuthFilter:78`(`getAuthUser` → `parseUser`)과 `JwtAuthFilter:81`(`parseUser`)이 각각 `AuthTokenProvider:71`의 `userRepository.findById`를 탄다
  - `users` UPDATE 1회 - `LastAccessInterceptor.preHandle` → `UserAccessService.updateLastAccessed` → `UserRepository.updateLastAccessedAt`
  - 위 3건은 `weak-concepts` 대상 측정(`../weak-concepts/query-stats-summary-0.txt`)에서 요청당 각각 2.00, 1.00으로 확인됐다
- 반환 행 수 예상: 시드는 오늘(2026-07-28)부터 과거 180일을 채운다. 조회 구간 2026-07-06 ~ 2026-08-02 중 `thisSunday`(2026-08-02)는 미래라 데이터가 없으므로, 실제로 걸리는 것은 2026-07-06 ~ 2026-07-28의 23일치다

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf |
| 커넥션 풀 크기 | 10 (`application-perf.yml:14`) |
| 데이터 규모 | `daily_learning_record` 181,000 (유저 1,000명 × 181일) / `users` 1,000 (id 1001~2000) |
| 카디널리티 | `user_id` 1,000 (유저당 181행) / `solved_date` 181일 / `solved_lesson_count` 8 |
| 조회 구간 실측 | 유저 1500 기준 23행. 구간은 28일(`threeWeeksAgoMonday ~ thisSunday`)이지만 `thisSunday`(2026-08-02)가 미래라 2026-07-06 ~ 2026-07-28의 23일만 걸린다 |
| 기존 인덱스 | `daily_learning_record_pkey` PRIMARY KEY btree (id) / `ix_daily_learning_record_user_date` btree (user_id, solved_date) / `uk_daily_learning_record_user_date` UNIQUE CONSTRAINT btree (user_id, solved_date) — **(user_id, solved_date) 조합이 중복 생성돼 있다.** 조회에는 하나만 쓰이고 나머지는 INSERT 시 유지 비용만 낸다 |
| 부하 조건 | VU 50. ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m. 이슈 내 3개 대상 공통 |
| Redis 캐시 상태 | cold (measure 직전 FLUSHDB). 현재 실행 경로에 애플리케이션 캐시 없음 |
| DB 캐시 상태 | 제어하지 않음. Redis FLUSHDB는 PostgreSQL의 `shared_buffers`와 OS page cache를 비우지 않는다. 개선 전후 모두 같은 조건이므로 델타 비교에는 영향이 없으나, 단일 측정의 절대값은 warm 상태가 섞인 값이다 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` |
| DB 접속 | `PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d mydb` |
| 측정 시점 스크립트 | 저장된 수치는 토큰을 `tokens[__VU % tokens.length]`로 고르던 시절에 낸 값이다. VU가 50이라 1,000개 중 50개만 쓰였다. 리뷰 반영으로 `exec.scenario.iterationInTest` 기반 순회로 바꿨으므로 **현재 `test-script.js`로는 이 수치가 그대로 재현되지 않는다.** 개선 전후가 같은 조건이었으므로 델타 비교와 하드웨어 독립 판정은 유효하다 |
| 시드 SQL | `../seeds.sql` (이슈 공용, `weak-concepts` 대상에서 적재 완료) |
| 시드 모듈과 변수 | `learning.sql`의 `daily_record_days 180`, `user_start 1001`, `user_count 1000`. 실제 적재는 181일치(측정 준비 중 자정을 넘겨 하루가 더 들어갔다) |
| 선행 대상의 코드 변경 | `weak-concepts` 사이클 1에서 `V32__add_problem_submission_user_index.sql`이 적용된 상태다. 이 인덱스는 `problem_submission` 대상이라 이번 쿼리(`daily_learning_record`)와 무관하다 |

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| med | 42.78 ms |
| p95 | 203.6272499999999 ms |
| p99 | 602.2159999999999 ms |
| max | 4305.034 ms |
| RPS | 510.87112351348134 |
| 요청 수 | 61306 (측정 구간 실경과 120.00초) |
| 에러율 | 0 |
| check 통과율 | 1 (3항목 전부 61306/61306) |
| 요청당 쿼리 수 | 4 (대상 1 + `users` SELECT 2 + `users` UPDATE 1), 트랜잭션 4 (`BEGIN READ ONLY` 3 + `BEGIN` 1) |

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.txt` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 1.00 | 0.07 | 4492.92 | 42.2% | `DailyLearningRecordRepository.findByUserIdAndSolvedDateBetween` |
| 2.00 | 0.03 | 3178.11 | 29.8% | `AuthTokenProvider.parseUser` |
| 1.00 | 0.02 | 1521.74 | 14.3% | `UserRepository.updateLastAccessedAt` |
| 3.00 | 0.01 | 1425.74 | 13.4% | `BEGIN READ ONLY` (트랜잭션 제어) |

### 진단

- 병목 성격: **DB 쪽 병목 없음.** 응답시간을 지배하는 것은 DB 밖이고, 그것도 로컬 측정 환경의 자원 경합이다.
- 근거
  - 요청당 DB 시간은 전체 10,655.24 ms / 61,306건 = 0.1738 ms다. Little's Law로 계산한 평균 응답시간 97.87 ms(50 VU ÷ 510.871 RPS)의 **0.18%**에 불과하다.
  - 커넥션 풀 점유율 0.89% (10,655.24 ms / 풀 10 × 120,003 ms = 1,200,030 ms). 커넥션이 사실상 놀고 있어 대기 대상이 없다.
  - 대상 쿼리는 이미 `(user_id, solved_date)` 인덱스를 정확히 타는 술어(`user_id = ?` + `solved_date BETWEEN ?`)를 갖고 있고, mean 0.07 ms에 23행을 반환한다.
  - 톰캣 스레드 풀 대기도 아니다. `application.yml`, `application-perf.yml` 어디에도 `server.tomcat` 설정이 없어 기본값 `max-threads: 200`이 적용되는데 VU는 50이다.
  - JWT 검증 비용도 아니다. `JwtProvider.java:34,43`이 HS256(HMAC-SHA256) 대칭키를 쓴다.
  - 응답시간 분포가 꼬리가 길다: p95/med 4.76배, p99/med 14.08배, max/med 100.6배. 포화된 고정 크기 풀은 `weak-concepts` 기준선처럼 띠가 좁다(p95/med 1.31배, max/med 1.59배). 간헐적 자원 경합(CPU 스케줄링, GC)의 모양이며, 한 머신에서 k6 50 VU와 JVM과 PostgreSQL이 함께 도는 측정 구성과 부합한다.
- 예상 쿼리 목록과 어긋난 지점: 없음. 대상 쿼리 1.00회, 지연 로딩 없음, 반환 행 23.0으로 전부 예상과 일치했다.
- 부수 관측 (이번 사이클의 대상은 아니다)
  - `daily_learning_record`에 `(user_id, solved_date)` 인덱스가 **중복 생성**돼 있다. `uk_daily_learning_record_user_date`(UNIQUE CONSTRAINT)가 이미 같은 조합의 btree를 만드는데 `ix_daily_learning_record_user_date`가 따로 하나 더 있다. 조회에는 하나만 쓰이고 나머지는 INSERT마다 유지 비용만 낸다. 읽기 성능과는 무관하므로 이 대상의 개선 사이클로 다루지 않는다.
  - 인증 부수 쿼리(`users` SELECT 2회 + UPDATE 1회 + 트랜잭션 제어)가 DB 시간의 **57.8%**를 차지한다. 대상 쿼리(42.2%)보다 크다. 다만 전체 DB 시간 자체가 풀 용량의 0.89%라 개선 여지가 응답시간에 미치는 영향은 미미하다. 이 경로는 모든 인증 API가 공유하므로 별도 이슈로 다루는 것이 맞다.

---

## 사이클

돌지 않았다. Phase 4에서 DB 쪽 병목이 없다고 판정되어 적용할 기법이 없다.

---

## 최종 요약

> 개선 사이클 없이 종료. 기준선 측정값이 곧 최종값이다.

| 구분 | 지표 | 최초 = 최종 |
|---|---|---|
| 하드웨어 의존 | med | 42.78 ms |
| | p95 | 203.6272499999999 ms |
| | p99 | 602.2159999999999 ms |
| | RPS | 510.87112351348134 |
| 하드웨어 독립 | 요청당 쿼리 수 | 4 |
| | 요청당 DB 시간 | 0.1738 ms (응답시간의 0.18%) |
| | 검사 행 / 반환 행 | 23 / 23 (1:1) |
| | 스캔 방식 | `(user_id, solved_date)` 인덱스 사용. 술어와 정확히 일치 |
| | 커넥션 풀 점유율 | 0.89% |
| | 캐시 hit / miss, 적중률 | - |

적용한 기법: 없음

종료 사유: Phase 4 진단에서 DB 쪽 병목이 없음이 확인됐다. 대상 쿼리가 요청당 1회, mean 0.07 ms, 반환 행 대비 검사 행 1:1이고 커넥션 풀 점유율이 0.89%다. 인덱스, 쿼리 재작성, 캐싱 어느 쪽도 겨냥할 지점이 없다.
