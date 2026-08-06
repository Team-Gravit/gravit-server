# [PERF-490] GET /api/v1/chapters

> 이슈: #490
> 브랜치: refactor/490-chapter-unit-query-performance
> 대상 디렉토리: `.claude/resources/perf/490/chapters/`

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

- 엔드포인트: `GET /api/v1/chapters`
- 실행 경로: `ChapterController.getAllChapter` → `ChapterFacade.getAllChapter` → (`ChapterQueryService`, `LearningProgressRateService`) → (`ChapterRepository`, `LessonSubmissionRepository`, `LessonRepository`)
- 트랜잭션 경계: `open-in-view: false`. 요청 1회가 트랜잭션 3개로 쪼개진다 - 필터의 SELECT, 인터셉터의 UPDATE, 파사드의 `@Transactional(readOnly = true)`
- 예상 쿼리 목록 (요청 1회 기준, `n` = 전체 챕터 수, `k` = 그중 제출 이력이 0건인 챕터 수, `0 <= k <= n`)

  **API 밖 (필터, 인터셉터)**
  1. `UserRepository.findById` - SELECT. `JwtAuthFilter:81` → `AuthTokenProvider.parseUser:70`. 1회
  2. `UserRepository.updateLastAccessedAt` - `@Modifying` 벌크 UPDATE. `LastAccessInterceptor:30` → `UserAccessService:25`.
     `WHERE ... lastAccessedAt < :startOfToday` 조건에 걸리지 않아도 쿼리 자체는 나간다. 1회

  **파사드 (`ChapterFacade:21~35`)**
  3. `ChapterRepository.findAllChapterSummary` - `FROM Chapter c`, 조건 없는 전체 조회. 1회
  4. `LessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId` - `COUNT(DISTINCT l.id)`, `LessonSubmission` JOIN `Lesson` JOIN `Unit`. 챕터마다 1회, 총 `n`회
  5. `LessonRepository.countTotalLessonByChapterId` - `COUNT(l.id)`, `Chapter` JOIN `Unit` JOIN `Lesson`. `solvedLessonCount == 0`이면 조기 반환(`LearningProgressRateService:23~25`)이라 건너뛴다. 총 `n - k`회

  **합계: `3 + 2n - k`** (하한 `3 + n`, 상한 `3 + 2n`)

  지연 로딩 지점 없음. 세 파사드 쿼리 모두 record projection 또는 스칼라 카운트라 엔티티를 적재하지 않는다.

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application="gravit-perf"` 확인) |
| 커넥션 풀 크기 | 60 (`application-perf.yml:17` `maximum-pool-size`) |
| 데이터 규모 | `users` 1,002 / `chapter` 5 / `unit` 66 / `lesson` 230 / `lesson_submission` 317,300. 현재 규모 유지로 확정, 시드 미사용 |
| 카디널리티 | `lesson_submission.user_id` 1,000 / `lesson_submission.lesson_id` 148 (`lesson` 230개 중 82개는 제출 이력 없음). `unit.chapter_id` 5 / `lesson.unit_id` 66 (`units` 대상에서 측정, 행 수가 그대로라 유효) |
| 부하 조건 | VU 50. ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m. 이슈 472, 475, 490-units와 동일 조건 |
| Redis 캐시 상태 | cold (measure 직전 FLUSHDB) |
| DB 캐시 상태 | 제어하지 않음. Redis FLUSHDB는 PostgreSQL의 `shared_buffers`와 OS page cache를 비우지 않는다. 둘을 묶어 cold라고 적지 마라 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` (PONG 확인) |
| 시드 SQL | 미사용 (현재 규모로 진행) |
| 시드 모듈과 변수 | - |
| 유저 범위 | `USER_ID_START=1001`, `USER_COUNT=1000`. `lesson_submission`의 distinct user 1,000과 일치 |
| chapterId 분산 | 없음. 이 API는 경로 변수 없이 전체 챕터(900001~900005)를 매 요청에 훑는다 |

**챕터별 레슨 수 (편중)**

| chapter_id | lesson_count |
|---|---|
| 900001 | 126 |
| 900002 | 26 |
| 900003 | 26 |
| 900004 | 26 |
| 900005 | 26 |

챕터 하나가 전체 레슨 230개의 55%를 갖는다. `countTotalLessonByChapterId`와
`countSolvedLessonByChapterIdAndUserId`의 챕터별 비용이 균등하지 않다.

**요청당 쿼리 수 (Phase 1 예측을 실측 분포로 확정)**

`n`(전체 챕터 수) = 5로 고정. `k`(제출 이력 0건인 챕터 수)만 유저마다 다르다.

| 제출 이력 있는 챕터 수 | 유저 수 | `k` | 요청당 쿼리 (`3 + 2n - k`) |
|---|---|---|---|
| 4 | 154 | 1 | 12 |
| 5 | 846 | 0 | 13 |

가중 평균 **12.85**. 유저 1,000명을 균등 순회하므로 이 값이 요청당 기대치다.
조기 반환(`LearningProgressRateService:23~25`)은 154명에게 챕터 1개씩만 걸려 거의 작동하지 않는다.
Phase 4의 실측으로 확정한다.

**데이터 규모 판단 (호출자 확정)**

`chapter` 5행을 목표 규모로 확정했다. 운영 실제 콘텐츠 규모이고 `units` 대상과 동일 조건이라 이슈 내 비교가 가능하다.
증설안(20행)은 N+1 기울기를 4배로 키우지만 `unit`·`lesson`·`lesson_submission` 동반 시드가 필요하고
`units` 대상과 조건이 어긋나 배제했다.

**Phase 2 게이트 통과 기록**

| 검증 항목 | 관측값 |
|---|---|
| perf 프로파일 기동 | `application="gravit-perf"` |
| actuator health | 200 |
| 응답시간 히스토그램 버킷 수 | 146 |
| `pg_stat_statements` | 47행 (살아있음) |
| Redis 캐시 제어 | PONG |

`units` 대상 Phase 7 적용 후 애플리케이션을 재기동했으므로 Skip 조건이 성립하지 않아 게이트를 다시 통과시켰다.
관측값은 `units` 때와 동일하다.

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| p95 | 189.25139999999993 ms |
| p99 | 463.67911999999995 ms |
| med | 83.6445 ms |
| max | 2033.209 ms |
| RPS | 397.0506729592537 (요청 47,680건) |
| 에러율 | 0 |
| check 통과율 | 1 (세 항목 모두 47,680 통과 / 0 실패) |
| 요청당 쿼리 수 | SQL 12.8459941275167785 + 트랜잭션 제어 3.00014681208053691275 = 왕복 15.85회 |
| 요청당 DB 실행시간 | 105493.00377599859ms / 47680 = 2.2125 ms |

`waiting_ms` med 83.503 / `duration_ms` med 83.6445. 전송 시간은 무시할 수준이고 전부 서버 대기다.

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.md` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 5.0000000000000000 | 0.3010765931082263 | 71776.65979699792 | 68.03926064083532% | `LessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId` |
| 4.8459941275167785 | 0.12106246924351827 | 27972.33095600065 | 26.515816172413153% | `LessonRepository.countTotalLessonByChapterId` |

상위 2개가 DB 실행시간의 94.55507681324847%를 차지한다. 배경 노이즈는
`SeasonRepository.findCloseableActiveByNowForUpdate` 7회(비중 0.00028643510866523315%)뿐이다.
로컬 `application.yml:104`가 시즌 롤오버 cron을 `*/30 * * * * *`로 덮어써 30초마다 도는 것으로, 대상 API와 무관하다.

### 진단

- 병목 성격: **N+1**. 요청당 상호작용 횟수가 비용을 지배한다. 개별 쿼리의 실행시간 문제가 아니다
- 근거
  - 상위 2개 쿼리의 mean은 0.3010765931082263ms, 0.12106246924351827ms로 개별 실행은 빠르다.
    그럼에도 DB 실행시간의 94.56%를 차지하는 이유는 호출 수(238,400회, 231,057회)뿐이다
  - 요청당 DB 실행시간 2.2125ms 대 med 응답시간 83.6445ms. 격차 81.43ms를 왕복 15.85회로 나누면 왕복당 5.14ms다.
    loopback RTT(통상 0.05~0.2ms)로 설명되지 않으므로, 순수 네트워크 지연이 아니라
    왕복마다 붙는 처리비용(JDBC 직렬화, Hibernate 세션, `total_exec_time`에 잡히지 않는 PG 파싱·프로토콜)에
    50 VU 동시성의 대기가 얹힌 값이다
  - 동시성 몫 분리 (Little의 법칙, warmup은 JIT 미완이라 참고용 교차검증):
    5 VU에서 173 RPS → 평균 응답 28.9ms, 왕복당 1.82ms.
    measure의 평균 동시성 37.5 VU에서 397 RPS → 평균 응답 94.4ms, 왕복당 5.3ms.
    경합이 거의 없는 5 VU에서도 DB 실행 2.2ms짜리 요청이 28.9ms 걸린다.
    나머지 26.7ms가 왕복 15.85회에 붙는 고정비고, 동시성이 오르면 약 3배로 증폭된다
  - 따라서 왕복 횟수를 줄이면 고정비와 증폭분이 함께 줄어든다
- 예상 쿼리 목록과 어긋난 지점: 없음. Phase 1 예측 `3 + 2n - k`와 Phase 3의 가중 기대치 12.85가
  실측 12.8459941275167785와 소수 넷째 자리까지 일치한다. `countTotalLessonByChapterId`의
  예측값 `(846×5 + 154×4)/1000 = 4.846`도 실측 4.8459941275167785와 일치한다

---

## 사이클 1: 단일 집계 쿼리로 N+1 제거

### 설계 결정

> Phase 5-B에서 호출자와 확정한 내용.

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 쿼리 분할 | `findAllChapterSummary` 유지 + 집계 쿼리 1개 추가 (1안) | 챕터 메타 조회와 진행도 집계를 분리해 두고 `units` 대상과 같은 모양을 유지한다. 2안(집계 쿼리 하나에 `c.title`, `c.description`까지 담아 `findAllChapterSummary` 제거)보다 왕복이 1회 많다(7 대 6) |
| 쿼리 배치 | `ChapterRepository.findChapterProgressByUserId` (a안) | 쿼리가 `FROM Chapter c`로 시작하므로 주 엔티티와 리포지토리가 일치한다. `units` 선례(`UnitRepository:59`)와 같은 모양 |
| 서비스 배치 | `ChapterQueryService.getAllChapterProgress(long userId)`, `@Transactional(readOnly = true)` | 리포지토리와 같은 도메인. `units`는 `UnitQueryService.getAllUnitProgressInChapter` |
| 내부 DTO | `chapter/dto/internal/ChapterProgressRowDto(chapterId, totalLessons, solvedLessons)` | `UnitProgressRowDto`의 필드 순서를 따른다. 1안이라 `title`은 넣지 않는다 |
| 조인 방식 | `Chapter` → `Unit` → `Lesson` → `LessonSubmission` 전부 `LEFT JOIN`, `ls.userId = :userId`는 조인 조건에 둔다 | 제출 이력이 없는 챕터도 행을 남겨야 한다. `WHERE`로 내리면 그 챕터가 결과에서 사라진다 |
| 집계 함수 | 양쪽 다 `COUNT(DISTINCT ...)` | `LessonSubmission`을 조인하면 `l.id`가 제출 건수만큼 중복된다. 기존 `countTotalLessonByChapterId`의 `COUNT(l.id)`를 그대로 쓰면 총 레슨 수가 부풀어 진행률이 틀어진다 |
| 진행률 계산 | `LearningProgressRateService.calculateProgressRate(solved, total)` 재사용, 누락 시 `NOT_STARTED_PROGRESS_RATE = 0.0` | `units` 사이클 1에서 이미 추가한 순수 계산 메서드 |
| 기존 메서드 정리 | `getChapterProgress`, `countSolvedLessonByChapterIdAndUserId`, `countTotalLessonByChapterId` **유지** | `LearningFacade:48`, `UserFacade:118`이 `recentSolvedChapterId` 단건으로 호출한다. 그쪽은 N+1이 아니다. `units` 커밋(`fd3482c7`)이 `countSolvedLessonByUnitIdAndUserId`를 지운 것과 다른 지점 |

- 검토했지만 택하지 않은 안
  - **인덱스 추가·조정**: 상위 2개 쿼리의 mean이 0.3010765931082263ms / 0.12106246924351827ms로 개별 실행이 이미 빠르다.
    실행시간을 0으로 만들어도 요청당 DB 실행이 2.2125 → 0.31ms, med 83.6445ms 기준 2.3% 미만이고 왕복 15.85회는 그대로다
  - **챕터 목록 캐싱**: `findAllChapterSummary`는 DB 시간의 1.2682330686505523%뿐이라 단독 효과가 작다
  - **유저별 챕터 진행도 캐싱**: 효과가 이 기법과 겹치는데 무효화 경로가 넓다.
    레슨 제출마다 해당 유저의 챕터 진행도를 무효화해야 하고, 놓치면 진행도가 틀린 채 남는다
- 예상 효과 (호출자는 별도 목표치를 두지 않고 설계를 승인했다. 아래는 기준선 수치에서 도출한 값)
  - 요청당 왕복 15.85 → **7.00회** (SQL 12.85 → 4, 트랜잭션 제어 3 유지)
  - `lesson_submission` 검사 행: 유저당 약 317행을 챕터마다 반복해 요청당 약 1,585행 → **약 317행**.
    `ix_lesson_submission_user_created_at (user_id, created_at) INCLUDE (lesson_id)`가 `WHERE ls.user_id = ?`만으로
    index-only scan을 지원하므로, 챕터별 반복이 사라지면 그대로 5배가 줄어든다
  - 응답시간: 왕복 고정비로 환산하면 저동시성(5 VU, 왕복당 1.82ms) 기준 요청당 약 16ms 절감.
    50 VU에서는 왕복당 환산치가 5.14ms까지 커지므로 절감폭이 더 크다
  - **DB 실행시간은 목표가 아니다.** 새 쿼리는 4중 LEFT JOIN + GROUP BY라 단건 실행시간이 기존 0.301ms보다 크다.
    요청당 DB 실행시간(2.2125ms)이 줄지 않거나 늘 수 있다. 판정은 왕복 횟수와 검사 행 수로 한다

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 189.25139999999993 ms / 463.67911999999995 ms (med 83.6445) |
| RPS | 397.0506729592537 |
| 요청당 쿼리 수 | SQL 12.8459941275167785 + 트랜잭션 제어 3.00014681208053691275 = 왕복 15.85회 |
| 대상 쿼리 calls / mean_ms / total_ms | `countSolvedLessonByChapterIdAndUserId` 238400 / 0.3010765931082263 / 71776.65979699792 (비중 68.04%)<br>`countTotalLessonByChapterId` 231057 / 0.12106246924351827 / 27972.33095600065 (비중 26.52%) |
| 부하 조건 | VU 50, 총 2m, 커넥션 풀 60, `chapter` 5 / `unit` 66 / `lesson` 230 / `lesson_submission` 317,300 |

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`)

- EXPLAIN 파라미터: chapterId = 900003, userId = 1500 (이후 모든 사이클에서 동일하게 사용)
  - chapterId는 챕터 5개의 중앙값. 900001은 레슨 126개로 나머지(26개)와 동떨어진 극단값이라 피했다
  - userId는 `USER_ID_START` 1001 ~ 2000의 중앙. 이 조합의 solved는 26으로 0건이 아니다
- **절대 시간은 근거로 쓰지 않는다.** psql이 매 실행 새 커넥션을 열어 계획 캐시가 없는 탓에
  Planning Time이 302.770ms / 109.802ms, 쿼리 1의 Execution Time이 17.879ms로 나왔다.
  같은 쿼리의 부하 테스트 mean은 0.3010765931082263ms(238,400회)다. 구조만 근거로 쓴다
- 스캔 방식
  - 쿼리 1: `lesson_submission`은 `ix_lesson_submission_user_created_at (user_id, created_at) INCLUDE (lesson_id)`로
    **Index Only Scan, Heap Fetches 0**. `lesson`(230행)과 `unit`(66행)은 Seq Scan 후 Hash Join
  - 쿼리 2: `chapter`(5행), `unit`(66행), `lesson`(230행) 전부 Seq Scan. Nested Loop + Hash Join
  - 세 테이블 모두 1~3페이지라 Seq Scan이 올바른 선택이다. 인덱스 부재가 문제인 계획이 아니다
- actual rows 대 반환 행 수
  - 쿼리 1: Index Only Scan 317행 → Hash Join 78행 → Aggregate 1행.
    317행은 user 1500의 **전체 챕터 제출분**이고, 그중 239행은 다른 챕터 것이라 조인에서 버려진다.
    `chapter_id`가 `unit`에 있어 두 조인 건너에 있으므로 챕터 조건을 인덱스 스캔까지 밀어넣을 수 없다.
    그래서 챕터마다 같은 317행을 다시 읽는다. 요청당 약 1,585행
  - 쿼리 2: 26행 → 1행
- Rows Removed by Filter: 두 계획 모두 `unit` Seq Scan에서 53 (66행 읽어 13행만 사용), 쿼리 2의 `chapter` Seq Scan에서 4
- shared hit / read: 쿼리 1 최상단 16 / 0 (128KB), 쿼리 2 최상단 6 / 0 (48KB). 두 계획 모두 디스크까지 내려간 적 없음
- 플래너 추정 대 실측: 315/317, 62/78, 45/26으로 최대 1.7배. 10배 이상 괴리는 없다
- 위험 신호 판정

  | 지표 | 기준 | 관측 | 신호 |
  |---|---|---|---|
  | 검사 행 / 반환 행 | 100:1 초과 | 317 / 1 (집계라 반환은 항상 1), 조인 통과 기준 317 / 78 | 판단 보류 |
  | 플래너 추정 대 실측 | 10배 이상 | 최대 1.7배 | 없음 |
  | 단일 쿼리 total_exec_time 점유율 | 30% 이상 | 68.03926064083532% | **있음** |
  | OLTP 경로의 Seq Scan | 1만 행 이상 테이블 | `lesson` 230, `unit` 66, `chapter` 5 | 없음 |
  | 동일 쿼리의 요청당 호출 횟수 | 1회 초과 | 5.0회 / 4.8459941275167785회 | **있음** |

  신호가 켜진 두 항목이 모두 호출 횟수에서 나온다. 노드 단위로 비싼 곳은 없다.
  계획이 드러내는 것은 노드 하나의 비용이 아니라 챕터마다 같은 317행을 다시 읽는 반복이다

**로직 개선 기법의 추가 캡처 — 변경 전 요청당 쿼리 수와 호출 스택**

```
ChapterController.getAllChapter (ChapterController:24)
└ ChapterFacade.getAllChapter (ChapterFacade:21)  @Transactional(readOnly = true)
    ├ ChapterQueryService.getAllChapter (ChapterQueryService:22)
    │   └ ChapterRepository.findAllChapterSummary          ... 1회
    └ chapters.stream().map(...)  — 챕터 n=5개를 순차 순회
        └ LearningProgressRateService.getChapterProgress (LearningProgressRateService:17)
            ├ LessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId  ... 챕터마다 1회, 총 5회
            └ LessonRepository.countTotalLessonByChapterId ... solvedCount>0인 챕터만, 총 4.85회
                (solvedLessonCount == 0이면 LearningProgressRateService:23~25에서 조기 반환)
```

`stream().map`은 순차 실행이므로 9.85회의 왕복이 직렬로 쌓인다.

### 적용 내용

| 파일 | 변경 |
|---|---|
| `chapter/dto/internal/ChapterProgressRowDto.java` | 신규. `(chapterId, totalLessons, solvedLessons)`. 같은 패키지의 `ChapterSolvedStatDto` 형식을 따랐다 |
| `chapter/repository/ChapterRepository.java` | `findChapterProgressByUserId(userId)` 추가. `FROM Chapter c` + `Unit`, `Lesson`, `LessonSubmission` 3중 LEFT JOIN + `GROUP BY c.id` |
| `chapter/service/ChapterQueryService.java` | `getAllChapterProgress(userId)` 추가, `@Transactional(readOnly = true)` |
| `chapter/facade/ChapterFacade.java` | 챕터별 `getChapterProgress` 루프 제거. 집계 결과를 `Map<Long, Double>`로 만들고 `calculateProgressRate(solved, total)` 재사용. 누락 시 `NOT_STARTED_PROGRESS_RATE = 0.0` |
| `test/.../ChapterFacadeUnitTest.java` | 새 협력 객체 경로로 수정. `집계에_없는_챕터는_진행도가_0이다` 케이스 추가 |
| `test/.../ChapterQueryServiceUnitTest.java` | `GetAllChapterProgress` 중첩 클래스 추가 |

**손대지 않은 것** — `LearningProgressRateService.getChapterProgress`,
`LessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId`, `LessonRepository.countTotalLessonByChapterId`.
`LearningFacade:48`, `UserFacade:118`이 `recentSolvedChapterId` 단건으로 호출하며 그쪽은 N+1이 아니다.

**쿼리 설계상 주의점 (구현 근거)**

- `COUNT(DISTINCT l.id)` — `LessonSubmission`을 조인하면 같은 레슨이 제출 건수만큼 중복된다.
  `COUNT(l.id)`를 쓰면 총 레슨 수가 줄 수만큼 부풀어 진행률이 낮게 나온다.
  기존 `countTotalLessonByChapterId`가 `COUNT(l.id)`여도 문제없던 건 제출 테이블을 조인하지 않아서다
- `ls.userId = :userId`를 `ON`에 둔다 — `WHERE`로 내리면 제출이 없어 `ls`가 null인 행이 걸러져
  해당 챕터가 결과에서 통째로 사라진다
- `COUNT`는 null을 세지 않으므로 제출 이력이 없는 챕터는 별도 분기 없이 `solvedLessons = 0`이 된다.
  기존의 `solvedLessonCount == 0` 조기 반환이 하던 역할을 집계가 대신한다

- 테스트: `./gradlew test` 통과

### 개선 후 지표

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 189.25139999999993 ms | 125.61419999999995 ms | −33.6% |
| | p99 | 463.67911999999995 ms | 328.7562199999998 ms | −29.1% |
| | med | 83.6445 ms | 52.239 ms | −37.5% |
| | RPS | 397.0506729592537 | 589.2846296260478 | +48.4% |
| | 처리 요청 수 | 47,680 | 70,715 | +48.3% |
| | 에러율 / check 통과율 | 0 / 1 | 0 / 1 | 동일 |
| 하드웨어 독립 | 요청당 SQL | 12.8459941275167785 | 4.0 | −68.9% |
| | 요청당 왕복 (SQL + 트랜잭션 제어) | 15.85 | 7.00 | −55.8% |
| | 요청당 DB 실행시간 | 2.2125210943372 ms | 1.3445919 ms | −39.2% |
| | 진행도 집계 부분의 요청당 실행시간 | 2.09206 ms (9.85개 쿼리) | 1.1704637619882787 ms (1개 쿼리) | −44.1% |
| | 대상 쿼리 total_ms | `countSolved` 71776.65979699792 + `countTotal` 27972.33095600065 | `findChapterProgressByUserId` 82769.34492900038 | 요청 수가 달라 total 직접 비교는 무의미. 요청당 값으로 본다 |
| | 검사 행 / 반환 행 | `lesson_submission` 약 1,585행 (317 × 5회) → 5행 | **317행 (317 × 1회) → 5행** | 검사 행 −80% |
| | 만진 버퍼 / 요청 | 약 109.1페이지 (872.6 KB) | **17페이지 (136 KB)** | −84.4% |
| | 스캔 방식 | `lesson_submission` Index Only Scan(Heap Fetches 0) + `lesson`·`unit` Seq Scan + Hash Join, 요청당 9.85회 반복 | 동일한 스캔 방식이되 Hash Right Join 3단 + Sort + GroupAggregate, **loops 전부 1** | 스캔 종류는 그대로, 반복이 사라짐 |
| | Rows Removed by Filter | `unit` Seq Scan에서 53 (두 쿼리 모두) | **0 (Filter 노드 자체가 없음)** | 해소 |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클 아님 |

**실행계획 변화 (`query-plan-1.txt`, userId 1500)**

- EXPLAIN 파라미터: userId = 1500 (Phase 6과 동일). **chapterId = 900003은 이번 쿼리에 존재하지 않는다.**
  챕터별 필터를 없앤 것이 이 기법의 핵심이므로 파라미터가 하나 사라진 것이고, 값을 바꾼 것이 아니다
- 계획 구조: GroupAggregate ← Sort(quicksort, Memory 51kB, Batches 1 — 디스크 스필 없음) ← Hash Right Join 3단
  ← Index Only Scan `ix_lesson_submission_user_created_at`(실측 317행, Heap Fetches 0) + `lesson`(230) · `unit`(66) · `chapter`(5) Seq Scan
- 조인 결과 430행은 제출 317건이 레슨과 곱해져 부푼 값이고, `COUNT(DISTINCT)`가 여기서 중복을 걷어낸다
- 플래너 추정 대 실측: 316/317, 316/430(1.36배), 5/5. 10배 이상 괴리 없음
- Planning Time 302.770ms → **3.518ms**. Phase 6에서 "302ms는 psql 콜드 커넥션 노이즈"라고 본 판단이 이 값으로 확인된다.
  Execution Time 1.653ms도 부하 테스트의 mean 1.1704637619882787ms와 같은 자릿수로 맞는다

**Phase 5 예상과 실측 대조**

| 예상 | 실측 | 판정 |
|---|---|---|
| 요청당 왕복 15.85 → 7.00회 | 15.85 → 7.00 | 일치 |
| `lesson_submission` 검사 행 약 1,585 → 약 317 (5배 감소) | 317 × 1회 | 일치 |
| DB 실행시간은 목표가 아니며 줄지 않거나 늘 수 있다 | 2.2125 → 1.3446 ms (−39.2%) | **빗나감. 예상보다 좋다** |

마지막 항목의 어긋난 가정: 집계 쿼리의 **단건** 실행시간이 커진다는 예측은 맞았다(0.3010765931082263 → 1.1704637619882787ms, 3.9배).
틀린 것은 그 증가가 상쇄되지 않으리라 본 부분이다. 9.85건을 1건으로 줄인 효과가 단건 증가를 덮고도 남았다.
같은 317행을 챕터마다 다시 읽던 낭비가 사라진 만큼이 실행시간으로 돌아왔다.

### 판정

- 개선 여부 (하드웨어 독립 증거 기준): **있음**
  - 요청당 SQL 12.8459941275167785 → 4.0, 왕복 15.85 → 7.00. Phase 5의 예측값과 소수점까지 일치한다.
    이 수치는 코드 경로에서 결정되므로 부하 상황에 따라 달라지지 않는다. 측정 편차로 설명할 수 없다
  - 실행계획의 `loops`가 전부 1이 되었고 `Rows Removed by Filter`가 0이 되었다
  - 만진 버퍼가 요청당 109.1페이지 → 17페이지
  - 하드웨어 의존 지표(p95 −33.6%, RPS +48.4%)는 같은 방향을 가리키지만,
    로컬 한 대에서 k6·JVM·PostgreSQL이 CPU를 공유한 결과이므로 방향으로만 읽는다. 운영 개선폭의 예측치가 아니다
- 남은 위험 신호
  - **단일 쿼리 total_exec_time 점유율 87.04973879038928% (기준 30% 초과)**.
    다만 성격이 바뀌었다. 개선 전에는 같은 일을 9.85번 나눠 하며 68.04%였고, 지금은 한 번에 하며 87.05%다.
    분모인 요청당 DB 실행시간이 2.2125 → 1.3446ms로 줄어든 상태에서의 점유율이다
  - 해소된 신호: 동일 쿼리의 요청당 호출 횟수(5.0 / 4.85 → 전부 1.0), `Rows Removed by Filter`(53 → 0)
- 다음 사이클 진행 여부: **종료.** 남은 왕복 7회 중 집계 쿼리는 실행계획상 더 깎을 데가 없고
  (Filter 0, Index Only Scan Heap Fetches 0, 소형 테이블 Seq Scan이 최적, Sort는 51kB 인메모리),
  필터·인터셉터 2회는 전체 API 공통 경로라 이 대상만의 문제가 아니다.
  검토한 사이클 2 후보와 배제 근거는 아래와 같다

  | 후보 | 효과 | 배제 근거 |
  |---|---|---|
  | 챕터 목록 캐싱 | 왕복 7.00 → 6.00 (−14.3%), DB 시간 −2.53% | 캐시 계층과 어드민 변경 시 무효화를 추가하는 비용에 비해 효과가 작다 |
  | 유저별 진행도 캐싱 | DB 시간 −87.05% (캐시 히트 시) | 레슨 제출 경로 전반에 무효화를 심어야 하고, 놓치면 진행도가 틀린 채 남는다 |
  | 집계 쿼리 튜닝 (인덱스) | — | 실행계획에 낭비가 없다. `Rows Removed by Filter` 0, 추정 대 실측 최대 1.36배 |

---

## 최종 요약

> 하드웨어 의존 증거와 독립 증거를 모두 남긴다.

| 구분 | 지표 | 최초 (상태 0) | 최종 (상태 1) | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 189.25139999999993 ms | 125.61419999999995 ms | −33.6% |
| | p99 | 463.67911999999995 ms | 328.7562199999998 ms | −29.1% |
| | med | 83.6445 ms | 52.239 ms | −37.5% |
| | RPS | 397.0506729592537 | 589.2846296260478 | +48.4% |
| | 에러율 / check 통과율 | 0 / 1 | 0 / 1 | 동일 |
| 하드웨어 독립 | 요청당 SQL | 12.8459941275167785 | 4.0 | −68.9% |
| | 요청당 왕복 (SQL + 트랜잭션 제어) | 15.85 | 7.00 | −55.8% |
| | 요청당 DB 실행시간 | 2.2125210943372 ms | 1.3445919 ms | −39.2% |
| | 검사 행 / 반환 행 | `lesson_submission` 약 1,585행 (317 × 5회) → 5행 | 317행 (317 × 1회) → 5행 | 검사 행 −80% |
| | 만진 버퍼 / 요청 | 약 109.1페이지 (872.6 KB) | 17페이지 (136 KB) | −84.4% |
| | 스캔 방식 | `lesson_submission` Index Only Scan(Heap Fetches 0) + `lesson`·`unit` Seq Scan + Hash Join을 요청당 9.85회 반복 | 같은 스캔 방식으로 Hash Right Join 3단 + Sort + GroupAggregate, loops 전부 1 | 스캔 종류는 그대로, 반복이 사라짐 |
| | Rows Removed by Filter | `unit` Seq Scan에서 53 (두 쿼리 모두) | 0 (Filter 노드 없음) | 해소 |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클 없음 |

적용한 기법: 사이클 1 — 단일 집계 쿼리로 N+1 제거 (`ChapterRepository.findChapterProgressByUserId`)

측정 조건: perf 프로파일, VU 50, ramp-up 30s + 유지 1m + ramp-down 30s (총 2m), 커넥션 풀 60,
Redis 캐시 cold(측정 직전 FLUSHDB), DB 캐시 제어하지 않음, 시드 미사용
(`chapter` 5 / `unit` 66 / `lesson` 230 / `lesson_submission` 317,300 / `users` 1,002).
상태 0과 상태 1의 조건은 동일하다.

하드웨어 의존 지표는 로컬 한 대에서 k6·JVM·PostgreSQL이 CPU를 공유한 결과이므로 방향으로만 읽는다.
운영 환경의 개선폭 예측치가 아니다.
