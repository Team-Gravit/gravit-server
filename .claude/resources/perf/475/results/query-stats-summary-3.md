# query-stats-summary-3 — results

상태: 3 = 사이클 3 적용 후 (`problem_submission` 다중행 INSERT, `jsonb_to_recordset`)
측정: VU 50 / 유지 1m (총 2m) / Redis cold / 요청 17300건 / 첫 풀이만 / 되돌리기 후 VACUUM ANALYZE
직전 상태 대비: `problem_submission` 요청당 호출 수 30.00 → 1.00, 요청당 대상 시간 13.04 → 8.96 ms (-31.3%), 비중 73.16% → 56.97%. 요청당 DB 실행 시간 17.83 → 15.73 ms. 처리량이 82.29 → 144.15 RPS로 75% 늘어 다른 쿼리들의 호출당 mean은 오히려 올랐다(경합 증가)

전체 쿼리 실행 시간 합계 약 272,188 ms (아래 상위 20건이 267,988.754277 ms, 98.5%)

`problem_submission` 다중행 INSERT는 같은 원문으로 항목 2개(#1, #4)에, 오답노트 UPSERT는 항목 2개(#2, #5)에 나뉘어 집계되었다.
각 쌍의 calls 합이 17300으로 요청 수와 정확히 일치하고 per_req 합은 1.00이다. 분리 원인은 확인하지 못했다(사이클 2에서도 같은 현상).

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 0.86075144508670520231 | 14891 | 9.466271326035853 | 140962.24631599983 | 51.78853858964279% | 30.0000000000000000 | ProblemSubmissionCommandService.saveProblemSubmissions → ProblemSubmissionRepository.insertAll | 문제 풀이 일괄 저장 (한 문장이 30행 처리) |
| 2 | 0.72895953757225433526 | 12611 | 3.3641874411228283 | 42425.767820000336 | 15.586928921491827% | 9.0000000000000000 | WrongAnsweredNoteService.saveWrongAnsweredNotes → WrongAnsweredNoteRepository.upsertAll | 오답노트 일괄 저장 (한 문장이 9행 처리) |
| 3 | 1.00000000000000000000 | 17300 | 0.9757195038728315 | 16879.94741700009 | 6.2015740458388695% | 0.000000000000000000000000 | LessonSubmissionQueryService.checkFirstLessonSubmission → LessonSubmissionRepository.existsByLessonIdAndUserId | 첫 풀이 여부 확인 |
| 4 | 0.13924855491329479769 | 2409 | 5.853295064342041 | 14100.587809999975 | 5.18045686004327% | 30.0000000000000000 | ProblemSubmissionRepository.insertAll (#1과 같은 문장) | 문제 풀이 일괄 저장 |
| 5 | 0.27104046242774566474 | 4689 | 1.84722177713798 | 8661.622912999983 | 3.182219382864069% | 9.0000000000000000 | WrongAnsweredNoteRepository.upsertAll (#2와 같은 문장) | 오답노트 일괄 저장 |
| 6 | 1.00000000000000000000 | 17300 | 0.3941716914450872 | 6819.170261999998 | 2.505315227960061% | 1.00000000000000000000 | UserLeaguePointService.addLeaguePoints → UserLeagueRepository.findByUserId (리스너) | 리그 포인트 반영 대상 조회 |
| 7 | 1.00000000000000000000 | 17300 | 0.38963190612716747 | 6740.631975999961 | 2.4764608136641986% | 1.00000000000000000000 | UserLeagueService.getUserLeagueName → UserLeagueRepository.findUserLeagueNameByUserId | 리그명 조회 |
| 8 | 0.41023121387283236994 | 7097 | 0.86341154346907 | 6127.631724000014 | 2.251248829350377% | 1.00000000000000000000 | MissionService.handleLessonMission → LessonSubmissionQueryService.getLessonSubmissionTryCount (리스너) | 레슨 제출 횟수 집계 |
| 9 | 1.03855491329479768786 | 17967 | 0.2131325390994601 | 3829.3523299999924 | 1.4068771326967238% | 1.00000000000000000000 | UserService.updateUserLevelAndXp / MissionService.awardMissionXp (dirty checking) | 유저 레벨·XP 갱신 |
| 10 | 1.00000000000000000000 | 17300 | 0.21194159895953632 | 3666.589661999996 | 1.3470792723974852% | 1.00000000000000000000 | LearningProgressRateService.getPlanetConquestRate → LessonSubmissionRepository.countDistinctLessonByUserId | 유저가 푼 서로 다른 레슨 수 집계 |
| 11 | 1.00000000000000000000 | 17300 | 0.1705623476878612 | 2950.7286149999964 | 1.0840769549239617% | 1.00000000000000000000 | LessonSubmissionCommandService.saveLessonSubmission → LessonSubmissionRepository.save | 레슨 풀이 저장 |
| 12 | 1.00000000000000000000 | 17300 | 0.11807565606936397 | 2042.708850000004 | 0.7504768749816848% | 1.00000000000000000000 | LessonQueryService.getLearningIdsByLessonId → LessonRepository.findLearningIdsByLessonId | 레슨에서 챕터·유닛·레슨 아이디 추출 |
| 13 | 1.00000000000000000000 | 17300 | 0.11482262930635846 | 1986.431486999992 | 0.7298009673424445% | 1.00000000000000000000 | UnitQueryService.getUnitSummaryByLessonId → UnitRepository.findUnitSummaryByLessonId | 응답용 유닛 요약 조회 |
| 14 | 1.00000000000000000000 | 17300 | 0.10945746838150269 | 1893.6142029999971 | 0.6957005495366453% | 30.0000000000000000 | ProblemSubmissionCommandService.validateProblemSubmissions → ProblemRepository.findProblemTypesByIds | 제출된 문제 30건의 유형 조회 |
| 15 | 1.00000000000000000000 | 17300 | 0.10595918578034717 | 1833.093914 | 0.6734658207050224% | 1.00000000000000000000 | DailyLearningRecordService.handleDailyLearningRecord (dirty checking, 리스너) | 일일 학습 기록 갱신 |
| 16 | 3.0385549132947977 | 52567 | 0.034630937831720006 | 1820.444508999993 | 0.6688185182102088% | 1.00000000000000000000 | AuthTokenProvider.parseUser ×2 (JwtAuthFilter:78, :81) + UserService.updateUserLevelAndXp + MissionService.awardMissionXp → UserRepository.findById | 유저 단건 조회 |
| 17 | 0.05161849710982658960 | 893 | 1.8143101332586795 | 1620.1789490000017 | 0.5952423589669321% | 1.00000000000000000000 | SocialFeedService.createFeed ← SocialFeedLevelUpRetryTarget ← RetryQueueSweeper (@Scheduled, 스케줄러 스레드) | 소셜 피드 생성 |
| 18 | 0.80098265895953757225 | 13857 | 0.11665375968824498 | 1616.471147999998 | 0.5938801389385926% | 1.00000000000000000000 | UserLeaguePointService.addLeaguePoints (dirty checking, 리스너) | 리그 포인트 갱신 |
| 19 | 1.00000000000000000000 | 17300 | 0.059361780404624136 | 1026.958800999998 | 0.37729744584472463% | 1.00000000000000000000 | MissionService.findTodayMission → UserMissionRepository.findAssignedMission (리스너) | 오늘자 미션 배정 조회 |
| 20 | 1.00000000000000000000 | 17300 | 0.05691188271676273 | 984.5755709999977 | 0.3617261450193378% | 1.00000000000000000000 | DailyLearningRecordService.handleDailyLearningRecord → DailyLearningRecordRepository.findByUserIdAndSolvedDate (리스너) | 오늘자 학습 기록 조회 |

직전 상태(2)에서 상위 20건에 있었으나 이번에 빠진 쿼리:
개별 `insert into problem_submission ... values (...)` (다중행으로 대체되어 **사라짐**),
`learning` SELECT·UPDATE, `daily_learning_record` INSERT, `BEGIN READ ONLY` (순위 밖).

## F / R 분리

문장 하나의 비용을 고정비 `F`와 행당 작업 `R`로 나누면:

```
상태 2 (개별 30회) :  30 × (F + R) = 13.04 ms   →  F + R  = 0.43476 ms
상태 3 (다중행 1회):  F + 30R      =  8.9631 ms
────────────────────────────────────────────────────────────────
                      29R = 8.5283  →  R = 0.29408 ms
                                        F = 0.14068 ms
```

검산: `30 × 0.43476 = 13.043` / `0.14068 + 30 × 0.29408 = 8.963` / 절감 `29 × 0.14068 = 4.08 ms` = 실측 `13.04 − 8.96 = 4.08 ms`

**절감 공식: 문제 N개당 `(N − 1) × 0.1407 ms`** (서버측 실행 시간 기준)

| N | 절감 문장 수 | DB 실행 시간 절감 |
|---|---|---|
| 7 (현재 실제) | 6 | 0.84 ms |
| 8 | 7 | 0.98 ms |
| 30 (측정 조건) | 29 | 4.08 ms |
| 50 | 49 | 6.89 ms |

두 가지 한계:
1. `R`이 두 상태에서 동일하다고 가정했다. 다중행 문장은 페이지 지역성이 좋아 `R`이 더 작을 수 있고, 그 차이는 `F`에 흡수된다.
2. `F`는 서버측 실행 시간만 반영한다. 네트워크 왕복, 드라이버·datasource-proxy 리스너 오버헤드가 빠져 있어 **실제 절감은 이보다 크다.**

## 쿼리 원문

[1] INSERT INTO problem_submission (user_id, problem_id, is_correct, selected_option_id, submitted_content, created_at, updated_at)
    SELECT $1, t.problem_id, t.is_correct, t.selected_option_id, t.submitted_content, $2, $3
    FROM jsonb_to_recordset(CAST($4 AS jsonb))
         AS t(problem_id bigint, is_correct boolean, selected_option_id bigint, submitted_content text)

[2] INSERT INTO wrong_answered_note (user_id, problem_id, wrong_count, created_at, updated_at)
    SELECT $1, p.problem_id, $5, $2, $3
    FROM unnest(CAST($4 AS BIGINT[])) AS p(problem_id)
    ON CONFLICT (user_id, problem_id)
    DO UPDATE SET wrong_count = wrong_answered_note.wrong_count + $6,
                  resolved_at = $7,
                  updated_at  = EXCLUDED.updated_at

[3] select ls1_0.id from lesson_submission ls1_0 where ls1_0.lesson_id=$1 and ls1_0.user_id=$2 fetch first $3 rows only

[4] (= [1])

[5] (= [2])

[6] select ul1_0.id,ul1_0.created_at,ul1_0.league_id,ul1_0.league_point,ul1_0.season_id,ul1_0.updated_at,ul1_0.user_id from user_league ul1_0 left join users u1_0 on u1_0.id=ul1_0.user_id and (u1_0.deleted_at IS NULL) where u1_0.id=$1

[7] select l1_0.name from user_league ul1_0 join league l1_0 on ul1_0.league_id=l1_0.id where ul1_0.user_id=$1

[8] select count(ls1_0.id) from lesson_submission ls1_0 where ls1_0.lesson_id=$1 and ls1_0.user_id=$2

[9] update users set created_at=$1,deleted_at=$2,email=$3,handle=$4,is_onboarded=$5,last_accessed_at=$6,level=$7,xp=$8,nickname=$9,profile_img_number=$10,provider_id=$11,role=$12,status=$13,updated_at=$14 where id=$15

[10] select count(distinct ls1_0.lesson_id) from lesson_submission ls1_0 where ls1_0.user_id=$1

[11] insert into lesson_submission (accuracy,created_at,learning_time,lesson_id,updated_at,user_id) values ($1,$2,$3,$4,$5,$6)
RETURNING *

[12] select c1_0.id,u1_0.id,l1_0.id from lesson l1_0 join unit u1_0 on u1_0.id=l1_0.unit_id join chapter c1_0 on c1_0.id=u1_0.chapter_id where l1_0.id=$1

[13] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 join lesson l1_0 on l1_0.unit_id=u1_0.id where l1_0.id=$1

[14] select p1_0.id,p1_0.problem_type from problem p1_0 where p1_0.id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30)

[15] update daily_learning_record set solved_date=$1,solved_lesson_count=$2,user_id=$3 where id=$4

[16] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[17] insert into social_feed (actor_id,created_at,event_type,event_value,updated_at) values ($1,$2,$3,$4,$5)
RETURNING *

[18] update user_league set created_at=$1,league_id=$2,league_point=$3,season_id=$4,updated_at=$5,user_id=$6 where id=$7

[19] select um1_0.id,um1_0.assigned_date,um1_0.completed_at,um1_0.created_at,um1_0.mission_id,um1_0.progress_count,um1_0.updated_at,um1_0.user_id,m1_0.id,m1_0.award_xp,m1_0.code,m1_0.created_at,m1_0.description,m1_0.max_progress_per_event,m1_0.status,m1_0.target_type,m1_0.target_value,m1_0.title,m1_0.updated_at,m1_0.weight from user_mission um1_0 join mission m1_0 on m1_0.id=um1_0.mission_id where um1_0.user_id=$1 and um1_0.assigned_date=$2

[20] select dlr1_0.id,dlr1_0.solved_date,dlr1_0.solved_lesson_count,dlr1_0.user_id from daily_learning_record dlr1_0 where dlr1_0.user_id=$1 and dlr1_0.solved_date=$2
