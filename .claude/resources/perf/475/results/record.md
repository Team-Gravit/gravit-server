# [PERF-475] POST /api/v1/lessons/results

> 이슈: #475
> 브랜치: refactor/475-lesson-submission-save
> 대상 디렉토리: `.claude/resources/perf/475/results/`

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
| 1 | `wrong_answered_note (user_id, problem_id)` 유니크 인덱스 | ✅ | ✅ | ✅ | ✅ |
| 2 | 오답노트 저장 UPSERT 전환 (`unnest` + `ON CONFLICT`) | ✅ | ✅ | ✅ | ✅ |
| 3 | `problem_submission` 다중행 INSERT (`jsonb_to_recordset`) | ✅ | ✅ | ✅ | ✅ |

**9. 보고**: ✅ 완료 (2026-07-29). 사이클 3회로 종료.

## 대상

- 엔드포인트: `POST /api/v1/lessons/results`
- 실행 경로: `LessonController:35` → `LessonFacade:74` (`@Transactional`) → 9개 Service → 9개 Repository
  → `LessonCompletedEvent` 발행 시 `@TransactionalEventListener(AFTER_COMMIT)` 리스너 4개 (모두 `@Async` 없음, 요청 스레드에서 실행)
- 변수: **N** = 요청의 문제 풀이 개수, **W** = 그중 오답 개수(W ≤ N), **F** = 첫 풀이 여부(`isFirstTry`)

### 예상 쿼리 목록 (요청 1회 기준)

**메인 트랜잭션 — `LessonFacade.saveLessonSubmission`**

| # | Repository 메서드 | 쿼리 요지 | 횟수 |
|---|---|---|---|
| 1 | `LessonRepository.findLearningIdsByLessonId` | SELECT lesson ⋈ unit ⋈ chapter, 아이디 3개 추출 | 1 |
| 2 | `ProblemRepository.findProblemTypesByIds` | SELECT problem WHERE id IN (:problemIds) | 1 |
| 3 | `LessonSubmissionRepository.existsByLessonIdAndUserId` | 첫 풀이 여부 exists (파생 쿼리) | 1 |
| 4 | `LessonSubmissionRepository.save` | INSERT lesson_submission | 1 |
| 5 | `ProblemSubmissionRepository.saveAll` | INSERT problem_submission | **N** |
| 6 | `WrongAnsweredNoteRepository.findByProblemIdAndUserId` | SELECT wrong_answered_note WHERE problem_id, user_id | **W** |
| 7 | `WrongAnsweredNoteRepository.save` | 신규면 INSERT, 기존이면 flush 시 UPDATE | **W** |
| 8 | `UnitRepository.findUnitSummaryByLessonId` | SELECT unit ⋈ lesson | 1 |
| 9 | `UserLeagueRepository.findUserLeagueNameByUserId` | SELECT user_league ⋈ league, 리그명 | 1 |
| 10 | `UserRepository.findById` | SELECT users (`level`은 `@Embedded`, 추가 쿼리 없음) | 1 |
| 11 | `LearningRepository.findByUserId` | SELECT learning | 1 |
| 12 | `LessonSubmissionRepository.countDistinctLessonByUserId` | SELECT COUNT(DISTINCT lesson_id) — 사용자 전체 스캔 | 1 |
| 13 | `LessonRepository.count` | SELECT COUNT(*) lesson (전체 행) | 1 |
| 14 | (dirty checking) | flush 시 UPDATE users, UPDATE learning | 2 |

메인 트랜잭션 소계: **11 + 2N' + 2W** (N'는 INSERT N건, 상수 11 + UPDATE 2건)
→ 정리하면 **13 + N + 2W**

`saveAll`은 세 엔티티(`LessonSubmission`, `ProblemSubmission`, `WrongAnsweredNote`) 모두
`@GeneratedValue(IDENTITY)`이고 `hibernate.jdbc.batch_size` 설정이 리소스에 없어 JDBC 배치가 적용되지 않는다.
문제 N개 = INSERT N번.

**AFTER_COMMIT 리스너 — F(첫 풀이)일 때만 실행. 각 서비스가 `REQUIRES_NEW`로 별도 트랜잭션을 연다**

| 리스너 | 쿼리 | 횟수 |
|---|---|---|
| `UserLeagueEventListener` → `UserLeaguePointService.addLeaguePoints` | SELECT user_league (`findByUserId`) | 1 |
| | SELECT league — `userLeague.getLeague()` **LAZY 초기화** | 1 |
| | SELECT league WHERE lp BETWEEN (`findByLpBetween`) | 1 |
| | UPDATE user_league (lp 변경, dirty checking) | 1 |
| `MissionEventListener` → `MissionService.handleLessonMission` | SELECT user_mission ⋈ mission (`findAssignedMission`) | 1 |
| | SELECT COUNT lesson_submission (`getLessonSubmissionTryCount`) — 미완료 미션일 때만 | 0~1 |
| | UPDATE user_mission (진행도, dirty checking) | 0~1 |
| | 목표 달성 시: UPDATE user_mission (`completeIfNotCompleted`) + SELECT users + UPDATE users | 0~3 |
| `DailyLearningRecordListener` → `DailyLearningRecordService` | SELECT daily_learning_record WHERE user_id, solved_date | 1 |
| | INSERT 또는 UPDATE daily_learning_record | 1 |
| `SocialFeedEventListener` | DB 쿼리 없음 (마일스톤일 때 Redis 큐 적재) | 0 |

리스너 소계: **8 ~ 13** (F=true일 때)

**요청 1회 총계**

| 조건 | 쿼리 수 |
|---|---|
| F=false (재풀이) | 13 + N + 2W |
| F=true (첫 풀이) | 21 + N + 2W ~ 26 + N + 2W |

### 지연 로딩 참조 지점

- `UserLeague.league` — `@ManyToOne(FetchType.LAZY)`. `UserLeaguePointService:33`의 `userLeague.getLeague()`에서 추가 SELECT 1건.
  같은 지점을 `UserLeagueService.getUserLeagueDetail:40`이 주석으로 이미 지적하고 있다.
- `User.level` — `@Embedded`이므로 추가 쿼리 없음.

### 범위 밖 표기

리스너 4개는 담당 범위 밖이다. AFTER_COMMIT 동기 실행이라 요청 지연시간과 `pg_stat_statements`에는 잡히므로
관측 대상에는 포함하되, 결함이 발견되면 수정 제안이 아니라 인계 사항으로 분류한다.

### 인증 경로

`JwtAuthFilter:66`은 JWT 파싱만 수행하고 DB를 조회하지 않는다. 요청당 추가 쿼리 없음.

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application="gravit-perf"` 확인) |
| 커넥션 풀 크기 | 10 → **60** (2026-07-29 변경. 아래 *기준선 1차 시도 실패* 참조). 1차 시도의 10은 `application-perf.yml` 값이 아니라 HikariCP 기본값이었다 — 아래 *설정 미적용* 참조 |
| 데이터 규모 | `users` 1,000 / `lesson_submission` 300,000 / `problem_submission` 2,000,000 / `daily_learning_record` 182,000 / `learning` 1,001 / `user_league` 1,000 / `user_mission` 3,000 / `league` 5 / `season` 4 / `chapter` 5 / `unit` 66 / `lesson` 160 / `problem` 4,800 / `wrong_answered_note` 0 |
| 카디널리티 | `lesson_submission.user_id` 1,000, `.lesson_id` 130 (유저당 서로 다른 레슨 100) / `problem_submission.user_id` 1,000, `.problem_id` 3,900 / `learning.user_id` 1,001 (unique) / `user_league.user_id` 1,000, `.league_id` 5 / `user_mission.user_id` 1,000 × 3일 / `season.status` 2 (ACTIVE 1 + CLOSED 3) |
| 부하 조건 | VU 50, 유지 1m (ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m). 요청당 문제 30건 / 오답 9건(30%) / accuracy 70 / learningTime 300 |

### 요청당 문제 수(N=30)와 실제의 차이 — 사이클 3 진입 시 확인 (2026-07-29)

앱 시드(`src/main/resources/sql/problem/`)를 확인한 결과 **실제 서비스는 레슨당 6~8문제**다.
예: `lesson 122`는 문제 7개(`problem` 845~851).

측정 조건 N=30은 이슈 472의 시드 값 `problems_per_lesson 30`을 물려받은 것이며 실제의 약 4배다.
Phase 3-B에서 "레슨의 전체 문제를 한 번에 제출하는 실제 사용 패턴"이라고 적은 근거는 틀렸다.

| 항목 | 측정 조건 (N=30, W=9) | 실제 추정 (N=7, W=2) |
|---|---|---|
| `problem_submission` INSERT | 30/req | 7/req |
| 오답노트 구간 (사이클 1·2 대상) | 18 → 1 쿼리 | 4 → 1 쿼리 |
| 메인 트랜잭션 쿼리 (`13 + N + 2W`) | 61 | 24 |

**결정: N=30을 유지한다.** 문제 수는 서비스 성장에 따라 늘릴 예정이므로 N=30은 미래 규모에 대한 조건으로 유효하다.
대신 결과를 절대값이 아니라 **N의 함수로 기술한다.**

문장 하나의 비용을 고정비 `F`(파싱·계획·실행 준비, 왕복, 드라이버·프록시 오버헤드)와
행당 작업 `R`(힙 쓰기, 인덱스 갱신, FSM 조회)로 나누면:

```
개별 실행 N회 :  N × (F + R)
다중행  1회   :  F + (N × R)
절감          :  (N − 1) × F
```

- **쿼리 수 절감은 완전히 선형**이다: `N − 1`. 계수 기반이라 캐비엇이 없다.
- **시간 절감도 N에 선형이지만 기울기는 `F`**다. `R`은 한 문장으로 합쳐도 사라지지 않는다.
  N=30에서 이 쿼리가 13.04 ms/req를 쓴다고 해서 30 → 1이 13 ms를 모두 없애는 것이 아니다.

사이클 3이 두 점(상태 2의 개별 30회, 상태 3의 다중행 1회)을 주므로 `F`와 `R`을 실측으로 분리할 수 있다.

**한계 두 가지를 보고에 명시한다.**
1. `R`은 완전한 상수가 아니다. 테이블이 커지면 인덱스 깊이가 늘어 오르고, 한 문장 처리의 페이지 지역성 개선으로 내려갈 수도 있다.
2. `F`는 실제보다 작게 나온다. `pg_stat_statements`는 서버측 실행 시간만 재므로 네트워크 왕복과 드라이버·프록시 오버헤드가 빠져 있다.
| Redis 캐시 상태 | cold (measure 직전 FLUSHDB) |
| DB 캐시 상태 | 제어하지 않음. Redis FLUSHDB는 PostgreSQL의 `shared_buffers`와 OS page cache를 비우지 않는다. 둘을 묶어 cold라고 적지 않는다 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` (PONG 확인) |
| 시드 SQL | `../seeds.sql` (이슈 공용) |
| 시드 모듈과 변수 | `content.sql` / `user.sql` / `learning.sql` / `league.sql` + 커스텀 블록 3개(`learning`, `user_mission`, 첫 풀이 전용 콘텐츠). `user_start 1001` / `user_count 1000` / `content_id_base 900000` / `chapter_count 5` / `units_per_chapter 13` / `lessons_per_unit 2` / `problems_per_lesson 30` / `lesson_sub_per_user 300` / `distinct_lessons 100` / `problem_sub_per_user 2000` / `distinct_problems 700` / `wrong_pct 30` / `daily_record_days 180` / `league_tier_count 5` / `past_season_count 3` / `first_try_id_base 910000` / `first_try_lesson_count 100` / `first_try_problems_per_lesson 30` |

### 첫 풀이 측정 설계 (Phase 3-B 확정)

`isFirstTry = true` 경로만 측정한다. 최악 경로이기 때문이다(재풀이 대비 리스너 쿼리 8~13건이 더 붙는다).
단, 두 경로의 차이분은 전부 리스너 안이라 담당 범위 밖이다. 메인 트랜잭션은 두 경로가 동일하다.

| 항목 | 값 |
|---|---|
| 첫 풀이 전용 대역 | `unit` 910001 / `lesson` 910001~910100 / `problem` 910001~913000 |
| 조합 상한 | 1,000 유저 × 100 레슨 = **100,000 요청** |
| 조합 배정 | `userIdx = iterationInTest % 1000`, `lessonOffset = floor(iterationInTest / 1000) % 100` |
| 소진 감지 | k6 check `첫 풀이 조합이 남아 있다` (실패하면 재풀이가 섞인 것) |
| 측정 간 되돌리기 | `seeds.sql` 최상단 되돌리기 블록 또는 Phase 4의 인라인 DELETE. **warmup이 조합을 소모하므로 measure 직전 필수** |

### Phase 2 점검 결과

| 점검 | 결과 |
|---|---|
| perf 프로파일 기동 | `application="gravit-perf"` |
| 히스토그램 노출 | `http_server_requests_seconds_bucket` 146행 (SLO `100ms,200ms,500ms,1s`) |
| `pg_stat_statements` | 조회 성공 (`count = 34`). `docker-compose-local.yml:16`에 `shared_preload_libraries` + `track=all` 설정됨 |
| Redis 캐시 제어 | `redis-cli -h localhost -p 6379 ping` → PONG |
| SQL 로깅 | `show_sql: false`, `org.hibernate.SQL: OFF` (`application-perf.yml:9-22`) |

psql은 비밀번호 프롬프트가 뜬다. 이후 Phase에서는 `PGPASSWORD=postgres`를 앞에 붙여 실행한다.

## 기준선 1차 시도 실패 — 커넥션 고갈 (2026-07-29)

풀 10 / VU 50으로 측정했으나 요청 251건 중 123건이 실패해 기준선으로 쓸 수 없었다.
원인은 쿼리 비용이 아니라 커넥션 대기였고, 재측정을 위해 `maximum-pool-size`를 10 → 60으로 올렸다.

### 관측

| 지표 | 값 |
|---|---|
| 요청 수 | 251 |
| RPS | 1.6868004217861257 |
| 실패율 | 0.4900398406374502 |
| duration med / p95 / p99 | 30004.48 / 60000.266 / 60001.219 ms |
| 전체 쿼리 실행 시간 합계 | 약 935.6 ms (2분 측정 구간 전체) |
| 메인 트랜잭션 완주 요청 | 151 (`learning` UPDATE 호출 수) |
| 요청당 DB 실행 시간 | 935.6 / 151 = 6.2 ms |
| 커넥션 10개 기준 이론 처리량 | 10 / 0.0062 = 약 1,600 RPS |

실측이 이론값의 약 1/950이다. 커넥션을 쥔 스레드가 DB 작업을 하고 있지 않았다는 뜻이다.
`http_req_failed` 123건의 내역은 서버 에러 6건, 나머지 117건은 k6의 60초 타임아웃(무응답)이었다.

### 원인

요청 하나가 리스너 구간에서 **커넥션 2개를 동시에 점유한다.**

스택 트레이스의 두 프레임이 근거다.

- `AbstractPlatformTransactionManager.processCommit(...:839)` → `triggerAfterCompletion` → 리스너
  리스너가 `processCommit` 안에서 실행된다. `cleanupAfterCompletion`이 아직 호출되지 않아 바깥 트랜잭션 자원이 살아 있다.
- `AbstractPlatformTransactionManager.handleExistingTransaction(...:452)`
  AFTER_COMMIT 시점에도 Spring이 "기존 트랜잭션 있음"으로 판단했다. 바깥 트랜잭션이 스레드에 여전히 묶여 있다.

REQUIRES_NEW는 기존 트랜잭션을 **보류(suspend)**하고 새 커넥션을 요청한다.
보류는 자원 홀더를 스레드에서 떼어내 보관하는 것일 뿐, 물리 커넥션은 계속 체크아웃 상태다.

Hikari 로그가 결과를 보여준다.

```
HikariPool-1 - Connection is not available, request timed out after 30001ms
              (total=10, active=10, idle=0, waiting=3)
```

`active` 전부 / `idle` 0인데 실제 쿼리 실행 시간 합계는 935ms다.

### 실패 연쇄

| 단계 | 근거 |
|---|---|
| 1. 리스너 REQUIRES_NEW가 2번째 커넥션 요청 | `handleExistingTransaction` → `JpaTransactionManager.doBegin` |
| 2. 풀이 비어 `connection-timeout`(미설정, 기본 30초) 만료 | `request timed out after 30001ms` |
| 3. 리스너의 try/catch가 예외를 삼키고 재시도 큐 적재 | `MissionEventListener: 레슨 완료 미션 처리 실패, 재시도 큐 적재` |
| 4. 리스너 4개가 순차로 각각 30초 대기 → 응답 60~90초 | `API_PERF ... response_time=60236 status=200`, `response_time=90639 status=200` |
| 5. k6가 60초에 포기, 서버는 이후에 응답 → broken pipe | `AsyncRequestNotUsableException: ServletOutputStream failed to flush: Broken pipe` |

요청은 200으로 끝난다. 리스너 예외를 전부 삼키므로 비즈니스적으로는 성공이고, 시간만 30초 단위로 쌓인다.

### 설정 미적용 — `application-perf.yml`의 hikari 설정이 무시되고 있었다

풀을 60으로 올린 뒤에도 `hikaricp_connections_max{pool="HikariPool-1"}`가 `10.0`으로 나왔다.
풀 이름도 `application-perf.yml`에 적은 `gravit-perf-pool`이 아니라 `HikariPool-1`이었다.

원인은 `global/config/DatasourceConfig.java`의 `@Primary` DataSource 빈이다.

```java
DataSource dataSource = props.initializeDataSourceBuilder().build();
```

`DataSourceProperties`는 `spring.datasource.url` / `username` / `password` / `driver-class-name`만 담는다.
`spring.datasource.hikari.*`는 Spring Boot의 `DataSourceConfiguration.Hikari` 자동설정이 바인딩하는데,
`@Primary` DataSource 빈을 직접 정의하면 그 자동설정이 물러난다.

따라서 1차 시도에서 관측된 값은 전부 HikariCP 기본값이었다.

| 항목 | perf yml 값 | 실제 적용값 | 출처 |
|---|---|---|---|
| `maximum-pool-size` | 10 | 10 | HikariCP 기본값 (우연히 일치) |
| `pool-name` | `gravit-perf-pool` | `HikariPool-1` | HikariCP 기본값 |
| `connection-timeout` | 미지정 | 30,000 ms | HikariCP 기본값 |

조치: Hikari 빈을 분리해 `@ConfigurationProperties("spring.datasource.hikari")`로 바인딩하고,
프록시가 그 빈을 감싸도록 했다. `DatasourceConfig`는 `@Profile("!test & !prod")`이라 로컬과 dev에 걸리지만,
두 프로파일의 yml에 hikari 설정이 없어 기존 동작은 바뀌지 않는다.

### 인계 사항 (담당 범위 밖)

풀 크기를 키우는 것은 측정을 진행하기 위한 조치이지 해결이 아니다.
`풀 크기 ≥ 동시 요청 수 + 1`을 만족하지 못하는 순간 같은 현상이 재현된다.
근본 해결은 리스너를 `@Async`로 요청 스레드에서 분리하거나 REQUIRES_NEW를 걷어내는 쪽이며,
리스너는 담당 범위 밖이므로 수정하지 않고 인계한다.

관련 파일: `userLeague/listener/UserLeagueEventListener.java:27`, `mission/listener/MissionEventListener.java:26`,
`dailyLearningRecord/listener/DailyLearningRecordListener.java:23`, `social/listener/SocialFeedEventListener.java:25`

---

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| p95 | 3204.7293999999993 ms |
| p99 | 3644.5262999999995 ms |
| med | 1005.8735 ms |
| RPS | 30.05442998801386 |
| 에러율 | 0 |
| check 통과율 | 1 (4개 항목 전부 3610/3610) |
| 요청 수 | 3610 |
| 요청당 쿼리 수 | 약 60건 (상위 20건이 57.4건, 나머지가 전체 시간의 1.3%) |
| 요청당 DB 실행 시간 | 288,660 / 3,610 = 79.96 ms |

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.txt` / k6 요약: `k6-test-summary-0.json`

| 요청당 | mean_ms | total_ms | 비중 | 행/호출 | 출처 |
|---|---|---|---|---|---|
| 9.00 | 4.7988053265312525 | 155913.18505900068 | 54.01% | 0.000 | `WrongAnsweredNoteRepository.findByProblemIdAndUserId` |
| 30.00 | 0.736195981643578 | 79730.02481200015 | 27.62% | 1.0 | `ProblemSubmissionRepository.saveAll` |
| 9.00 | 0.39034234493690123 | 12682.22278699999 | 4.39% | 1.0 | `WrongAnsweredNoteRepository.save` |
| 1.00 | 2.387485414681436 | 8618.822346999985 | 2.99% | 0.000 | `LessonSubmissionRepository.existsByLessonIdAndUserId` |
| 0.703 | 2.251290341213554 | 5713.77488600001 | 1.98% | 1.0 | `LessonSubmissionRepository.countLessonSubmissionByLessonIdAndUserId` (리스너) |

상위 3건 합계 86.02%.

### 진단

- **병목 성격: 상위 3건에 DB 시간의 86.02%가 몰려 있고, 1위와 2·3위는 비용의 형태가 다르다.**

  | 쿼리 | 요청당 호출 | mean_ms | 요청당 시간 | 비용의 출처 |
  |---|---|---|---|---|
  | `wrong_answered_note` SELECT | 9 | 4.799 | 43.19 ms | 호출당 단가 |
  | `problem_submission` INSERT | 30 | 0.736 | 22.09 ms | 호출 횟수 |
  | `wrong_answered_note` INSERT | 9 | 0.390 | 3.51 ms | 호출 횟수 |

  2·3위의 mean은 INSERT로서 평범하다(전체에서 mean 1ms를 넘는 쿼리는 4건뿐).
  1위만 단가가 2위 mean의 6.5배다.

- 근거:
  - 1위 `wrong_answered_note` SELECT — 32,490회 호출, 행/호출 `0.000000000000000000000000`.
    결과가 없는 조회가 호출당 4.799 ms. 측정 중 같은 테이블이 0 → 32,490행으로 증가한 구간의 평균이다.
  - 2위 `problem_submission` INSERT — 108,300회 = 3,610 × 30. IDENTITY 채번이라 JDBC 배치가 적용되지 않는다.
  - 요청당 DB 실행 시간 79.96 ms 대 duration med 1005.87 ms.
    DB 실행이 응답 시간의 8%다. 쿼리 약 60건의 왕복 오버헤드와,
    풀 60 / VU 50 (요청당 최대 2개 요구 → 최대 100 요구) 상황의 커넥션 획득 대기가 나머지에 포함된다.

- 예상 쿼리 목록과 어긋난 지점:

  | 항목 | 예상 | 실측 |
  |---|---|---|
  | `JwtAuthFilter` | DB 조회 없음 | **요청당 `users` SELECT 2회.** `AuthTokenProvider.parseUser:71`이 `findById`를 호출하고, 필터가 `:78`(`getAuthUser` 내부)과 `:81`에서 두 번 부른다 |
  | `LastAccessInterceptor` | 목록에 없었음 | 요청당 `users` 조건부 UPDATE 1회. 행/호출 0.1058 (하루 1회 조건이라 10.6%만 실제 갱신) |
  | `RetryQueueSweeper` | 목록에 없었음 | `social_feed` INSERT 0.162/req. `@Scheduled(fixedDelay=30000)` 스케줄러 스레드이므로 요청 지연시간 밖 |
  | `UserLeague.league` LAZY 로딩 | 추가 SELECT 1회 예상 | 상위 20건에 없음 (전체 시간의 0.27% 미만) |

---

## 사이클 1: `wrong_answered_note (user_id, problem_id)` 유니크 인덱스 추가

### 설계 결정

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 대상 테이블·컬럼 | `wrong_answered_note (user_id, problem_id)` | 인덱스가 PK뿐이라 `WHERE problem_id=? AND user_id=?`를 받아줄 인덱스가 없다. 요청당 9회, mean 4.799 ms, 전체의 54.01% |
| 컬럼 순서 | `user_id` 선두 | 대상 쿼리는 두 컬럼 모두 등치라 순서 무관. `user_id`가 선두여야 `findWrongAnsweredProblemDetailByUnitIdAndUserId`, `countByUnitIdAndUserId`(둘 다 `user_id` 단독 필터)가 같은 인덱스를 재사용한다 |
| 유니크 여부 | **UNIQUE** | 운영 DB `duplicate_pairs = 0`. `WrongAnsweredNoteRepository:14`가 `Optional`을 반환해 코드가 이미 유일성을 전제한다. 사이클 2의 `ON CONFLICT (user_id, problem_id)`가 유니크 제약을 요구한다 |
| 커버링 | **없음 (키 2개만)** | 대상 쿼리가 엔티티 7컬럼 전부를 가져가므로 커버링하려면 인덱스가 테이블 복제본이 된다. 조회 결과를 `markWrong()`으로 변경하므로 projection으로 대체 불가. 운영 DB는 V30 미적용이라 `wrong_count`/`resolved_at`이 아예 없다 |
| 부분 인덱스 | **없음 (전체)** | 대상 쿼리에 `resolved_at` 술어가 없어 플래너가 부분 인덱스를 쓸 수 없다. 부분 유니크는 조건 밖 행의 유일성을 강제하지 못해 `Optional` 전제와 `ON CONFLICT`가 깨진다 |
| 감수할 쓰기 비용 | 감수 | INSERT 9/req(4.39%)에 인덱스 유지 비용이 붙고, SELECT 54.01%의 단가가 내려간다. 키 컬럼은 생성 후 변경되지 않아 UPDATE 비용은 없다 |
| 마이그레이션 방식 | 일반 `CREATE UNIQUE INDEX` | 운영 907행이라 즉시 완료. `CONCURRENTLY`는 트랜잭션 안에서 실행할 수 없어 Flyway 기본 동작과 충돌하며, 이 규모에서 실익이 없다 |
| 파일 | `V34__add_wrong_answered_note_user_problem_unique_index.sql` | 최신이 V33. 인덱스명 `ix_wrong_answered_note_user_problem` (V32·V33과 같은 형식) |

- 검토했지만 택하지 않은 안:
  - `(problem_id, user_id)` 순서 — 나머지 두 쿼리가 선두 컬럼 불일치로 인덱스를 못 쓴다
  - `INCLUDE (id, created_at, updated_at, wrong_count, resolved_at)` — 인덱스가 테이블 복제본이 되고, 운영 DB에 컬럼이 없다
  - `WHERE resolved_at IS NULL` 부분 인덱스 — 대상 쿼리가 이 술어를 갖지 않아 사용되지 않는다
  - 사이클 2 후보(UPSERT 전환), 사이클 3 후보(`problem_submission` 다중행 INSERT)는 이번 사이클에서 다루지 않는다

- 호출자가 예상한 효과: Seq Scan → Index Scan, 대상 쿼리 단가 하락

- 유의: 이 인덱스만 적용된 상태에서는 `WrongAnsweredNoteService:23-25`의 check-then-act 경쟁이
  중복 행 생성 대신 `DataIntegrityViolationException`으로 드러난다. 사이클 2의 UPSERT가 이를 흡수한다.

- 유의: 운영 테이블은 907행이라 현재 규모에서 인덱스의 이득은 크지 않다.
  측정된 4.799 ms는 32,490행 기준이며, 이 인덱스의 값은 테이블 증가에 대비하는 성격이다.

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 3204.7293999999993 / 3644.5262999999995 ms |
| med | 1005.8735 ms |
| RPS | 30.05442998801386 |
| 에러율 / check | 0 / 1 |
| 요청당 쿼리 수 | 약 60건 |
| 대상 쿼리 calls / mean_ms / total_ms | 32490 / 4.7988053265312525 / 155913.18505900068 (전체의 54.01255759387924%) |

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`)

- EXPLAIN 파라미터: `$1` (problem_id) = **910035**, `$2` (user_id) = **1501** (이후 모든 사이클에서 동일하게 사용)
  - 910035: 부하가 소비한 레슨 4개(`lessonOffset` 0~3) 중 두 번째 레슨의 오답 9개(910031~910039)의 중간값
  - 1501: `USER_ID_START` 1001 ~ 2000의 중간값
  - 캡처 시점 테이블 상태: 32,490행 (기준선 측정이 남긴 상태. 되돌리기 전에 캡처)
- 스캔 방식: **Seq Scan**, 사용 인덱스: **없음** (PK만 존재)
- actual rows 대 반환 행 수: 1 / 1 (검사한 행은 32,490)
- Rows Removed by Filter: **32,489**
- shared hit / read: **310 / 0** (310 × 8KB = 2,480 KB ≈ 2.42 MB를 훑어 52 bytes 1행 반환. `read=0`이라 디스크 I/O 없음, 5.3 ms는 전부 CPU 스캔)
- 플래너 추정 대 실측: rows=1 / actual rows=1
- Planning Time 1.787 ms / Execution Time 5.475 ms

**해석**

플래너 추정과 실측이 1:1로 정확히 일치한다. 통계가 낡아 잘못된 계획을 고른 것이 아니라,
`(problem_id, user_id)` 조건을 받아줄 접근 경로가 아예 없어 **선택지가 Seq Scan 하나뿐**이었다.
따라서 `ANALYZE`나 통계 타깃 조정이 아니라 인덱스 추가가 유일한 처방이다.

**위험 신호 대조**

| 지표 | 기준 | 실측 | 판정 |
|---|---|---|---|
| 검사 행 수 / 반환 행 수 | 100:1 초과 | 32,490 : 1 | 초과 |
| 플래너 추정 대 실측 행 수 | 10배 이상 괴리 | 1 : 1 | 해당 없음 |
| 단일 쿼리의 total_exec_time 점유율 | 30% 이상 | 54.01% | 초과 |
| OLTP 경로의 Seq Scan | 1만 행 이상 테이블 | 32,490행 Seq Scan | 해당 |
| 동일 쿼리의 요청당 호출 횟수 | 1회 초과 | 9회 | 해당 |

### 적용 내용

- `src/main/resources/db/migration/V34__add_wrong_answered_note_user_problem_unique_index.sql` 신규
  ```sql
  CREATE UNIQUE INDEX IF NOT EXISTS ix_wrong_answered_note_user_problem
      ON wrong_answered_note (user_id, problem_id);
  ```
- 자바 코드 변경 없음. 이번 사이클은 인덱스 하나만 적용한다.
- 적용 절차: 첫 풀이 대역 되돌리기 → 앱 재기동(Flyway가 V34 적용) → `ANALYZE wrong_answered_note`
- 테스트: `./gradlew test` 통과

### 개선 후 지표

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 3204.7293999999993 ms | 1612.9363499999997 ms | −49.7% |
| | p99 | 3644.5262999999995 ms | 2564.2289099999994 ms | −29.6% |
| | med | 1005.8735 ms | 579.0505 ms | −42.4% |
| | RPS | 30.05442998801386 | 52.25093746890309 | +73.9% |
| | 요청 수 | 3610 | 6270 | +73.7% |
| 하드웨어 독립 | 대상 쿼리 요청당 호출 수 | 9.00 | 9.00 | 변화 없음 |
| | 대상 쿼리 mean_ms | 4.7988053265312525 | 0.16060131036682634 | −96.65% |
| | 대상 쿼리 total_ms | 155913.18505900068 | 9062.731943999976 | 비중 54.01% → 5.86% |
| | 검사 행 / 반환 행 | 32,490 : 1 | 1 : 1 | 해소 |
| | 스캔 방식 | Seq Scan | Index Scan (`ix_wrong_answered_note_user_problem`) | 변경 |
| | shared hit | 310 (2,480 KB) | 6 (48 KB) | −98.1% |
| | 요청당 DB 실행 시간 | 79.96 ms | 24.67 ms | −69.1% |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클이 아님 |

**개선 후 실행계획** (`query-plan-1.txt`)

```
Index Scan using ix_wrong_answered_note_user_problem  (cost=0.29..8.31 rows=1 width=52)
                                                      (actual time=0.222..0.226 rows=1 loops=1)
  Index Cond: ((wan1_0.user_id = 1501) AND (wan1_0.problem_id = 910035))
  Buffers: shared hit=6
Planning Time: 3.188 ms
Execution Time: 0.383 ms
```

`Filter` + `Rows Removed by Filter: 32,489`가 `Index Cond`로 바뀌어 버릴 행을 애초에 읽지 않는다.
Planning Time은 1.787 → 3.188 ms로 증가했다(플래너가 고려할 인덱스가 늘었다). 실행에서 5.09 ms를 벌고 계획에서 1.40 ms를 잃었다.

### 판정

- **개선 여부 (하드웨어 독립 증거 기준): 있음.**
  스캔 방식 Seq Scan → Index Scan, `Rows Removed by Filter` 32,489 → 0, `shared hit` 310 → 6.
  측정 편차로는 이 세 값이 움직이지 않는다.
- 예상 효과와의 대조: Phase 5의 예상("Seq Scan → Index Scan, 단가 하락")이 실측과 일치했다.
  근거로 삼은 "추정과 실측이 1:1이므로 통계 문제가 아니라 접근 경로 부재"라는 판단이 맞았고,
  인덱스 생성 즉시 플래너가 그것을 선택했다.
- 감수하기로 한 쓰기 비용: **실현되지 않았다.** `wrong_answered_note` INSERT mean이 0.390 → 0.330 ms로 오히려 감소했다.
  전체 DB 부하 감소로 경합이 완화된 효과가 인덱스 유지 비용보다 컸던 것으로 보인다.
  다만 이는 이번 측정 조건의 관찰이며 유지 비용 자체가 사라진 것은 아니다.
- 유니크 제약으로 인한 `DataIntegrityViolationException`: 발생하지 않음 (`failed_rate` 0, `checks_rate` 1로 0차와 동일).

- 남은 위험 신호: **요청당 호출 횟수 9회 (미해소).** 인덱스는 단가를 낮췄을 뿐 호출 수를 줄이지 않는다.

- 순위 변동

  | 순위 | 개선 전 | 개선 후 |
  |---|---|---|
  | 1위 | `wrong_answered_note` SELECT 54.01% | `problem_submission` INSERT **62.11%** |
  | 2위 | `problem_submission` INSERT 27.62% | `wrong_answered_note` INSERT 12.05% |
  | 3위 | `wrong_answered_note` INSERT 4.39% | `wrong_answered_note` SELECT 5.86% |

- 다음 사이클 진행 여부: **계속** (사이클 2 = 오답노트 저장 UPSERT 전환)

---

## 사이클 2: 오답노트 저장 UPSERT 전환

### 설계 결정

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 대상 | `WrongAnsweredNoteService.saveWrongAnsweredNote`의 SELECT → INSERT 를 다중행 UPSERT 1회로 | 사이클 1 이후에도 요청당 SELECT 9회(5.86%) + INSERT 9회(12.05%) = 18쿼리가 남아 있다. 인덱스는 단가만 낮췄고 호출 수는 그대로다 |
| UPSERT 단위 | **다중행 1회** | 요청당 18 → 1. 응답 시간의 대부분이 DB 실행이 아니라 왕복·대기이므로(요청당 DB 24.67 ms 대 med 579 ms) 왕복 횟수 감소가 핵심이다 |
| 쿼리 형태 | **`unnest` 배열** | 리스트 길이와 무관하게 파라미터가 3개(`userId`, `problemIds`, `now`)로 고정된다. VALUES 동적 조립은 오답 수마다 쿼리 원문이 달라져 `pg_stat_statements` 항목이 쪼개지고, `JdbcTemplate.batchUpdate`는 왕복만 줄고 `calls`는 9로 남는다 |
| 구현 위치 | `WrongAnsweredNoteRepository`의 `@Modifying @Query(nativeQuery = true)` | 처음에는 `repository/custom/` + `repository/sql/`(`NamedParameterJdbcTemplate`)로 만들었으나 `@Query`로 되돌렸다. 파일 3개가 늘고 오답노트 저장 진입점이 둘로 갈리는 비용이, 아래 두 이점보다 크다고 판단했다 |
| 시그니처 | 리스트 메서드 **추가**, 단건 메서드 **유지** | `ProblemFacade:58`(단건 제출 경로, 오답 최대 1건)을 건드리지 않는다 |
| 중복 제거 | `distinct()`, Service 내부 | 같은 명령 내 중복 쌍은 `ON CONFLICT DO UPDATE command cannot affect row a second time`로 실패한다(로컬에서 재현 확인). 현재 `forEach`는 중복을 정상 처리하므로, 넣지 않으면 기존에 동작하던 케이스가 500이 된다 |
| 타임스탬프 | `Clock` 빈 주입 → `LocalDateTime.now(clock)` | 네이티브 쿼리는 `BaseEntity`의 `@PrePersist`/`@PreUpdate`를 타지 않는다. Postgres `now()`는 서버 TZ(UTC)라 KST와 9시간 어긋난다. `MissionService`·`DailyLearningRecordService`가 이미 쓰는 `TimeConfig:14`의 `Clock.system(KST)` 빈에 맞춘다 |
| 영속성 컨텍스트 | **명시적 flush/clear 없음** | UPSERT 시점(`LessonFacade:96`)에 `wrong_answered_note`에 대기 중인 JPA 변경이 없다. `lesson_submission`·`problem_submission`은 IDENTITY라 이미 즉시 실행됐고, `users`·`learning`의 dirty checking은 UPSERT 이후에 발생한다. 이 테이블들에는 FK 제약도 없어 간접 간섭도 없다 |

**정정 (구현 중 확인)**: 네이티브 `@Query`는 Hibernate가 실행 전 세션을 **자동 flush**한다
(query space를 특정하지 못하면 보수적으로 전체를 flush한다). 따라서 "flush 없음"은 실제로는
"명시적 flush를 넣지 않음"이고, 자동 flush는 발생한다.
`JdbcTemplate` 방식에는 없던 동작이며, 위 근거대로 대기 중인 변경이 없어 무해하다.

`@Query` 선택 시 포기한 두 이점:
1. 시그니처가 배열 리터럴 문자열(`String problemIds`)을 노출한다. 커스텀 구현이었다면 `List<Long>`을 받고 변환을 감출 수 있었다.
2. 위의 자동 flush.

**적용할 SQL**

```sql
INSERT INTO wrong_answered_note (user_id, problem_id, wrong_count, created_at, updated_at)
SELECT :userId, p, 1, :now, :now
FROM unnest(cast(:problemIds AS bigint[])) AS p
ON CONFLICT (user_id, problem_id)
DO UPDATE SET wrong_count = wrong_answered_note.wrong_count + 1,
              resolved_at = NULL,
              updated_at  = EXCLUDED.updated_at
```

사이클 1의 `ix_wrong_answered_note_user_problem`(UNIQUE)이 `ON CONFLICT`의 대상이다. 사이클 1이 사이클 2의 전제였다.

**사전 검증** (로컬에서 실행 확인)

| 확인 | 결과 |
|---|---|
| IDENTITY + 다중행 + `ON CONFLICT` 동작 여부 | 동작. 3행이 id를 달고 반환되고 `wrong_count`가 증가했다. IDENTITY가 막는 것은 Hibernate의 JDBC 배치이지 네이티브 다중행 INSERT가 아니다 |
| 같은 명령 내 중복 쌍 | `ERROR: ON CONFLICT DO UPDATE command cannot affect row a second time` |

- 검토했지만 택하지 않은 안:
  - 건별 UPSERT 9회 — 요청당 18 → 9에 그친다
  - VALUES 절 동적 조립 — 쿼리 원문이 오답 수마다 달라져 통계가 쪼개진다
  - `JdbcTemplate.batchUpdate` — 왕복은 1회지만 `pg_stat_statements`의 `calls`가 9로 남아 하드웨어 독립 지표가 개선되지 않는다
  - 단건 메서드 교체(B안) — `ProblemFacade` 경로까지 함께 바뀐다
  - `clear()` — 1차 캐시를 비우면 이미 로드된 엔티티가 detach되어 dirty checking이 유실될 수 있고, 얻는 것이 없다
  - SQL의 `now()` — Postgres 서버 TZ(UTC) 기준이라 KST와 9시간 어긋난다

- 호출자가 예상한 효과: 요청당 쿼리 18 → 1, check-then-act 경쟁 해소

- **닫히지 않은 항목**: 단건 메서드를 유지하므로 `ProblemFacade:58` 경로의 check-then-act 경쟁은 남는다.
  사이클 1의 유니크 인덱스 때문에 그 경로는 동시 요청 시 `DataIntegrityViolationException`이 날 수 있다.
  오답 최대 1건짜리 단건 제출 경로라 발생 확률은 낮다.

- **유지해야 할 불변식**: flush를 넣지 않은 근거는 "UPSERT 시점에 `wrong_answered_note`에 대기 중인 JPA 변경이 없다"이다.
  `LessonFacade.saveLessonSubmission`의 호출 순서가 바뀌어 이 전제가 깨지면 flush가 필요해진다.

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 1612.9363499999997 / 2564.2289099999994 ms |
| med | 579.0505 ms |
| RPS | 52.25093746890309 |
| 요청당 쿼리 수 | 약 60건 |
| **대상 구간 요청당 쿼리** | **18건** (SELECT 9 + INSERT 9) |
| SELECT calls / mean_ms / total_ms | 56430 / 0.16060131036682634 / 9062.731943999976 (5.859072570518398%) |
| INSERT calls / mean_ms / total_ms | 56430 / 0.33039451765018535 / 18644.16263100004 (12.053484815238043%) |
| 대상 구간 합계 비중 | 17.91% |

**실행계획**

> 원본: `query-plan-1.txt` (SELECT는 사이클 1 검증분, INSERT는 사이클 2 스냅샷으로 덧붙임)

- EXPLAIN 파라미터: SELECT는 사이클 1과 동일(`problem_id` = 910035, `user_id` = 1501).
  INSERT는 `user_id` = 1501, `problem_id` = **919999** (기존에 없는 값이라야 충돌 없는 INSERT 경로를 타고, 되돌리기 DELETE `>= 910000`에도 걸린다)

| 노드 | 스캔 방식 | actual time | 추정 rows | 실측 rows | loops | Rows Removed by Filter | shared hit / read |
|---|---|---|---|---|---|---|---|
| SELECT `Index Scan using ix_wrong_answered_note_user_problem` | Index Scan | 0.222..0.226 | 1 | 1 | 1 | 없음 (`Index Cond`) | 6 / 0 |
| INSERT `Insert on wrong_answered_note` | 쓰기 노드 | 0.758..0.762 | 0 | 0 | 1 | 없음 | **68** / 0 |
| └ `Result` (자식) | 값 생성 | 0.054..0.055 | 1 | 1 | 1 | 없음 | 10 / 0 |

- INSERT 노드의 rows=0은 `RETURNING`이 없어 상위로 내보낼 행이 없다는 뜻이지 쓰지 않았다는 뜻이 아니다.
- INSERT의 `shared hit=68`은 SELECT의 6보다 11배다. 힙 쓰기 + 인덱스 2개(PK, 유니크) 갱신 때문이며,
  B-tree를 루트→중간→리프로 내려가는 **읽기**가 그 대부분을 차지한다.
- `Result`의 `Output`에 `nextval('wrong_answered_note_id_seq')`가 보인다. IDENTITY 시퀀스를 여기서 당겨 쓴다.
- INSERT 출력에 `dirtied`가 표시되지 않았다. 직전 부하 테스트로 해당 페이지들이 이미 dirty였을 가능성이 높으나 확정하지 못했다.

**호출 스택 (로직 개선 사이클의 추가 캡처)**

```
LessonFacade.saveLessonSubmission:96
  └ wrongAnsweredProblemIds.forEach(...)                     ← 오답 9건이면 9회 반복
      └ WrongAnsweredNoteService.saveWrongAnsweredNote:19
          ├ WrongAnsweredNoteRepository.findByProblemIdAndUserId    ← SELECT ×9
          └ WrongAnsweredNoteRepository.save                         ← INSERT ×9
```

**해석**

이 쌍의 비용 중심은 INSERT다. 요청당 시간이 SELECT 5.86% 대 INSERT 12.05%, 버퍼가 6페이지 대 68페이지다.

이 판정은 사이클 2의 기대치를 제한한다. UPSERT는 INSERT의 **행별 작업**(힙 쓰기, 인덱스 2개 하강, 중복 검사)을 없애지 못한다.
사라지는 것은 SELECT 9회(5.86%)와 문장 17개분의 왕복·파싱·계획이다.
즉 DB 실행 시간 자체의 감소폭은 6%p 남짓으로 예상되며, 그보다 왕복 17회 감소가 p95에 미치는 영향이 관건이다
(요청당 DB 실행 24.67 ms 대 duration med 579.05 ms — 응답 시간의 대부분이 DB 실행 밖에 있다).

### 적용 내용

| 파일 | 변경 |
|---|---|
| `wrongAnsweredNote/repository/WrongAnsweredNoteRepository.java` | `@Modifying @Query(nativeQuery = true) void upsertAll(userId, problemIds, now)` 추가 + Javadoc |
| `wrongAnsweredNote/service/WrongAnsweredNoteService.java` | `saveWrongAnsweredNotes(long, List<Long>)` 추가, `Clock` 주입, `toDistinctArrayLiteral` private 메서드. 단건 `saveWrongAnsweredNote`는 유지 |
| `lesson/facade/LessonFacade.java:96` | `wrongAnsweredProblemIds.forEach(...)` → `wrongAnsweredNoteService.saveWrongAnsweredNotes(userId, wrongAnsweredProblemIds)` |
| `test/.../LessonFacadeUnitTest.java` | 검증 2건 수정. "오답이 없으면" 테스트는 Facade가 빈 리스트로 호출하고 Service가 조기 반환하는 구조로 바뀌어, 저장하지 않음의 보장이 Service 테스트로 이동 |
| `test/.../WrongAnsweredNoteServiceUnitTest.java` | 일괄 저장 테스트 3건 추가(배열 리터럴 변환, 중복 제거, 빈 목록 조기 반환), `Clock` 고정 |

- 테스트: `./gradlew test` 통과

**검증되지 않은 구간**: `WrongAnsweredNoteServiceIntegrationTest`는 단건 메서드만 호출하므로
`upsertAll` 쿼리는 실제 Postgres에서 실행된 적이 없다. psql로 확인한 것은 순수 SQL이고,
Hibernate가 `CAST(:problemIds AS BIGINT[])`와 `AS p(problem_id)`를 파싱·바인딩할 수 있는지는 미검증이다.
통합 테스트 추가 대신 **Phase 8의 warmup 실행에서 확인**하기로 했다. warmup에서 실패 없이 통과했다.

### 1차 재측정 폐기 — dead tuple 누적으로 비교 불가 (2026-07-29)

1차 재측정에서 하드웨어 독립 증거는 개선됐으나(요청당 쿼리 18 → 1.00, 오답 9건당 버퍼 666 → 92)
하드웨어 의존 지표가 악화됐다(p95 1612.94 → 2514.98 ms, RPS 52.25 → 37.04).

원인은 이번 변경과 무관한 `problem_submission` INSERT였다. 코드도 스키마도 손대지 않았는데
호출당 mean이 0.5107715335619484 → 1.1151938711510767 ms(+118%)로 올랐고, 이 쿼리가 전체 DB 시간의 78.76%를 차지한다.

`pg_stat_user_tables` 확인 결과:

| 테이블 | dead tuple | last_vacuum | last_autovacuum |
|---|---|---|---|
| `problem_submission` | 385,560 | 없음 | **없음** |
| `lesson_submission` | 7,445 | 없음 | 없음 |
| `wrong_answered_note` | 18 | 없음 | 2026-07-29 14:38:44 |

측정 3회분(0·1·2)의 INSERT와 되돌리기 DELETE가 남긴 dead tuple이 회수되지 않았다.
기본 설정에서 autovacuum 발동 조건은 `50 + 0.2 × reltuples ≈ 420,050`이고 현재 385,560으로 **문턱 바로 아래**여서 한 번도 돌지 않았다.
`wrong_answered_note`는 4만 행 규모라 문턱이 낮아 autovacuum이 돌았고 dead가 18개뿐이다.

dead tuple은 VACUUM 전까지 공간이 회수되지 않아 힙이 커지고 인덱스에도 죽은 항목이 남는다.
새 행을 넣을 때마다 더 커진 B-tree를 내려가고 FSM을 더 뒤져야 하므로 INSERT가 느려진다.
사이클 1 측정 시점보다 사이클 2 측정 시점의 dead가 많았으니 같은 INSERT가 더 비싸진 것이다.

**조치**: 측정 절차의 되돌리기 단계 뒤에 `VACUUM ANALYZE`를 추가하고 재측정한다.
되돌리기 DELETE가 매번 dead tuple을 남기는데 기존 절차에는 회수 단계가 없었다.
`k6-test-summary-2.json`, `query-stats-summary-2.txt`, `query-plan-2.txt`는 재측정 결과로 덮어쓴다
(코드 상태는 동일하게 2이고, 폐기한 측정을 보존할 이유가 없다).

**주의**: `n_live_tup`은 신뢰하지 않는다. `lesson_submission`이 4,445로 나오지만 실제로는 30만 행 이상이다.
ANALYZE가 돈 적 없는 테이블의 `n_live_tup`은 통계 리셋 이후의 증감만 누적한 값이다(Phase 3에서 겪은 것과 같은 문제).

### 개선 후 지표 (VACUUM ANALYZE 후 재측정)

**측정 조건 변경**: 사이클 2 측정 직전에 `VACUUM ANALYZE`를 추가했다. 사이클 1은 dead tuple이 누적된 상태에서
측정되었으므로 **하드웨어 의존 지표의 차이에는 UPSERT 전환 효과와 dead tuple 회수 효과가 함께 섞여 있다.**
근거: 이번 변경과 무관한 `problem_submission` INSERT의 mean이 0.5107715335619484 → 0.4347570695423183 (−14.9%)로 개선됐다.

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 (두 효과 혼합) | p95 | 1612.9363499999997 ms | 820.8402499999999 ms | −49.1% |
| | p99 | 2564.2289099999994 ms | 1148.8985 ms | −55.2% |
| | med | 579.0505 ms | 443.10249999999996 ms | −23.5% |
| | RPS | 52.25093746890309 | 82.2901731818192 | +57.5% |
| | 요청 수 | 6270 | 9876 | +57.5% |
| | 실패율 / check | 0 / 1 | 0 / 1 | 동일 |
| 하드웨어 독립 (UPSERT 효과) | 오답노트 구간 요청당 쿼리 | 18 | **1.00** | **−94.4%** |
| | 오답노트 구간 요청당 시간 | 4.419 ms | 1.634 ms | −63.0% |
| | 오답 9건당 버퍼 접근 | 666 | **154** | **−76.9%** |
| | 오답노트 구간 비중 | 17.91% | 9.17% | −8.74%p |
| | 요청당 DB 실행 시간 | 24.67 ms | 17.83 ms | −27.7% (혼합) |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클이 아님 |

**개선 후 실행계획** (`query-plan-2.txt`)

```
Insert on public.wrong_answered_note  (cost=0.00..0.21 rows=0 width=0) (actual time=1.013..1.019 rows=0 loops=1)
  Conflict Resolution: UPDATE
  Conflict Arbiter Indexes: ix_wrong_answered_note_user_problem
  Tuples Inserted: 4
  Conflicting Tuples: 5
  Buffers: shared hit=154 dirtied=1
  ->  Function Scan on pg_catalog.unnest p  (actual time=0.079..0.102 rows=9 loops=1)
        Buffers: shared hit=18
Planning Time: 0.233 ms
Execution Time: 1.371 ms
```

| 항목 | 개선 전 (오답 9건) | 개선 후 (오답 9건) |
|---|---|---|
| 문장 수 | SELECT 9 + INSERT 9 = 18 | **1** |
| 버퍼 접근 | 6×9 + 68×9 = 666 | **154** |
| 실행 시간 | (0.383 + 0.793) × 9 ≈ 10.58 ms | **1.371 ms** |
| 처리 내역 | — | Tuples Inserted 4 + Conflicting Tuples 5 = 9 |

`Conflict Arbiter Indexes`에 사이클 1이 만든 `ix_wrong_answered_note_user_problem`이 찍혀 있다.
두 사이클이 맞물려 동작한 증거이며, 인덱스 없이는 `ON CONFLICT`가 성립하지 않는다.

폐기한 오염 측정에서는 같은 계획의 버퍼가 92였으나 이번에는 154다. VACUUM으로 페이지 배치가 달라진 결과로 보이나 확정하지 못했다.
어느 값이든 개선 전 666보다 크게 낮다.

### 판정

- **개선 여부 (하드웨어 독립 증거 기준): 있음.**
  오답노트 구간 요청당 쿼리 18 → 1.00, 오답 9건당 버퍼 접근 666 → 154.
  둘 다 계수 기반이라 측정 편차나 dead tuple 상태와 무관하다.

- 예상 효과와의 대조:
  - "요청당 쿼리 18 → 1" 예상 → 실측 1.00. 일치.
  - Phase 6에서 예상한 "DB 실행 시간 감소폭은 6%p 남짓" → 실측 오답노트 구간 비중 17.91% → 9.17% (8.74%p). 일치.
  - "check-then-act 경쟁 해소" → `Conflict Resolution: UPDATE`로 한 문장 내 처리 확인. 일치.

- **하드웨어 의존 지표는 비교 불가로 명시한다.** p95 −49.1%, RPS +57.5%에는 VACUUM 효과가 섞여 있다.
  분리하려면 사이클 1 상태로 코드를 되돌려 VACUUM 후 재측정해야 하며, 이번에는 하지 않았다.

- **왕복 비용에 대한 판정**: 왕복 **횟수** 감소(요청당 17회)는 확정이다. 그러나 그것이 응답시간에 기여한 몫은 분리되지 않는다.
  DB 실행 밖 시간이 554.38 → 425.27 ms(−129.11 ms)로 줄었지만, 이를 사라진 왕복 17회로 나누면 회당 7.6 ms다.
  로컬 루프백에서 성립할 수 없는 값이므로 129 ms의 대부분은 왕복이 아니라 **커넥션 획득 대기 감소**로 보인다
  (쿼리 수 감소와 DB 속도 개선이 커넥션 보유 시간을 줄인 결과이며, 두 변경 모두의 몫이 섞여 있다).
  확인하려면 `hikaricp_connections_acquire_seconds` 미터를 별도로 캡처해야 한다.

- 남은 위험 신호: **`problem_submission` INSERT가 단독 1위 73.16%** (요청당 30회, mean 0.4347570695423183).
  사이클 3 후보(다중행 INSERT)가 그대로 남아 있다.

- 측정 절차 변경: 되돌리기 단계 뒤에 `VACUUM ANALYZE`를 추가했다. 이후 모든 측정에 적용한다.

---

## 사이클 3: `problem_submission` 다중행 INSERT

### 설계 결정

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 대상 | `ProblemSubmissionCommandService.saveProblemSubmissions`의 `saveAll` → 다중행 INSERT 1회 | 요청당 30회, 296,280 calls, mean 0.4347570695423183, total 128,809.82 ms, **전체의 73.16%**. 요청당 DB 실행 17.83 ms 중 13.04 ms가 이 쿼리다. IDENTITY라 Hibernate JDBC 배치가 원천 봉쇄된다 |
| 데이터 전달 형태 | **JSON + `jsonb_to_recordset`** | 행마다 달라지는 컬럼이 4개(`problem_id`, `is_correct`, `selected_option_id`, `submitted_content`)다. `submitted_content`가 **사용자 입력 텍스트**라 사이클 2의 배열 리터럴 문자열 조립을 그대로 쓸 수 없다(이스케이프가 인젝션 경로가 된다). Jackson이 직렬화를 담당하고 파라미터는 문자열 1개라 `@Query`를 유지할 수 있다 |
| 시그니처 | `saveProblemSubmissions(long, List<...>)` **유지, 내부만 교체** | 시그니처가 이미 `List`를 받는다. `LessonFacade:93`과 `ProblemFacade:57` 모두 수정 불필요. `ProblemFacade`는 1건짜리라 문장 수가 1 → 1로 변화 없고, JSON 직렬화 1회만 추가된다 |
| JSON 페이로드 | `problem/dto/internal/ProblemSubmissionRow` record, `@JsonProperty`로 snake_case 고정 | `jsonb_to_recordset`은 SQL 선언과 JSON 키가 정확히 일치해야 하고, 어긋나면 `is_correct`가 NULL이 되어 NOT NULL 위반으로 터진다. `@JsonProperty`로 못 박으면 Jackson 설정 변화에 영향받지 않고 테이블 컬럼명과도 같은 이름이 된다 |
| 타임스탬프 | `Clock` 빈 → `LocalDateTime.now(clock)` (사이클 2와 동일) | 네이티브 쿼리는 `BaseEntity`의 `@PrePersist`를 타지 않는다. Postgres `now()`는 서버 TZ(UTC)라 KST와 어긋난다. 같은 트랜잭션의 두 네이티브 INSERT가 같은 시각을 쓴다 |
| 영속성 컨텍스트 | **명시적 flush/clear 없음** | INSERT 시점(`LessonFacade:93`)에 `problem_submission`에 대기 중인 JPA 변경이 없다. `lesson_submission`은 IDENTITY라 이미 즉시 실행됐고, 오답노트 UPSERT·`users`·`learning`은 모두 이후에 발생한다. FK 제약도 없다. 반환값은 `requests`에서 계산하므로 엔티티 영속화에 의존하지 않는다 |

**적용할 SQL**

```sql
INSERT INTO problem_submission (user_id, problem_id, is_correct, selected_option_id, submitted_content, created_at, updated_at)
SELECT :userId, t.problem_id, t.is_correct, t.selected_option_id, t.submitted_content, :now, :now
FROM jsonb_to_recordset(CAST(:payload AS jsonb))
     AS t(problem_id bigint, is_correct boolean, selected_option_id bigint, submitted_content text)
```

- 검토했지만 택하지 않은 안:
  - `VALUES` 절 동적 조립 — 문제 수가 늘어날 예정이라 쿼리 원문이 퍼지고 `pg_stat_statements` 항목이 쪼개진다. N의 함수로 기술하려는 목표와 충돌한다
  - `java.sql.Array` 병렬 배열 4개 — 안전하지만 `Connection.createArrayOf`가 필요해 `@Query`로는 불가하고 `JdbcTemplate` 구조로 갈라진다
  - `JdbcTemplate.batchUpdate` — 왕복은 1회지만 `pg_stat_statements`의 `calls`가 30으로 남아 하드웨어 독립 지표가 개선되지 않고, `F`를 분리할 두 번째 점을 얻지 못한다
  - 기존 요청 DTO(`ProblemSubmissionSaveRequest`) 재사용 — 요청 DTO가 DB 페이로드로 흘러가고, Jackson이 `isCorrect`의 `is` 접두사를 깎을 수 있어 설정 변화에 취약하다
  - `Map<String, Object>` 페이로드 — 키가 문자열 리터럴이라 오타가 런타임에만 드러난다. 컨벤션의 매직스트링 금지에도 어긋난다

- 호출자가 예상한 효과: 요청당 쿼리 30 → 1

- **부수 효과**: `saveAll`이 사라지면 `ProblemSubmission` 30개가 영속성 컨텍스트에 올라가지 않는다.
  사이클 2가 도입한 네이티브 쿼리 자동 flush가 훑을 관리 엔티티가 그만큼 줄어 flush 자체도 싸진다.

- **정리 대상**: `ProblemSubmission.create` 정적 팩토리와 `problemSubmissionRepository.saveAll` 호출이 사용처를 잃는다.
  엔티티 매핑 자체는 읽기 쿼리(`findWeakUnitsByUserId`)가 쓰므로 유지한다.

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 820.8402499999999 / 1148.8985 ms |
| med | 443.10249999999996 ms |
| RPS | 82.2901731818192 |
| 요청 수 | 9876 |
| 요청당 쿼리 수 | 약 45건 (오답노트 구간이 1로 접힌 뒤) |
| **대상 요청당 호출 수** | **30.00** |
| 대상 calls / mean_ms / total_ms | 296280 / 0.4347570695423183 / 128809.82456399893 (73.1629614619832%) |
| 요청당 대상 시간 | 13.04 ms |
| 문제 30건당 버퍼 접근 | 74 × 30 = **2,220** |

**실행계획**

> 원본: `query-plan-2.txt` (오답노트 UPSERT 뒤에 덧붙임). 개선 후는 `query-plan-3.txt`

- EXPLAIN 파라미터: `user_id` = 1501, `problem_id` = 910035, `is_correct` = false,
  `selected_option_id` = 910035, `submitted_content` = NULL
  - 1501·910035는 사이클 1·2와 동일. 910035는 홀수 = OBJECTIVE라 k6가 보내는 객관식 형태와 일치한다
  - `problem_submission`에는 유니크 제약이 없어 중복 삽입이 문제되지 않는다

| 노드 | 스캔 방식 | actual time | 추정 rows | 실측 rows | loops | Rows Removed by Filter | shared hit / read |
|---|---|---|---|---|---|---|---|
| `Insert on public.problem_submission` | 쓰기 노드 | 0.940..0.944 | 0 | 0 | 1 | 없음 | **74** / 0 (dirtied=1) |
| └ `Result` (자식) | 값 생성 | 0.084..0.085 | 1 | 1 | 1 | 없음 | 10 / 0 |

- INSERT 노드의 rows=0은 `RETURNING`이 없어 상위로 내보낼 행이 없다는 뜻이다.
- 자식 `Result`가 0.084 ms이므로 실제 쓰기 작업은 약 0.86 ms다.
- `shared hit=74` (592 KB): 힙 쓰기 + 인덱스 2개(PK, `ix_problem_submission_user_problem`) 갱신.
  B-tree를 루트→중간→리프로 내려가는 읽기가 대부분이다.
- `dirtied=1`이 표시됐다. 사이클 2의 오답노트 INSERT에서는 안 보였는데, `VACUUM ANALYZE` 이후라 페이지가 깨끗한 상태였기 때문으로 보인다.
- `Result`의 `Output`에 `nextval('problem_submission_id_seq')`가 보인다.
- Planning Time 0.084 ms — 오답노트 UPSERT의 0.233 ms보다 짧다. 단순 `VALUES` 문장이라 계획할 것이 적다.

**호출 스택 (로직 개선 사이클의 추가 캡처)**

```
LessonFacade.saveLessonSubmission:93
  └ ProblemSubmissionCommandService.saveProblemSubmissions:36
      └ problemSubmissionRepository.saveAll(problemSubmissions)   ← IDENTITY라 INSERT ×30으로 전개
```

**해석**

계획 자체에는 문제가 없다. 인덱스도 필터도 정상이고, **비용이 전부 "이것을 30번 한다"에서 온다.**
사이클 1과 성격이 다르다 — 그때는 쿼리 하나가 느렸고(Seq Scan), 지금은 쿼리가 많다.

**F / R 분리를 위한 첫 번째 점**

```
30 × (F + R) = 13.04 ms   →   F + R = 0.4348 ms
```

사이클 3 측정이 두 번째 점(`F + 30R`)을 주면 F와 R이 풀리고, "문제 N개에 대해 (N−1)×F 절감"을 실측 계수로 쓸 수 있다.

**위험 신호 대조**

| 지표 | 기준 | 실측 | 판정 |
|---|---|---|---|
| 단일 쿼리 total_exec_time 점유율 | 30% 이상 | 73.16% | 초과 |
| 동일 쿼리 요청당 호출 횟수 | 1회 초과 | 30회 | 해당 |
| 검사 행 / 반환 행 | 100:1 초과 | 해당 없음 (쓰기) | - |
| OLTP 경로의 Seq Scan | 1만 행 이상 | 없음 | - |

### 적용 내용

| 파일 | 변경 |
|---|---|
| `problem/dto/internal/ProblemSubmissionRow.java` | 신규. `@JsonProperty`로 snake_case 키 고정, `from(ProblemSubmissionSaveRequest)` 정적 팩토리 |
| `problem/repository/ProblemSubmissionRepository.java` | `@Modifying @Query(nativeQuery = true) void insertAll(userId, payload, now)` 추가 |
| `problem/service/ProblemSubmissionCommandService.java` | `saveAll` → `insertAll` 교체. `ObjectMapper`·`Clock` 주입, `toPayload` private 메서드 추가, `createProblemSubmission` 제거 |
| `global/exception/domain/CustomErrorCode.java` | `PROBLEM_SUBMISSION_SERIALIZE_FAILED(500, "PROBLEM_5001", ...)` 추가 |
| `lesson/facade/LessonFacade.java` / `problem/facade/ProblemFacade.java` | **변경 없음** (시그니처 유지) |

- 테스트: `./gradlew test` 통과
- **사이클 2와 달리 새 쿼리 경로가 통합 테스트로 검증됐다.**
  `ProblemSubmissionCommandServiceIntegrationTest`가 Testcontainers의 실제 Postgres에서 `saveProblemSubmissions`를
  호출하고 `findAll()`로 저장 결과를 확인하므로, `jsonb_to_recordset`의 Hibernate 파싱·JSON 키 일치·타임스탬프 채움이 모두 통과 범위에 들어간다.
- `ProblemSubmission.create` 정적 팩토리는 사용처를 잃었으나 이번 사이클에서는 제거하지 않았다(엔티티 매핑은 읽기 쿼리가 사용).

### 개선 후 지표

**측정 조건**: 사이클 2와 동일 (VU 50 / 유지 1m / Redis cold / 되돌리기 후 `VACUUM ANALYZE`). 조건 변경 없음.

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 820.8402499999999 ms | 658.8817499999996 ms | −19.7% |
| | p99 | 1148.8985 ms | 1109.8230099999998 ms | −3.4% |
| | med | 443.10249999999996 ms | 217.7925 ms | −50.8% |
| | RPS | 82.2901731818192 | 144.15073200449967 | +75.2% |
| | 요청 수 | 9876 | 17300 | +75.2% |
| | max | 2110.007 ms | 2584.645 ms | +22.5% |
| 하드웨어 독립 | 대상 요청당 호출 수 | 30.00 | **1.00** | **−96.7%** |
| | 요청당 대상 시간 | 13.04 ms | 8.96 ms | −31.3% |
| | 대상 비중 | 73.1629614619832% | 56.969% | −16.19%p |
| | 문제 30건당 버퍼 접근 | 74 × 30 = 2,220 | **248** | **−88.8%** |
| | 요청당 DB 실행 시간 | 17.83 ms | 15.73 ms | −11.8% |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클이 아님 |

**주의**: 문장당 mean은 0.4347570695423183 → 8.9631 ms로 **올랐다.** 한 문장이 30행을 처리하게 됐기 때문이다.
내려간 것은 요청당 호출 수와 요청당 총 비용이다.

**개선 후 실행계획** (`query-plan-3.txt`)

```
Insert on public.problem_submission  (cost=0.00..2.25 rows=0 width=0) (actual time=1.685..1.691 rows=0 loops=1)
  Buffers: shared hit=248 dirtied=1 written=1
  ->  Function Scan on pg_catalog.jsonb_to_recordset t  (cost=0.00..2.25 rows=100 width=81)
                                                        (actual time=0.135..0.168 rows=30 loops=1)
        Buffers: shared hit=39
Planning Time: 0.186 ms
Execution Time: 1.810 ms
```

| 항목 | 개선 전 (문제 30건) | 개선 후 (문제 30건) |
|---|---|---|
| 문장 수 | 30 | **1** |
| 버퍼 접근 | 74 × 30 = 2,220 | **248** |
| 실행 시간 | 0.992 × 30 ≈ 29.76 ms | **1.810 ms** |

`Function Scan`의 추정 rows=100 대 실측 30은 집합 반환 함수의 플래너 기본 추정치다.
3.3배 차이로 위험 신호 기준(10배) 아래이고, 조인 대상이 없어 계획 선택에 영향이 없다.

### F / R 분리 (사이클 3의 부수 성과)

```
상태 2 (개별 30회) :  30 × (F + R) = 13.04 ms   →  F + R  = 0.43476 ms
상태 3 (다중행 1회):  F + 30R      =  8.9631 ms
                      29R = 8.5283  →  R = 0.29408 ms,  F = 0.14068 ms
```

검산: 절감 `29 × 0.14068 = 4.08 ms` = 실측 `13.04 − 8.96 = 4.08 ms`

**절감 공식: 문제 N개당 문장 `N − 1`개 감소, DB 실행 시간 `(N − 1) × 0.1407 ms` 절감**

| N | 절감 문장 | DB 실행 시간 절감 |
|---|---|---|
| 7 (현재 실제) | 6 | 0.84 ms |
| 8 | 7 | 0.98 ms |
| 30 (측정 조건) | 29 | 4.08 ms |
| 50 | 49 | 6.89 ms |

한계 두 가지:
1. `R`이 두 상태에서 동일하다고 가정했다. 다중행 문장은 페이지 지역성이 좋아 `R`이 더 작을 수 있고, 그 차이는 `F`에 흡수된다.
2. `F`는 서버측 실행 시간만 반영한다. 네트워크 왕복, 드라이버·datasource-proxy 리스너 오버헤드가 빠져 있어 실제 절감은 이보다 크다.

### 판정

- **개선 여부 (하드웨어 독립 증거 기준): 있음.**
  대상 요청당 호출 수 30.00 → 1.00, 문제 30건당 버퍼 접근 2,220 → 248, 요청당 대상 시간 13.04 → 8.96 ms.

- 예상 효과와의 대조: "요청당 쿼리 30 → 1" 예상 → 실측 1.00. 일치.
  사이클 3의 부수 목적이었던 `F`/`R` 분리도 달성해 결과를 N의 함수로 기술할 수 있게 됐다.

- **처리량 증가로 다른 쿼리의 호출당 비용이 올랐다.** 개선으로 여유가 생겨 시스템이 더 높은 부하에서 돌기 때문이다.

  | 쿼리 | 사이클 2 요청당 | 사이클 3 요청당 | 변화 |
  |---|---|---|---|
  | 오답노트 UPSERT | 1.6354 ms | 2.9530 ms | +80.6% |
  | `lesson_submission` exists | 0.8335 ms | 0.9757 ms | +17.1% |
  | 리그명 조회 | 0.2644 ms | 0.3896 ms | +47.4% |

  전체 DB 실행 시간이 176,060 → 272,188 ms로 늘어난 것도 같은 이유다. 요청이 75% 많아졌으므로 총량은 늘고 요청당은 줄었다.

- 남은 위험 신호: `problem_submission` INSERT가 여전히 1위(56.97%)다.
  다만 요청당 1회가 되어 N+1 성격은 사라졌고, 남은 것은 행당 작업 `R = 0.294 ms`다.
  30행을 넣는 본질적 비용이라 더 줄일 여지가 크지 않다.

- 다음 사이클 진행 여부: **종료** (호출자 결정)

- 진행하지 않은 후보:

  | 후보 | 근거 | 예상 효과 |
  |---|---|---|
  | `lesson_submission (user_id, lesson_id)` 인덱스 | exists 6.20% + count 2.25% = 8.45%, 둘 다 `(lesson_id, user_id)` 조건인데 기존 인덱스는 `(user_id, created_at)` | 두 쿼리 단가 하락 |
  | `JwtAuthFilter` 중복 `findById` 제거 | 요청당 `users` SELECT 3.04회 중 2회가 인증 필터 | 요청당 쿼리 −1, 시간 효과 0.67% 미만 |
  | `problem_submission`의 `R` 축소 | `ix_problem_submission_user_problem` 유지 비용 | 읽기 쿼리(weak-concepts)가 그 인덱스를 쓰므로 트레이드오프 |

---

## 최종 요약

| 구분 | 지표 | 최초 (상태 0) | 최종 (상태 3) | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 3204.7293999999993 ms | 658.8817499999996 ms | **−79.4%** |
| | p99 | 3644.5262999999995 ms | 1109.8230099999998 ms | **−69.5%** |
| | med | 1005.8735 ms | 217.7925 ms | −78.3% |
| | RPS | 30.05442998801386 | 144.15073200449967 | **+379.6%** |
| | 요청 수 (2분) | 3610 | 17300 | +379.2% |
| | 실패율 / check | 0 / 1 | 0 / 1 | 동일 |
| 하드웨어 독립 | 요청당 쿼리 수 | 약 60건 | 약 16건 | −73% |
| | 오답노트 구간 요청당 쿼리 | 18 (SELECT 9 + INSERT 9) | **1.00** | −94.4% |
| | 문제 저장 요청당 쿼리 | 30 | **1.00** | −96.7% |
| | 검사 행 / 반환 행 (오답노트 조회) | 32,490 : 1 | **1 : 1** | 해소 |
| | 스캔 방식 (오답노트 조회) | Seq Scan | **Index Scan** | 변경 |
| | 오답 9건당 버퍼 접근 | 666 | **154** | −76.9% |
| | 문제 30건당 버퍼 접근 | 2,220 | **248** | −88.8% |
| | 요청당 DB 실행 시간 | 79.96 ms | 15.73 ms | **−80.3%** |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 기법 미적용 |

적용한 기법:
1. `wrong_answered_note (user_id, problem_id)` 유니크 인덱스 추가 (V34)
2. 오답노트 저장을 다중행 UPSERT로 전환 (`unnest` + `ON CONFLICT DO UPDATE`)
3. 문제 풀이 저장을 다중행 INSERT로 전환 (`jsonb_to_recordset`)

**하드웨어 의존 지표는 기법 효과만이 아니다.** 사이클 2 측정 직전에 `VACUUM ANALYZE`를 절차에 추가했고,
상태 0·1은 그 이전에 측정되었다. p95 −79.4%와 RPS +379.6%에는 dead tuple 회수 효과가 섞여 있으며 분리하지 않았다.
기법 효과로 확정된 것은 하드웨어 독립 증거다.

**측정 조건은 실제보다 큰 요청을 가정한다.** N=30 / W=9는 현재 서비스(레슨당 6~8문제)의 약 4배다.
문제 수를 늘릴 예정이라 조건을 유지했고, 결과는 N의 함수로 기술했다.

**인계 사항 (담당 범위 밖)**

`AFTER_COMMIT` 리스너 4개가 `REQUIRES_NEW`로 커넥션을 추가 점유해, 요청 하나가 커넥션 2개를 동시에 필요로 한다.
`풀 크기 ≥ 동시 요청 수 + 1`을 만족하지 못하면 데드락이 재현된다. 근본 해결은 리스너를 `@Async`로 분리하거나
`REQUIRES_NEW`를 걷어내는 쪽이다. 상세는 위 *기준선 1차 시도 실패* 절 참조.

부수로 발견한 두 건도 함께 남긴다.
- `application-perf.yml`의 `spring.datasource.hikari.*`가 적용되지 않고 있었다 (`DatasourceConfig`에서 수정 완료).
- `ProblemFacade:58` 경로의 오답노트 저장은 단건 메서드를 그대로 쓰므로 check-then-act 경쟁이 남아 있다.
