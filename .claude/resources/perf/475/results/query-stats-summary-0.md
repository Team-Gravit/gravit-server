# query-stats-summary-0 — results

상태: 0 = 원본 (아무 기법도 적용하지 않음)
측정: VU 50 / 유지 1m (총 2m) / Redis cold / 요청 3610건 / 첫 풀이만
직전 상태 대비: -

전체 쿼리 실행 시간 합계 약 288,660 ms (아래 상위 20건이 285,038.942236 ms, 98.7%)

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 9.0000000000000000 | 32490 | 4.7988053265312525 | 155913.18505900068 | 54.01255759387924% | 0.000000000000000000000000 | WrongAnsweredNoteService.saveWrongAnsweredNote → WrongAnsweredNoteRepository.findByProblemIdAndUserId | 오답 문제별 기존 오답노트 조회 |
| 2 | 30.0000000000000000 | 108300 | 0.736195981643578 | 79730.02481200015 | 27.620643856964% | 1.00000000000000000000 | ProblemSubmissionCommandService.saveProblemSubmissions → ProblemSubmissionRepository.saveAll | 문제 풀이 저장 |
| 3 | 9.0000000000000000 | 32490 | 0.39034234493690123 | 12682.22278699999 | 4.393466071788779% | 1.00000000000000000000 | WrongAnsweredNoteService.saveWrongAnsweredNote → WrongAnsweredNoteRepository.save | 오답노트 신규 저장 |
| 4 | 1.00000000000000000000 | 3610 | 2.387485414681436 | 8618.822346999985 | 2.9857939098132475% | 0.00000000000000000000 | LessonSubmissionQueryService.checkFirstLessonSubmission → LessonSubmissionRepository.existsByLessonIdAndUserId | 첫 풀이 여부 확인 |
| 5 | 0.70304709141274238227 | 2538 | 2.251290341213554 | 5713.77488600001 | 1.9794066485894053% | 1.00000000000000000000 | MissionService.handleLessonMission → LessonSubmissionQueryService.getLessonSubmissionTryCount (리스너) | 레슨 제출 횟수 집계 |
| 6 | 1.1847645429362881 | 4277 | 0.6173186389992971 | 2640.271819000002 | 0.9146617948524893% | 1.00000000000000000000 | UserService.updateUserLevelAndXp / MissionService.awardMissionXp (dirty checking) | 유저 레벨·XP 갱신 |
| 7 | 1.00000000000000000000 | 3610 | 0.6089050742382263 | 2198.147317999996 | 0.7614978718341049% | 1.00000000000000000000 | UserLeagueService.getUserLeagueName → UserLeagueRepository.findUserLeagueNameByUserId | 리그명 조회 |
| 8 | 1.00000000000000000000 | 3610 | 0.6035694711911342 | 2178.8857909999997 | 0.7548251562710196% | 1.00000000000000000000 | LessonSubmissionCommandService.saveLessonSubmission → LessonSubmissionRepository.save | 레슨 풀이 저장 |
| 9 | 1.00000000000000000000 | 3610 | 0.5956083099723 | 2150.145999000003 | 0.7448689125444322% | 1.00000000000000000000 | UserLeaguePointService.addLeaguePoints → UserLeagueRepository.findByUserId (리스너) | 리그 포인트 반영 대상 조회 |
| 10 | 1.00000000000000000000 | 3610 | 0.44709964376731276 | 1614.0297139999973 | 0.559143685331471% | 1.00000000000000000000 | LessonQueryService.getLearningIdsByLessonId → LessonRepository.findLearningIdsByLessonId | 레슨에서 챕터·유닛·레슨 아이디 추출 |
| 11 | 1.00000000000000000000 | 3610 | 0.40001246731301954 | 1444.0450070000004 | 0.5002563707439226% | 1.00000000000000000000 | LearningProgressRateService.getPlanetConquestRate → LessonSubmissionRepository.countDistinctLessonByUserId | 유저가 푼 서로 다른 레슨 수 집계 |
| 12 | 0.97922437673130193906 | 3535 | 0.39958569561527474 | 1412.5354340000004 | 0.48934059972829613% | 1.00000000000000000000 | UserLeaguePointService.addLeaguePoints (dirty checking, 리스너) | 리그 포인트 갱신 |
| 13 | 1.00000000000000000000 | 3610 | 0.36845120609418236 | 1330.108853999996 | 0.4607857959903571% | 1.00000000000000000000 | DailyLearningRecordService.handleDailyLearningRecord (dirty checking, 리스너) | 일일 학습 기록 갱신 |
| 14 | 3.1847645429362881 | 11497 | 0.11477065512742432 | 1319.5182220000033 | 0.4571169137169387% | 1.00000000000000000000 | AuthTokenProvider.parseUser ×2 (JwtAuthFilter:78, :81) + UserService.updateUserLevelAndXp + MissionService.awardMissionXp → UserRepository.findById | 유저 단건 조회 |
| 15 | 1.00000000000000000000 | 3610 | 0.3617516650969529 | 1305.9235109999981 | 0.45240733697022506% | 0.10581717451523545706 | LastAccessInterceptor.preHandle → UserAccessService.updateLastAccessed → UserRepository.updateLastAccessedAt | 마지막 접속 시각 갱신 (하루 1회 조건부 UPDATE) |
| 16 | 1.00000000000000000000 | 3610 | 0.33333269916897545 | 1203.3310440000007 | 0.4168665228277997% | 30.0000000000000000 | ProblemSubmissionCommandService.validateProblemSubmissions → ProblemRepository.findProblemTypesByIds | 제출된 문제 30건의 유형 조회 |
| 17 | 1.00000000000000000000 | 3610 | 0.2871433337950136 | 1036.587434999997 | 0.35910201252601964% | 1.00000000000000000000 | UnitQueryService.getUnitSummaryByLessonId → UnitRepository.findUnitSummaryByLessonId | 응답용 유닛 요약 조회 |
| 18 | 1.00000000000000000000 | 3610 | 0.2742501191135732 | 990.0429300000005 | 0.34297773313271773% | 1.00000000000000000000 | DailyLearningRecordService.handleDailyLearningRecord → DailyLearningRecordRepository.findByUserIdAndSolvedDate (리스너) | 오늘자 학습 기록 조회 |
| 19 | 0.16204986149584487535 | 585 | 1.3556970854700843 | 793.0827949999995 | 0.2747453983795022% | 1.00000000000000000000 | SocialFeedService.createFeed ← SocialFeedLevelUpRetryTarget ← RetryQueueSweeper (@Scheduled, 스케줄러 스레드) | 소셜 피드 생성 |
| 20 | 1.00000000000000000000 | 3610 | 0.2117053939058174 | 764.256472 | 0.26475917796672543% | 1.00000000000000000000 | MissionService.findTodayMission → UserMissionRepository.findAssignedMission (리스너) | 오늘자 미션 배정 조회 |

## 쿼리 원문

[1] select wan1_0.id,wan1_0.created_at,wan1_0.problem_id,wan1_0.resolved_at,wan1_0.updated_at,wan1_0.user_id,wan1_0.wrong_count from wrong_answered_note wan1_0 where wan1_0.problem_id=$1 and wan1_0.user_id=$2

[2] insert into problem_submission (created_at,is_correct,problem_id,selected_option_id,submitted_content,updated_at,user_id) values ($1,$2,$3,$4,$5,$6,$7)
RETURNING *

[3] insert into wrong_answered_note (created_at,problem_id,resolved_at,updated_at,user_id,wrong_count) values ($1,$2,$3,$4,$5,$6)
RETURNING *

[4] select ls1_0.id from lesson_submission ls1_0 where ls1_0.lesson_id=$1 and ls1_0.user_id=$2 fetch first $3 rows only

[5] select count(ls1_0.id) from lesson_submission ls1_0 where ls1_0.lesson_id=$1 and ls1_0.user_id=$2

[6] update users set created_at=$1,deleted_at=$2,email=$3,handle=$4,is_onboarded=$5,last_accessed_at=$6,level=$7,xp=$8,nickname=$9,profile_img_number=$10,provider_id=$11,role=$12,status=$13,updated_at=$14 where id=$15

[7] select l1_0.name from user_league ul1_0 join league l1_0 on ul1_0.league_id=l1_0.id where ul1_0.user_id=$1

[8] insert into lesson_submission (accuracy,created_at,learning_time,lesson_id,updated_at,user_id) values ($1,$2,$3,$4,$5,$6)
RETURNING *

[9] select ul1_0.id,ul1_0.created_at,ul1_0.league_id,ul1_0.league_point,ul1_0.season_id,ul1_0.updated_at,ul1_0.user_id from user_league ul1_0 left join users u1_0 on u1_0.id=ul1_0.user_id and (u1_0.deleted_at IS NULL) where u1_0.id=$1

[10] select c1_0.id,u1_0.id,l1_0.id from lesson l1_0 join unit u1_0 on u1_0.id=l1_0.unit_id join chapter c1_0 on c1_0.id=u1_0.chapter_id where l1_0.id=$1

[11] select count(distinct ls1_0.lesson_id) from lesson_submission ls1_0 where ls1_0.user_id=$1

[12] update user_league set created_at=$1,league_id=$2,league_point=$3,season_id=$4,updated_at=$5,user_id=$6 where id=$7

[13] update daily_learning_record set solved_date=$1,solved_lesson_count=$2,user_id=$3 where id=$4

[14] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[15] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[16] select p1_0.id,p1_0.problem_type from problem p1_0 where p1_0.id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30)

[17] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 join lesson l1_0 on l1_0.unit_id=u1_0.id where l1_0.id=$1

[18] select dlr1_0.id,dlr1_0.solved_date,dlr1_0.solved_lesson_count,dlr1_0.user_id from daily_learning_record dlr1_0 where dlr1_0.user_id=$1 and dlr1_0.solved_date=$2

[19] insert into social_feed (actor_id,created_at,event_type,event_value,updated_at) values ($1,$2,$3,$4,$5)
RETURNING *

[20] select um1_0.id,um1_0.assigned_date,um1_0.completed_at,um1_0.created_at,um1_0.mission_id,um1_0.progress_count,um1_0.updated_at,um1_0.user_id,m1_0.id,m1_0.award_xp,m1_0.code,m1_0.created_at,m1_0.description,m1_0.max_progress_per_event,m1_0.status,m1_0.target_type,m1_0.target_value,m1_0.title,m1_0.updated_at,m1_0.weight from user_mission um1_0 join mission m1_0 on m1_0.id=um1_0.mission_id where um1_0.user_id=$1 and um1_0.assigned_date=$2
