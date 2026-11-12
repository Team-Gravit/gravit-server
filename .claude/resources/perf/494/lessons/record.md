# [PERF-494] GET /api/v1/lessons/{unitId}

> 이슈: #494
> 브랜치: refactor/494-lesson-query-performance
> 대상 디렉토리: `.claude/resources/perf/494/lessons/`

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
| 1 | 없음 - 기준선 진단 결과 개선 불필요 | ⏭️ | ⏭️ | ⏭️ | ⏭️ |

## 대상

- 엔드포인트: `GET /api/v1/lessons/{unitId}`
- 실행 경로: `JwtAuthFilter` → `LessonController` → `LessonFacade` → (`UnitQueryService`, `ChapterQueryService`, `LessonQueryService`, `BookmarkService`, `WrongAnsweredNoteService`) → 각 Repository
- 트랜잭션 경계: `LessonFacade.getAllLessonInUnit`에 `@Transactional(readOnly = true)` 단일 (`LessonFacade.java:56`)
- 예상 쿼리 목록 (요청 1회 기준, 고정 6개)
  1. `UserRepository.findById` - `users` PK 단건 조회. 인증 필터(`AuthTokenProvider.java:70`)에서 발생. 대상 API 밖에서 붙는 쿼리
  2. `UnitRepository.findUnitSummaryById` - `Unit` 단일 테이블 PK 조회, DTO 프로젝션 (`UnitRepository.java:42-47`)
  3. `ChapterRepository.findChapterBriefByUnitId` - `Chapter ⋈ Unit` 2테이블 조인, `WHERE u.id = ?` (`ChapterRepository.java:30-37`)
  4. `LessonRepository.findAllLessonSummaryByUnitId` - `Lesson` 단일 테이블, `WHERE l.unitId = ?`. 셀렉트 절에 `Problem` COUNT 스칼라 서브쿼리와 `LessonSubmission` EXISTS 서브쿼리가 레슨 행마다 붙는다 (`LessonRepository.java:48-63`)
  5. `BookmarkRepository.countByUnitIdAndUserId` - `Bookmark ⋈ Problem ⋈ Lesson` 3테이블 조인 COUNT, `WHERE l.unitId = ? AND b.userId = ?` (`BookmarkRepository.java:46-53`)
  6. `WrongAnsweredNoteRepository.countByUnitIdAndUserId` - `WrongAnsweredNote ⋈ Problem ⋈ Lesson` 3테이블 조인 COUNT, `WHERE l.unitId = ? AND wan.userId = ? AND wan.resolvedAt IS NULL` (`WrongAnsweredNoteRepository.java:56-63`)

### 기준선 이전에 선행한 정합성 수정

Phase 4의 워밍업에서 데이터 검증 check가 22.3%만 통과해 드러난 결함이다. 성능 기법이 아니라 응답 정합성 수정이므로 사이클에 넣지 않고 기준선(`-0`) 이전에 적용했다. `-0`은 이 수정이 적용된 상태다.

- 증상: `lessonSummaries`에 같은 레슨이 그 유저의 제출 횟수만큼 반복해서 실린다. 대상 유닛 900002에서 제출 이력이 없는 유저 223명(22.3%)만 정상 응답을 받았고, 이력이 있는 777명은 전원 중복 응답을 받았다
- 원인: `V29__convert_lesson_submission_to_history.sql`이 `lesson_submission`을 유저+레슨당 1행 덮어쓰기에서 제출마다 새 행을 쌓는 이력 구조로 바꿨는데(`try_count` 컬럼 삭제, 시도 횟수를 행 개수로 집계), `findAllLessonSummaryByUnitId`는 그 테이블을 `LEFT JOIN`으로 1:1처럼 붙인 채였다. `DISTINCT`도 집계도 없어 레슨 행이 제출 수만큼 복제됐다
- 수정: `LEFT JOIN LessonSubmission`을 `CASE WHEN EXISTS (...)` 서브쿼리로 대체했다. `LessonSummaryResponse.isSolved`는 제출 존재 여부만 필요하므로 이력 테이블을 조인할 이유가 없다
- 검증: `LessonQueryService`, `LessonFacade` 단위, 통합 테스트 통과
- 회귀 테스트: `LessonQueryServiceIntegrationTest`에 `같은_레슨을_여러_번_제출해도_레슨당_한_건만_반환한다`를 추가했다. 같은 레슨에 제출 3건을 넣고 응답이 1건인지, 레슨 id가 유일한지, `isSolved`가 `true`인지 검증한다. 기존 성공 케이스는 레슨당 제출 1건만 넣어 이 결함을 잡지 못했다

- 지연 로딩 추가 쿼리 후보: 없음. 2~6번 모두 `SELECT new ...Response(...)` DTO 프로젝션이거나 스칼라 COUNT라 엔티티를 반환하지 않는다
- N+1 후보: 4번의 `Problem` COUNT 스칼라 서브쿼리. JPQL 상으로는 SQL 1개지만 유닛 내 레슨 수만큼 서브플랜이 반복 실행될 수 있다. 실행계획으로 확인할 항목
- 사전 관찰(미검증)
  - `lesson.unit_id`에 인덱스가 없다(`V1__init_tables.sql:106-112`, 이후 마이그레이션에도 없음). 4번의 `WHERE l.unitId = ?`와 5, 6번의 조인 키가 모두 이 컬럼이다
  - `lesson_submission`에는 `ix_lesson_submission_user_created_at (user_id, created_at) INCLUDE (lesson_id)`가 있다(`V33`). 4번의 조인 조건은 `(lesson_id, user_id)` 순이라 이 인덱스가 어떻게 쓰이는지 확인이 필요하다
  - ~~`problem.lesson_id`에는 `ix_problem_lesson`이 있다(`V3`). 4번 서브쿼리와 5, 6번 조인이 이를 탈 수 있다~~ **틀림.** 마이그레이션 파일만 보고 단정한 것으로, 로컬 DB에는 이 인덱스가 없었다. 아래 "폐기한 1차 기준선" 참조
  - `bookmark (user_id, problem_id)` 유니크 인덱스(`V38`, #492에서 추가), `wrong_answered_note (user_id, problem_id)` 유니크 인덱스(`V34`)는 이미 있다

### 폐기한 1차 기준선 (로컬 스키마 드리프트)

1차 측정(p95 239.402ms, RPS 337.955, 상위 3개 쿼리가 실행시간의 97.12%)은 **폐기했다.** 로컬 DB가 dev, 운영과 다른 스키마 상태였다.

- 관측: `problem`에 PK 외 인덱스가 없어 `problem` 6,900행 전체 Seq Scan이 반복됐다. 레슨 목록 쿼리는 레슨 행마다(`loops=2`) 이 스캔을 돌려 전체 195버퍼 중 184를 썼고, 북마크와 오답노트 카운트 쿼리도 같은 Seq Scan(`cost=0.00..161.00`)을 탔다
- 원인: V3가 만드는 인덱스 3개(`ix_problem_lesson`, `ix_answer_problem`, `ix_option_problem`)가 로컬 DB에만 없었다. `flyway_schema_history`는 V3를 success로 기록하고 있고(2026-03-03), 이를 지우는 마이그레이션도 없다(`DROP INDEX`는 V36의 `ix_ul_league_rank` 하나뿐). dev DB에는 3개 모두 존재한다
- 없어진 3개는 전부 `content.sql`, `review.sql`이 대량 INSERT하는 테이블(`problem` 6,900 / `option` 13,800 / `answer` 3,450)이고, 살아있는 인덱스는 전부 대량 적재 이후 추가된 마이그레이션(V33, V34, V38) 것이다. 벌크 적재 전 수동 삭제 후 복구 누락으로 보이나 저장소에 흔적이 없어 정황 추론이다
- 조치: 로컬에 V3와 동일한 정의로 인덱스 3개를 재생성하고 기준선을 다시 잡았다. 두 측정 사이에 바뀐 것은 로컬 DB의 인덱스뿐이고 애플리케이션 코드는 그대로이므로 상태 번호는 `0`을 유지한다. 정합성 수정은 1차 측정 이전에 이미 적용돼 있어 두 측정 모두에 포함된다
- 파급: 같은 로컬 DB에서 측정한 #492의 기록도 `ix_problem_lesson`이 존재한다는 전제로 해석돼 있다(`492/wrong-answered-notes/record.md:154`). 그 이슈의 진단과 개선폭은 재검토가 필요하다

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application="gravit-perf"` 확인, `application_ready_time_seconds` 15.554) |
| 커넥션 풀 크기 | 60 (`application-perf.yml:17` `maximum-pool-size`) |
| 데이터 규모 | `lesson_submission` 317,300 / `wrong_answered_note` 195,700 / `bookmark` 156,000 / `problem` 6,900 / `users` 1,002 / `lesson` 230 / `unit` 66 / `chapter` 5. 대상 유닛 900002는 레슨 2건, 문제 60건, 레슨 제출 4,614건 |
| 카디널리티 | `lesson.unit_id` 66 (유닛당 3.5행) / `problem.lesson_id` 230 (레슨당 30행) / `lesson_submission.user_id` 1,000 (유저당 317행) / `lesson_submission.lesson_id` 148 / `bookmark.user_id` 1,000 / `wrong_answered_note.user_id` 1,000. 대상 유닛 900002에 제출 이력이 있는 유저 777명 (시드 유저 1,000명 중 77.7%). 응답 행 수 2건 |
| 부하 조건 | VU 50, 유지 1m (ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m). #490, #492와 동일 조건 |
| Redis 캐시 상태 | cold (measure 직전 FLUSHDB). 단 이 API는 Redis를 쓰지 않는다 |
| DB 캐시 상태 | 제어하지 않음. Redis FLUSHDB는 PostgreSQL의 `shared_buffers`와 OS page cache를 비우지 않는다 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` (PONG 확인) |
| 스키마 드리프트 | 있었음. V3의 `ix_problem_lesson`, `ix_answer_problem`, `ix_option_problem`이 로컬 DB에만 없어 기준선 이전에 복구했다(dev DB에는 3개 모두 존재). 복구 후 재검사에서 V2의 `gin_users_handle_trgm`, `ix_users_cover`, `ix_users_friends_covering`, `ix_users_handle_like_with_id` 4개가 추가로 드러났으나 **게이트 통과 기준의 예외로 처리하고 복구하지 않았다.** 근거: 4개 모두 `users` 테이블의 검색, 커버링 인덱스이고, 이번 대상이 `users`를 읽는 경로는 인증 필터의 PK 단건 조회(`AuthTokenProvider.parseUser`) 하나뿐이라 이 인덱스들을 타지 않는다. `users`를 검색 조건으로 읽는 대상(친구, 소셜 검색)을 측정할 때는 먼저 복구해야 한다 |
| 시드 SQL | 미사용. 이번 대상이 읽는 8개 테이블 전부 #490, #492 시드로 목표 규모에 도달해 있어 Phase 3-A에서 새로 돌리지 않았다 |
| 시드 모듈과 변수 | 없음 (기존 데이터 그대로 사용) |

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| p95 | 133.33449999999996 ms |
| p99 | 319.93609999999995 ms |
| RPS | 543.6218810323729 (요청 65,236건) |
| 에러율 | 0 |
| check 통과율 | 1 (3개 항목 전부 65,236/65,236) |
| 요청당 쿼리 수 | SQL 7개 (예상 6개 + `LastAccessInterceptor`의 UPDATE 1개), 트랜잭션 제어 별도 |

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.md` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 1.00 | 0.3302276035164658 | 21542.72794299995 | 29.085465926961536% | `WrongAnsweredNoteRepository.countByUnitIdAndUserId` |
| 1.00 | 0.310082543687537 | 20228.54481999992 | 27.311148925561273% | `BookmarkRepository.countByUnitIdAndUserId` |
| 1.00 | 0.30593950446073004 | 19958.269513000098 | 26.946242343003945% | `LessonRepository.findAllLessonSummaryByUnitId` |
| 2.00 | 0.017156888826721214 | 2238.4935990000463 | 3.0222555599135847% | `BEGIN READ ONLY` (트랜잭션 제어) |
| 1.00 | 0.029910295036482754 | 1951.2280069999752 | 2.634409897553009% | `UserRepository.updateLastAccessedAt` |

### 진단

- 병목 성격: **없음. 개선 불필요.** DB는 응답시간의 주된 요인이 아니다
- 근거
  - 요청당 DB 실행시간 합계가 1.10ms인데 med 응답은 62.2035ms다. DB 몫이 응답시간의 1.8%이므로, 상위 3개 쿼리를 0으로 만들어도 응답시간은 60ms대에 머문다
  - 상위 3개가 실행시간 비중 83.3%를 차지하지만 그 83.3%가 1.10ms의 83.3%다. 각 쿼리의 mean은 0.306~0.330ms이고 가장 무거운 것이 0.330ms다
  - N+1 없음. 모든 쿼리가 요청당 정확히 1.00회다(트랜잭션 제어 제외)
  - 커넥션 풀 경합 없음. 543.62 RPS × 1.10ms = 평균 0.6개 점유, 풀 크기 60
  - `problem.lesson_id` 인덱스는 사용된다. 드리프트 복구 전후로 상위 3개 쿼리 mean이 각각 -94.9%, -92.5%, -91.8% 변한 것이 근거다. 나머지 인덱스의 사용 여부는 **미확인**이다. 복구 후 EXPLAIN을 다시 뜨지 않았고(개선 사이클에 들어가지 않아 Phase 6을 건너뛰었다), 드리프트 상태의 실행계획에서는 `lesson`이 `Seq Scan`(`Rows Removed by Filter: 228`)이었다. `lesson.unit_id`에는 인덱스가 없으므로 복구 후에도 이 스캔은 남아 있을 것이다. 230행 3버퍼짜리라 비용은 무시할 수준이다
- 예상 쿼리 목록과 어긋난 지점: 2건
  1. `UserRepository.updateLastAccessedAt` - Phase 1 목록에 없던 쿼리다. `LastAccessInterceptor.preHandle`이 매 요청 호출한다. 행/호출이 0.000000이라 측정 내내 한 행도 갱신하지 않았다(시드 유저가 이미 당일 접근 처리된 상태). 읽기 전용 조회 API에 쓰기 트랜잭션이 하나 붙는 구조지만 비중 2.63%, mean 0.030ms로 이번 대상의 병목은 아니다
  2. `BEGIN READ ONLY`가 요청당 2회다. 파사드의 `@Transactional(readOnly = true)`는 하나인데 읽기 전용 트랜잭션이 두 번 열린다. 인증 필터(`AuthTokenProvider.parseUser`)가 파사드 밖에서 별도 트랜잭션을 여는 것으로 보인다. 비중 3.02%

---

## 최종 요약

> 하드웨어 의존 증거와 독립 증거를 모두 남긴다.

성능 기법을 적용하지 않고 종료했으므로 최초와 최종이 같다(`-0`). 아래 표는 측정 환경을 dev, 운영과 맞추기 위해 수행한 **로컬 인덱스 복구**의 전후이며, **개선 기법의 효과가 아니다.**

| 구분 | 지표 | 드리프트 상태 (폐기) | 인덱스 복구 후 (`-0`) | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 239.40159999999995 ms | 133.33449999999996 ms | -44.3% |
| | p99 | 625.1698399999999 ms | 319.93609999999995 ms | -48.8% |
| | RPS | 337.9550212256619 | 543.6218810323729 | +60.9% |
| 하드웨어 독립 | 요청당 쿼리 수 | SQL 7개 | SQL 7개 | 변화 없음 |
| | 요청당 DB 실행시간 합계 | 14.48 ms | 1.10 ms | -92.4% |
| | 검사 행 / 반환 행 | `problem` 6,900행 스캔(레슨 행마다 반복) / 2행 반환 | 인덱스 경로 / 2행 반환 | Seq Scan 제거 |
| | 스캔 방식 | `problem` Seq Scan (`ix_problem_lesson` 부재) | 인덱스 경로 (`ix_problem_lesson` 복구) | - |
| | 캐시 hit / miss, 적중률 | - (이 API는 캐시를 쓰지 않는다) | - | - |

적용한 기법: **없음.** 기준선 진단에서 개선 불필요로 판정했다. 요청당 DB 실행시간 1.10ms가 med 응답 62.2035ms의 1.8%이고, 가장 무거운 쿼리가 0.330ms이며, N+1과 커넥션 풀 경합이 모두 없다.

이번 이슈에서 실제로 해결한 것 (둘 다 성능 기법이 아니다):

1. **레슨 목록 응답 중복** - 정합성 결함. `LEFT JOIN LessonSubmission`을 `EXISTS` 서브쿼리로 대체 (커밋 `e1cd4837`)
2. **로컬 DB 스키마 드리프트** - 측정 환경 문제. V3 인덱스 3개를 로컬에 복구. dev와 운영은 정상이므로 코드 변경 없음. 재발 방지로 `optimize-performance` Phase 2에 스키마 드리프트 검사를 게이트로 추가했다

남은 일:

- #492 기록 재검토. 같은 로컬 DB에서 측정했고 `ix_problem_lesson`이 있다는 전제로 해석돼 있다 (`492/wrong-answered-notes/record.md:154`)
- 로컬 DB에 V2 인덱스 4개가 아직 없다 (`gin_users_handle_trgm`, `ix_users_cover`, `ix_users_friends_covering`, `ix_users_handle_like_with_id`). `users` 검색 관련 API를 측정할 때 복구가 필요하다
