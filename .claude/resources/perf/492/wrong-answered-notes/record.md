# [PERF-492] GET /api/v1/wrong-answered-notes/{unitId}

> 이슈: #492
> 브랜치: refactor/492-bookmark-wrong-note-query-performance
> 대상 디렉토리: `.claude/resources/perf/492/wrong-answered-notes/`

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
| 1 | 불필요한 `Unit` 조인 제거 (`WHERE l.unitId = :unitId`) | ✅ | ✅ | ✅ | ✅ |

## 대상

- 엔드포인트: `GET /api/v1/wrong-answered-notes/{unitId}`
- 실행 경로: `JwtAuthFilter` → `LastAccessInterceptor` → `WrongAnsweredNoteController` → `WrongAnsweredNoteFacade` → (`UnitQueryService`, `WrongAnsweredNoteService`, `ProblemFactory`) → 각 Repository
- 트랜잭션 경계: `WrongAnsweredNoteFacade.getAllWrongAnsweredProblemInUnit`에 `@Transactional(readOnly = true)`. `LastAccessInterceptor` → `UserAccessService.updateLastAccessed`가 별도 `@Transactional`로 앞에 붙는다
- 예상 쿼리 목록 (요청 1회 기준, 고정 6개)

  Controller 앞단 (2개)
  1. `UserRepository.findById` - `users` PK 단건 조회. 인증 필터(`AuthTokenProvider.parseUser:67-71`)에서 발생
  2. `UserRepository.updateLastAccessedAt` - `users` UPDATE. `LastAccessInterceptor.preHandle` → `UserAccessService.updateLastAccessed`(`@Transactional`). `WebMvcConfig:34`에서 `/**`에 등록되어 이 경로에도 걸린다. 읽기 엔드포인트에 쓰기가 1회 섞인다

  Controller 이후 (4개)
  3. `UnitRepository.findUnitSummaryById` - `Unit` 단일 테이블 PK 조회, DTO 프로젝션
  4. `WrongAnsweredNoteRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId` - `WrongAnsweredNote ⋈ Problem ⋈ Lesson ⋈ Unit` 내부 조인 + `Bookmark` LEFT JOIN(`b.problemId = p.id AND b.userId = :userId`), `WHERE wan.userId = ? AND u.id = ? AND wan.resolvedAt IS NULL`. `ORDER BY` 없음
  5. `AnswerRepository.findByProblemIdIn` - 결과에 SUBJECTIVE 문제가 있을 때만 1회 (`ProblemFactory:25` → `AnswerQueryService:30`)
  6. `OptionRepository.findAllByProblemIdIn` - 결과에 OBJECTIVE 문제가 있을 때만 1회 (`ProblemFactory:26` → `OptionQueryService:29`)

- 대상 유닛 900002는 OBJECTIVE 30 / SUBJECTIVE 30이라 5번과 6번이 모두 조건을 통과한다. 쿼리 수는 6개로 고정이다
- 지연 로딩 추가 쿼리 후보: 없음. 3, 4, 6번은 `SELECT new ...Response(...)` DTO 프로젝션이고, 5번만 `List<Answer>` 엔티티를 반환하지만 `Answer`는 `id`/`content`/`explanation`/`problemId` 스칼라 4개뿐이라 연관관계가 없다
- N+1 후보: 없음. `ProblemFactory.create`가 문제 타입별로 ID를 모아 `IN` 절 배치 조회 2회로 끝낸다. 오답 문제 개수가 늘어도 쿼리 수는 늘지 않는다
- 사전 관찰(미검증): `wrong_answered_note`에는 `V34`의 `(user_id, problem_id)` UNIQUE 인덱스가 있다. 대상 쿼리의 선두 필터가 `wan.userId`이므로 이 인덱스를 탈 여지가 있다. `resolved_at`(`V30` 추가)에는 인덱스가 없다

### 기준선의 전제 (이 대상 고유)

이 대상의 `-0`은 **아무것도 적용하지 않은 원본이 아니다.** 같은 이슈의 앞 대상(`GET /api/v1/bookmarks/{unitId}`)에서 추가한
`V38__add_bookmark_user_problem_unique_index.sql`의 `bookmark (user_id, problem_id)` UNIQUE 인덱스가 이미 적용된 상태다.

대상 쿼리가 `LEFT JOIN Bookmark b ON b.problemId = p.id AND b.userId = :userId`를 포함하므로 그 인덱스를 이미 탄다.
즉 이 대상의 기준선에는 앞 대상의 개선분이 섞여 있다. 사이클 판정에서 감안한다.

## 측정 환경

> 값이 바뀌면 그 사실을 사이클 기록에 남긴다.

| 항목 | 값 |
|---|---|
| 프로파일 | perf (`application="gravit-perf"` 확인, `application-perf.yml:34`) |
| 커넥션 풀 크기 | 60 (`application-perf.yml:17` `maximum-pool-size`) |
| 데이터 규모 | `wrong_answered_note` 195,700 / `bookmark` 156,000 / `problem` 6,900 / `option` 13,800 / `answer` 3,450 / `lesson` 230 / `unit` 66 / `users` 1,002. 대상 유닛 900002는 문제 60건(OBJECTIVE 30, SUBJECTIVE 30) |
| 카디널리티 | `wrong_answered_note.user_id` 1,000 (유저당 195.7행) / `wrong_answered_note.problem_id` 202 / `resolved_at` NULL 185,700 · NOT NULL 10,000. 요청당 결과 30건 (OBJECTIVE 15, SUBJECTIVE 15) |
| 부하 조건 | VU 50, 유지 1m (ramp-up 30s + 유지 1m + ramp-down 30s = 총 2m). 앞 대상 `bookmarks` 및 #490과 동일 조건 |
| Redis 캐시 상태 | cold (measure 직전 FLUSHDB). 단 이 API는 Redis를 쓰지 않는다 |
| DB 캐시 상태 | 제어하지 않음. Redis FLUSHDB는 PostgreSQL의 `shared_buffers`와 OS page cache를 비우지 않는다 |
| 캐시 제어 수단 | `redis-cli -h localhost -p 6379` (PONG 확인) |
| 시드 SQL | `../seeds.sql` (이슈 공용) |
| 시드 모듈과 변수 | `review.sql`. `user_start` 1001, `user_count` 1000, `target_unit_id` 900002, `bookmarks_per_user` 156, `target_unit_bookmarks_per_user` 30, `options_per_problem` 4, **`target_unit_wrong_notes_per_user` 40, `target_unit_resolved_per_user` 10** (이번 대상에서 추가). `answer`/`option`/`bookmark` 블록은 가드에 걸려 `INSERT 0 0`, `wrong_answered_note`만 40,000행 적재 |
| 시드 이력 | 진입 시 `wrong_answered_note` 155,700행이 **전부 유닛 910001**에 있었고 대상 유닛 900002에는 0행이었다. 그대로 재면 API가 빈 리스트를 반환해 `ProblemFactory`가 두 조회를 건너뛰어 6쿼리가 아니라 4쿼리가 된다. 그래서 `review.sql`에 `wrong_answered_note` 블록을 추가해 900002를 채웠다. 기존 155,700행은 지우지 않고 `user_id` 필터가 걸러낼 잡음으로 남겼다 |
| DB 접속 | `PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d mydb` (5433은 컨테이너 5432 매핑) |
| 관측 도구 | `pg_stat_statements` 유효 (48행), 히스토그램 버킷 146개 노출 |
| 앱 기동 이력 | V38 적용을 위해 앞 대상 종료 후 재기동했다. 그래서 Phase 2를 건너뛰지 않고 다시 검증했다 |

## 기준선 (Baseline)

| 지표 | 값 |
|---|---|
| p95 | 192.63904999999988ms |
| p99 | 253.12869999999998ms |
| RPS | 382.23845109833474 |
| 에러율 | 0 |
| check 통과율 | 1 (45872/45872, 3개 항목 전부. `problems` 30건 검증 포함) |
| 요청당 쿼리 수 | 6 (트랜잭션 제어문 제외). 트랜잭션은 요청당 3개 (`BEGIN READ ONLY` 2 + `BEGIN` 1.0001) |

- med 97.561ms / max 496.084ms / 요청 45,872건 / 수신 667,078,851바이트 (요청당 14,542)
- 요청당 DB 시간 합 13.2309ms (트랜잭션 제어 포함 13.2920ms)

### 쿼리 통계 (total_exec_time 상위)

> 전체: `query-stats-summary-0.md` / k6 요약: `k6-test-summary-0.json`
> 여기에는 진단 근거로 쓴 행만 옮긴다. 전체를 복사하지 않는다.

| 요청당 | mean_ms | total_ms | 비중 | 출처 |
|---|---|---|---|---|
| 1.00 | 7.283352535708062 | 334101.947518001 | 54.79509378993013% | `OptionRepository.findAllByProblemIdIn` |
| 1.00 | 4.0971767350671575 | 187945.69119100034 | 30.82442904846952% | `WrongAnsweredNoteRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId` |
| 1.00 | 1.6740161849494228 | 76790.47043599872 | 12.594182886308074% | `AnswerRepository.findByProblemIdIn` |

**행당 비용** (mean_ms ÷ 행/호출)

| 쿼리 | mean_ms | 행/호출 | ms/행 |
|---|---|---|---|
| `option` | 7.2834 | 60 | 0.12139 |
| 대상 쿼리 | 4.0972 | 30 | 0.13657 |
| `answer` | 1.6740 | 15 | 0.11160 |

### 진단

- 병목 성격: 대상 쿼리(`findWrongAnsweredProblemDetailByUnitIdAndUserId`)의 쿼리 자체 비효율. 호출 횟수가 아니라 단일 쿼리 1건의 실행 비용이 문제다
- 근거:
  - 대상 쿼리의 요청당 호출 수가 1.00이다. N+1이 아니다
  - 행/호출 30으로 시드한 결과 크기와 정확히 일치한다. 반환 행 수 자체는 예상대로다
  - 행당 비용 0.13657ms로 상위 3개 쿼리 중 1위다. 총 시간 비중은 30.82%로 2위지만, 1위 `option`(54.80%)은 단위 비용이 나빠서가 아니라 반환 행 수가 가장 많아서(60행) 총합이 큰 것으로 설명된다. 세 쿼리의 행 수 비 60 : 30 : 15 = 4 : 2 : 1이 비중 비 4.35 : 2.45 : 1과 거의 일치한다
  - 대상 쿼리만 5테이블 조인이고 나머지 둘은 단일 테이블 `IN` 조회다
  - `option.problem_id`(`ix_option_problem`, `V3:26`)와 `answer.problem_id`(`ix_answer_problem`, `V3:23`)에는 이미 인덱스가 있고 테이블도 13,800행 / 3,450행으로 작다
  - 비중 30.82%는 위험 신호 기준(30%)을 넘는다
- 미해결 질문: 대상 쿼리가 느린 원인이 조인인지, 조인이라면 어느 조인인지. 조인 4개 중 `Unit` 조인은 얻는 컬럼이 `u.id` 하나뿐이고 그 값이 이미 `l.unitId`에 있어 `WHERE l.unitId = :unitId`로 대체 가능하다(반정규화 없이 제거 가능). 나머지 3개(`problem` 응답 컬럼, `lesson` 경유 경로, `bookmark` LEFT JOIN의 `isBookmarked`)는 대체 경로가 없다. 실행계획으로 갈린다
- 예상 쿼리 목록과 어긋난 지점: 없음. Phase 1에서 확정한 6개(앞단 2 + Controller 이후 4)가 개수와 출처 모두 일치한다. `BEGIN READ ONLY` 2.00회도 트랜잭션 경계 2개(`LastAccessInterceptor`는 `BEGIN`)와 맞는다
  - 목록 밖 관측: `season ... FOR NO KEY UPDATE` 4건(2분간 총 4회, 요청당 0.000087, 비중 1.09e-05%). 요청 경로가 아닌 스케줄러로 보이나 출처를 특정하지 못했다

---

## 사이클 1: 불필요한 `Unit` 조인 제거

### 설계 결정

| 결정 항목 | 정한 값 | 근거 |
|---|---|---|
| 대체 조건절 | `JOIN Unit u ON u.id = l.unitId ... WHERE u.id = :unitId` → `WHERE l.unitId = :unitId` | `Unit`에서 얻는 값이 `u.id` 하나뿐이고, 조인 조건 `u.id = l.unitId`에 의해 그 값은 항상 `l.unitId`와 같다. FK 값을 이미 들고 있는데 부모 테이블을 다시 찾아가는 형태다 |
| 적용 범위 | 불필요한 4곳 전부 (`WrongAnsweredNoteRepository` 2, `BookmarkRepository` 2) | 같은 결함을 한쪽만 고치면 왜 한쪽만 그런지 알 수 없다. `Unit` 조인 8곳 중 나머지 4곳은 `u.title` 프로젝션이나 `u.chapterId` 경유 Chapter 조인에 쓰여 제거 대상이 아니다 |
| 마이그레이션 | 없음 | 스키마 변경이 아니라 JPQL 수정이다 |
| 메서드 시그니처 | 유지 | 파라미터도 반환 타입도 그대로다. 호출부 변경 없음 |
| 감수할 것 | 4곳 중 3곳은 측정되지 않은 변경 | Phase 8이 재측정하는 것은 대상 쿼리 1곳뿐이다. 나머지 3곳은 같은 형태의 변경이라 안전하다고 판단했을 뿐 효과를 잰 것이 아니다 |

**등가성 검증**

`lesson.unit_id`에는 FK 제약이 없다(`V1__init_tables.sql:106-112`, `V14`에도 없음). 따라서 이론적으로는 존재하지 않는 유닛을 가리키는 레슨이 있을 수 있고,
그 경우 `JOIN Unit`(inner)은 행을 버리지만 `WHERE l.unitId`는 행을 남겨 결과가 갈린다.

그러나 4개 쿼리의 호출 경로가 전부 `UnitQueryService.getUnitSummaryByUnitId`를 먼저 호출해 유닛이 없으면 `UNIT_NOT_FOUND`를 던진다.

- `WrongAnsweredNoteFacade:30` → `:32`
- `BookmarkFacade:30` → `:32`
- `LessonFacade:60` → `:66`, `:67`

유닛이 존재하지 않으면 쿼리에 도달하지 못하므로, 이 변경으로 동작이 달라지는 경로는 현재 코드에 없다.

- 검토했지만 택하지 않은 안:
  - `wrong_answered_note`에 `unit_id` 반정규화 + `(user_id, unit_id)` 인덱스 - 비싼 노드(`problem` Seq Scan + Hash Join, 74.3%)를 없앨 수 있으나, 그 노드는 **콘텐츠 양에만 비례하고 유저 수로는 커지지 않는다**. `wrong_answered_note`(195,700행)와 `bookmark`(156,000행)는 점 조회라 O(log n)이다. 영구적인 정합성 책임(문제의 레슨 이동 시 동기화)과 195,700행 백필을 지불하고 얻는 것이 응답시간 2.7%(2.686ms / med 97.561ms)라 근거가 부족하다
  - 유닛→문제 목록 캐싱 - 같은 74.3%를 노리므로 상한이 같은데 무효화 경로 설계 비용이 추가된다
  - `problem` 조회를 인덱스 경로로 유도 - `ix_problem_lesson`(`V3:4`)이 있으나 `problem.lesson_id` correlation -0.193으로 군집도가 낮아 플래너가 Seq Scan(cost 161)을 고른다. 뒤집으려면 `content`(TEXT)까지 커버링에 넣어야 해 설계가 성립하지 않는다
- 대상 API 밖의 부수 효과: `BookmarkRepository.findBookmarkedProblemDetailByUnitIdAndUserId`(앞 대상이 측정한 쿼리), `BookmarkRepository.countByUnitIdAndUserId`, `WrongAnsweredNoteRepository.countByUnitIdAndUserId`에서도 `unit` 스캔 노드가 사라진다. 앞 대상 `bookmarks/record.md`에 적힌 쿼리 원문과 실행계획은 측정 당시 기록으로는 유효하나 현재 코드와는 어긋나게 된다
- 호출자가 예상한 효과: `Seq Scan on unit` 노드와 Nested Loop 1개가 사라진다. Execution Time -1.0%(0.036ms), 버퍼 -2

### 측정 조건의 한계

이 대상의 기준선(`-0`)은 아무것도 적용하지 않은 원본이 아니다. 앞 대상에서 추가한 `V38`의 `bookmark (user_id, problem_id)` UNIQUE 인덱스가 이미 적용된 상태이고,
대상 쿼리의 `LEFT JOIN Bookmark ... AND b.userId = :userId`가 실제로 그 인덱스를 탄다(`query-plan-0.txt`의 `Index Scan using ix_bookmark_user_problem`, loops 30, 120버퍼).
그 인덱스가 없었다면 이 대상의 기준선은 더 나빴을 것이다.

### 개선 전 지표

| 지표 | 값 |
|---|---|
| p95 / p99 | 192.63904999999988ms / 253.12869999999998ms |
| med / max | 97.561ms / 496.084ms |
| RPS | 382.23845109833474 |
| 요청당 쿼리 수 | 6 (트랜잭션 제어문 제외) |
| 요청당 DB 시간 합 | 13.2309ms |
| 대상 쿼리 calls / mean_ms / total_ms | 45872 / 4.0971767350671575 / 187945.69119100034 (30.82442904846952%) |

**실행계획**

> 원본: `query-plan-0.txt` (개선 후는 `query-plan-1.txt`)

- EXPLAIN 파라미터: 유저 1500 (1001~2000의 중앙값), 유닛 900002. 이후 모든 사이클에서 동일하게 사용
- 스캔 방식: `problem` Seq Scan(`ix_problem_lesson` 미사용), `lesson` Seq Scan, `unit` Seq Scan, `wrong_answered_note` Index Scan(`ix_wrong_answered_note_user_problem`), `bookmark` Index Scan(`ix_bookmark_user_problem`)
- 실행 구조: `problem` 6,900행 전부 스캔 → 유닛의 `lesson` 2건과 Hash Join → 60행 → 그 60건마다 `wrong_answered_note` 인덱스 탐색(loops 60, 30건 통과) → 그 30건마다 `bookmark` 인덱스 탐색(loops 30)
- actual rows 대 반환 행 수: `problem` 노드가 6,900행을 내보내고 쿼리는 30행을 반환한다
- Rows Removed by Filter: `lesson` 228(230 중 99.1%), `unit` 65(66 중 98.5%), `wrong_answered_note` 총 10(`resolved_at IS NULL`이 극복분을 걸러낸 수, loops 60의 per-loop 표시는 반올림되어 0)
- shared hit / read: 최상단 누적 440 / 0 (3.44MB). 노드별로는 `wrong_answered_note` 223(50.7%), `bookmark` 120(27.3%), `problem` 92(20.9%). read가 전부 0이라 디스크 접근이 없었다
- 플래너 추정 대 실측: 최상단 `rows=2` 대 실측 30(15배 괴리). 유저 필터와 유닛 필터의 상관관계를 플래너가 독립으로 가정한 결과다. `Hash Join`은 `rows=60` 대 실측 60으로 정확하다
- Planning Time 6.753ms / Execution Time 3.617ms. 부하 중 mean 4.097ms가 Execution Time에 가까우므로 요청마다 계획을 다시 세우지는 않는 것으로 보인다

**노드별 자기 몫** (누적 actual time에서 자식 몫을 뺀 값, loops 반영. Execution Time 3.617ms 대비)

| 노드 | 자기 몫 (ms) | 비중 |
|---|---|---|
| Hash Join (`problem` ⋈ `lesson`) | 1.869 | 51.7% |
| Seq Scan `problem` (6,900행) | 0.817 | 22.6% |
| Index Scan `wrong_answered_note` (loops 60) | 0.300 | 8.3% |
| Index Scan `bookmark` (loops 30) | 0.210 | 5.8% |
| Seq Scan `unit` (66행) | 0.036 | 1.0% |
| Seq Scan `lesson` (230행) | 0.033 | 0.9% |
| Hash build | 0.015 | 0.4% |
| 나머지 (조인 노드 자기 몫) | 0.337 | 9.3% |

**위험 신호 판정**

| 지표 | 값 | 기준 | 판정 |
|---|---|---|---|
| 검사 행 / 반환 행 | 6,900 / 30 = 230:1 | 100:1 초과 | 초과 |
| 플래너 추정 대 실측 | 최상단 2 대 30 = 15배 | 10배 이상 | 초과 |
| 단일 쿼리 total_exec_time 점유율 | 30.82% | 30% 이상 | 초과 |
| 1만 행 이상 테이블의 Seq Scan | `problem` 6,900행이 최대 | 1만 행 | 해당 없음 |
| 동일 쿼리의 요청당 호출 횟수 | 1.00 | 1회 초과면 N+1 | 해당 없음 |

- 확정 해석: 비용을 먹는 노드는 `problem` Seq Scan과 그 위의 Hash Join이다. 두 노드 자기 몫의 합이 2.686ms로 Execution Time의 74.3%다. 유닛의 문제 60건을 찾기 위해 6,900행 전부를 훑는다
- **이번 사이클의 기법은 위 위험 신호를 하나도 해소하지 못한다.** `unit` 조인 제거가 없애는 것은 Seq Scan `unit` 노드(자기 몫 0.036ms = 1.0%, 2버퍼)와 Nested Loop 1개다. 74.3%를 만드는 노드는 그대로 남는다. 이 사실을 알고 선택한 기법이다 (근거는 위 설계 결정의 "검토했지만 택하지 않은 안" 참조)

### 적용 내용

JPQL 4곳에서 `JOIN Unit u ON u.id = l.unitId` + `WHERE u.id = :unitId`를 `WHERE l.unitId = :unitId`로 바꿨다. 총 4줄 추가 / 8줄 삭제.

| 파일 | 메서드 | 이 대상의 실행 경로 |
|---|---|---|
| `src/main/java/gravit/code/wrongAnsweredNote/repository/WrongAnsweredNoteRepository.java:48` | `findWrongAnsweredProblemDetailByUnitIdAndUserId` | **포함** (측정 대상 쿼리) |
| `src/main/java/gravit/code/wrongAnsweredNote/repository/WrongAnsweredNoteRepository.java:61` | `countByUnitIdAndUserId` | 미포함 (`LessonFacade`가 호출) |
| `src/main/java/gravit/code/bookmark/repository/BookmarkRepository.java:38` | `findBookmarkedProblemDetailByUnitIdAndUserId` | 미포함 (앞 대상이 측정한 쿼리) |
| `src/main/java/gravit/code/bookmark/repository/BookmarkRepository.java:51` | `countByUnitIdAndUserId` | 미포함 (`LessonFacade`가 호출) |

- 마이그레이션 없음. 스키마 변경이 아니다
- 메서드 시그니처, 반환 타입, 호출부 모두 그대로다
- 남겨둔 `Unit` 조인 4곳(`ProblemSubmissionRepository:38`, `LessonRepository:25`, `LessonSubmissionRepository:27`, `:93`)은 `u.title` 프로젝션이나 `u.chapterId` 경유 Chapter 조인에 쓰여 제거 대상이 아니다
- 테스트: `./gradlew test` 통과
- Phase 8 재측정 전 애플리케이션 재기동 완료 (JPQL 변경이라 기동 시점에 쿼리가 다시 생성된다)

### 개선 후 지표

| 구분 | 지표 | 개선 전 | 개선 후 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 192.63904999999988ms | 204.7070999999999ms | +6.3% |
| | p99 | 253.12869999999998ms | 372.14019999999977ms | +47.0% |
| | med | 97.561ms | 90.641ms | -7.1% |
| | max | 496.084ms | 1048.058ms | +111.3% |
| | RPS | 382.23845109833474 | 377.23077533234846 | -1.3% |
| 하드웨어 독립 | 요청당 쿼리 수 | 6 | 6 | 변화 없음 |
| | 대상 쿼리 mean_ms | 4.0971767350671575 | 4.2596087043843 | +4.0% |
| | 대상 쿼리 total 비중 | 30.82442904846952% (2위) | 30.991447705657233% (2위) | 순위 동일 |
| | 요청당 DB 시간 합 | 13.2309ms | 13.6583ms | +3.2% |
| | 쿼리 전체 shared hit | 440 (3.44MB) | **438 (3.42MB)** | **-2** |
| | 검사 행 / 반환 행 | 6,900 / 30 = 230:1 | 6,900 / 30 = 230:1 | 변화 없음 |
| | 스캔 방식 | `problem`/`lesson`/`unit` Seq Scan + Index Scan 2 | `problem`/`lesson` Seq Scan + Index Scan 2 | `unit` 노드 소멸 |
| | 계획 노드 수 | Nested Loop 3 + Seq Scan 3 + Index Scan 2 | Nested Loop 2 + Seq Scan 2 + Index Scan 2 | -2 |
| | 단건 Execution Time | 3.617ms | 1.742ms | -51.8% |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 사이클 아님 |

- 에러율 0, check 통과율 1로 전후 동일하다. 응답 내용은 달라지지 않았다
- 계획 변화: `Seq Scan on unit`(자기 몫 0.036ms, 2버퍼)과 그 위의 Nested Loop 1개가 사라졌다. 나머지 구조는 동일하다 — `problem` 6,900행 Seq Scan → `lesson` 2건과 Hash Join → 60행 → `wrong_answered_note` 인덱스 탐색(loops 60) → `bookmark` 인덱스 탐색(loops 30)
- 개선 후에도 비용이 가장 큰 노드는 Hash Join 0.824ms(47.3%)와 Seq Scan `problem` 0.578ms(33.2%)로 둘이 합쳐 80.5%다. 개선 전(74.3%)과 같은 노드다

### 측정 편차 조사 (`k6-test-summary-1-rerun.json`)

부하 지표가 전반적으로 악화해 보여, **코드를 그대로 둔 채 측정만 한 번 더 돌렸다.**

| 측정 | 코드 | 요청 | RPS | med | p95 | p99 | max | 요청당 DB |
|---|---|---|---|---|---|---|---|---|
| `-0` | 변경 전 | 45,872 | 382.23845109833474 | 97.561 | 192.639 | 253.129 | 496.084 | 13.2309ms |
| `-1` | 변경 후 | 45,275 | 377.23077533234846 | 90.641 | 204.707 | 372.140 | 1048.058 | 13.6583ms |
| `-1` 재실행 | 변경 후 (동일) | 38,750 | 322.9095518928733 | 104.626 | 253.289 | 480.510 | 1971.246 | 14.0404ms |

| 구간 | 코드 변경 | RPS 변화 | 요청당 DB 변화 | p99 변화 |
|---|---|---|---|---|
| `-0` → `-1` | 있음 | -1.3% | +3.2% | +47.0% |
| `-1` → 재실행 | **없음** | **-14.4%** | +2.8% | +29.1% |

**코드 변경이 없는 구간의 낙폭이 있는 구간의 11배다.** 세 측정이 단조 악화(RPS 382 → 377 → 323, max 496 → 1048 → 1971ms)이므로,
같은 머신에서 2분짜리 380 RPS 부하를 연달아 돌린 데 따른 환경 드리프트(발열 스로틀링, 누적 배경 부하)로 본다.

검토했다가 기각한 가설:

- **JVM 워밍업 차이** - `-0`은 앞 대상의 측정 부하까지 처리한 JVM에서, `-1`은 재기동 직후 JVM에서 쟀다. 그러나 이미 45,275건을 처리해 데워진 상태의 재실행이 더 나빠졌으므로 기각한다
- **dead tuple 누적** - 전 테이블 `n_dead_tup` 0이다. `update users`가 `last_accessed_at < startOfToday` 가드 때문에 하루 첫 요청 이후로는 0행을 갱신한다(세 측정 모두 `rows_per_call` 0)

**결론: 이 환경의 부하 지표는 1% 수준의 변화를 판정할 해상도가 없다.** 측정 간 편차(-14.4%)가 이 기법의 예상 효과(-1.0%)보다 훨씬 크다.
따라서 `-0` → `-1`의 부하 지표 악화는 기법에 귀속되지 않으며, 개선 여부는 하드웨어 독립 증거로만 판정한다.

### 판정

- **개선 여부 (하드웨어 독립 증거 기준): 사실상 없음.** 확정된 변화는 `unit` Seq Scan 노드 소멸, 버퍼 440 → 438(-2), 계획 노드 -2뿐이다.
  요청당 쿼리 수, 검사 행/반환 행 비, 스캔 방식은 그대로다
- 예상 효과 대조: Phase 5에서 예상한 "Seq Scan `unit` 노드와 Nested Loop 1개 소멸, 버퍼 -2"는 정확히 그대로 나왔다.
  함께 예상한 "Execution Time -1.0%"는 측정 해상도 밖이라 확인도 반증도 되지 않았다
- 남은 위험 신호: 5개 중 3개가 그대로다 — 검사 행/반환 행 230:1, 플래너 추정 대 실측 15배 괴리, 단일 쿼리 점유율 30.99%.
  이번 기법이 겨냥한 항목이 아니므로 예상된 결과다. 이 셋을 해소하려면 `problem` 6,900행 스캔 경로를 없애야 하고, 그 수단은 Phase 5에서 배제한 반정규화나 캐싱이다
- 되짚어보면 **이 대상은 개선 여지가 약했다.** 기준선 자체가 p95 192.6ms / 에러 0이었고, 요청당 DB 시간 13.2309ms가 med 응답 97.561ms의 13.6%,
  대상 쿼리는 4.2%에 불과했다. 남은 74.3% 노드를 통째로 없애도 응답시간 상한이 2.7%다. 병목은 DB가 아니라 DB 밖 86%에 있다
- 다음 사이클 진행 여부: 진행하지 않는다 (호출자가 종료를 선택). 종료 조건표의 "하드웨어 독립 증거에 변화가 없음"에도 해당한다

---

## 최종 요약

> 하드웨어 의존 증거와 독립 증거를 모두 남긴다.

| 구분 | 지표 | 최초 | 최종 | 변화 |
|---|---|---|---|---|
| 하드웨어 의존 | p95 | 192.63904999999988ms | 204.7070999999999ms | +6.3% (환경 드리프트, 기법에 귀속 불가) |
| | p99 | 253.12869999999998ms | 372.14019999999977ms | +47.0% (동일) |
| | RPS | 382.23845109833474 | 377.23077533234846 | -1.3% (동일) |
| 하드웨어 독립 | 요청당 쿼리 수 | 6 | 6 | 변화 없음 |
| | 요청당 DB 시간 합 | 13.2309ms | 13.6583ms | +3.2% (환경 드리프트) |
| | 검사 행 / 반환 행 | 6,900 / 30 = 230:1 | 6,900 / 30 = 230:1 | 변화 없음 |
| | 스캔 방식 | `problem`/`lesson`/`unit` Seq Scan + Index Scan 2 | `problem`/`lesson` Seq Scan + Index Scan 2 | `unit` 노드 소멸 |
| | 쿼리 전체 shared hit | 440 (3.44MB) | 438 (3.42MB) | -2 |
| | 계획 노드 수 | 8 | 6 | -2 |
| | 캐시 hit / miss, 적중률 | - | - | 캐싱 기법을 쓰지 않았다 |

적용한 기법: 사이클 1 - 불필요한 `Unit` 조인 제거 (`WHERE l.unitId = :unitId`, JPQL 4곳)

**총평.** 이 대상은 개선 여지가 약했다. 기준선이 이미 p95 192.6ms / 에러 0이었고, DB가 응답시간의 13.6%뿐이라 쿼리 튜닝의 상한 자체가 낮았다.
비용의 74.3%를 차지하는 `problem` 6,900행 스캔은 유저 수가 아니라 콘텐츠 양에만 비례해 커지므로, 반정규화나 캐싱으로 걷어낼 근거도 부족했다.
그래서 마이그레이션도 정합성 책임도 없는 조인 제거만 적용하고 닫는다. 성능 수치보다는 쿼리가 정직해진 것이 이 사이클의 결과다.

남겨두는 후보 (근거가 생기면 다시 꺼낸다):

- `problem` 6,900행 Seq Scan + Hash Join 경로 제거 - 반정규화(`wrong_answered_note.unit_id`) 또는 유닛→문제 목록 캐싱. `problem`이 수만 행대로 커지면 근거가 생긴다
- DB 밖 86% - 요청당 14.5KB 응답의 직렬화 비용. 이 이슈의 범위(쿼리 성능) 밖이다
- `LastAccessInterceptor`의 `UPDATE users` - 읽기 엔드포인트에 섞인 쓰기. 비중 0.38%로 이번 병목과 무관하고 별도 이슈 사안이다
- 측정 환경 - 같은 머신에서 부하를 연달아 돌리면 RPS가 단조 하락한다. 1% 수준의 변화를 재려면 DB를 별도 머신에 두거나 측정 간 냉각 시간을 둬야 한다
