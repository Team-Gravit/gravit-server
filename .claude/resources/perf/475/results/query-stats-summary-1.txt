# query-stats-summary-1 — results

상태: 1 = 사이클 1 적용 후 (`wrong_answered_note (user_id, problem_id)` 유니크 인덱스)
측정: VU 50 / 유지 1m (총 2m) / Redis cold / 요청 6270건 / 첫 풀이만
직전 상태 대비: 대상 쿼리 mean_ms 4.7988053265312525 → 0.16060131036682634, total_ms 155913.18505900068 → 9062.731943999976, 비중 54.01% → 5.86%. 요청당 호출 수는 9.00으로 동일(인덱스 기법이라 호출 수는 바뀌지 않는다). 요청당 DB 실행 시간 79.96 ms → 24.67 ms. `BEGIN READ ONLY`는 0차에서 상위 20건 밖이었다가 이번에 진입했다(호출 수 변화가 아니라 다른 쿼리가 줄어 순위가 올라온 것)

전체 쿼리 실행 시간 합계 약 154,679 ms (아래 상위 20건이 152,537.947339 ms, 98.6%) — 0차의 288,660 ms 대비 감소

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 30.0000000000000000 | 188100 | 0.5107715335619484 | 96076.1254630008 | 62.113388640456705% | 1.00000000000000000000 | ProblemSubmissionCommandService.saveProblemSubmissions → ProblemSubmissionRepository.saveAll | 문제 풀이 저장 |
| 2 | 9.0000000000000000 | 56430 | 0.33039451765018535 | 18644.16263100004 | 12.053484815238043% | 1.00000000000000000000 | WrongAnsweredNoteService.saveWrongAnsweredNote → WrongAnsweredNoteRepository.save | 오답노트 신규 저장 |
| 3 | 9.0000000000000000 | 56430 | 0.16060131036682634 | 9062.731943999976 | 5.859072570518398% | 0.000000000000000000000000 | WrongAnsweredNoteService.saveWrongAnsweredNote → WrongAnsweredNoteRepository.findByProblemIdAndUserId | 오답 문제별 기존 오답노트 조회 |
| 4 | 1.00000000000000000000 | 6270 | 1.2288744425837328 | 7705.042754999997 | 4.981324057629229% | 0.00000000000000000000 | LessonSubmissionQueryService.checkFirstLessonSubmission → LessonSubmissionRepository.existsByLessonIdAndUserId | 첫 풀이 여부 확인 |
| 5 | 0.54593301435406698565 | 3423 | 1.095045941279576 | 3748.3422569999984 | 2.423310039247452% | 1.00000000000000000000 | MissionService.handleLessonMission → LessonSubmissionQueryService.getLessonSubmissionTryCount (리스너) | 레슨 제출 횟수 집계 |
| 6 | 1.00000000000000000000 | 6270 | 0.3703657180223277 | 2322.1930519999883 | 1.5013020023646826% | 1.00000000000000000000 | UserLeaguePointService.addLeaguePoints → UserLeagueRepository.findByUserId (리스너) | 리그 포인트 반영 대상 조회 |
| 7 | 1.00000000000000000000 | 6270 | 0.33515817368421036 | 2101.4417490000005 | 1.3585858862635412% | 1.00000000000000000000 | UserLeagueService.getUserLeagueName → UserLeagueRepository.findUserLeagueNameByUserId | 리그명 조회 |
| 8 | 1.1063795853269537 | 6937 | 0.25634916275046826 | 1778.294141999999 | 1.1496703746825254% | 1.00000000000000000000 | UserService.updateUserLevelAndXp / MissionService.awardMissionXp (dirty checking) | 유저 레벨·XP 갱신 |
| 9 | 1.00000000000000000000 | 6270 | 0.25608167208931515 | 1605.6320840000046 | 1.0380440423306363% | 1.00000000000000000000 | LearningProgressRateService.getPlanetConquestRate → LessonSubmissionRepository.countDistinctLessonByUserId | 유저가 푼 서로 다른 레슨 수 집계 |
| 10 | 1.00000000000000000000 | 6270 | 0.2055060799043063 | 1288.5231209999988 | 0.8330325250023606% | 1.00000000000000000000 | LessonSubmissionCommandService.saveLessonSubmission → LessonSubmissionRepository.save | 레슨 풀이 저장 |
| 11 | 1.00000000000000000000 | 6270 | 0.17420753843700176 | 1092.281266000004 | 0.7061618113011411% | 1.00000000000000000000 | DailyLearningRecordService.handleDailyLearningRecord (dirty checking, 리스너) | 일일 학습 기록 갱신 |
| 12 | 3.1063795853269537 | 19477 | 0.0538701033013299 | 1049.2280019999996 | 0.678327798364157% | 1.00000000000000000000 | AuthTokenProvider.parseUser ×2 (JwtAuthFilter:78, :81) + UserService.updateUserLevelAndXp + MissionService.awardMissionXp → UserRepository.findById | 유저 단건 조회 |
| 13 | 1.00000000000000000000 | 6270 | 0.16704819952153113 | 1047.3922110000037 | 0.6771409561669318% | 1.00000000000000000000 | LessonQueryService.getLearningIdsByLessonId → LessonRepository.findLearningIdsByLessonId | 레슨에서 챕터·유닛·레슨 아이디 추출 |
| 14 | 0.94816586921850079745 | 5945 | 0.15983007653490336 | 950.1898050000002 | 0.6142994251250626% | 1.00000000000000000000 | UserLeaguePointService.addLeaguePoints (dirty checking, 리스너) | 리그 포인트 갱신 |
| 15 | 1.00000000000000000000 | 6270 | 0.14588173237639546 | 914.6784620000018 | 0.5913412777364807% | 1.00000000000000000000 | UnitQueryService.getUnitSummaryByLessonId → UnitRepository.findUnitSummaryByLessonId | 응답용 유닛 요약 조회 |
| 16 | 1.00000000000000000000 | 6270 | 0.13972068245614042 | 876.048679000001 | 0.5663670532555031% | 30.0000000000000000 | ProblemSubmissionCommandService.validateProblemSubmissions → ProblemRepository.findProblemTypesByIds | 제출된 문제 30건의 유형 조회 |
| 17 | 1.00000000000000000000 | 6270 | 0.11272424465709738 | 706.7810139999973 | 0.45693520210891664% | 1.00000000000000000000 | DailyLearningRecordService.handleDailyLearningRecord → DailyLearningRecordRepository.findByUserIdAndSolvedDate (리스너) | 오늘자 학습 기록 조회 |
| 18 | 0.08070175438596491228 | 506 | 1.1324407845849795 | 573.015037 | 0.370455256375979% | 1.00000000000000000000 | SocialFeedService.createFeed ← SocialFeedLevelUpRetryTarget ← RetryQueueSweeper (@Scheduled, 스케줄러 스레드) | 소셜 피드 생성 |
| 19 | 2.0000000000000000 | 12540 | 0.040257127432216946 | 504.8243780000006 | 0.32636987216940055% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 20 | 1.00000000000000000000 | 6270 | 0.07831248596491222 | 491.0192869999992 | 0.3174448559037293% | 1.00000000000000000000 | MissionService.findTodayMission → UserMissionRepository.findAssignedMission (리스너) | 오늘자 미션 배정 조회 |

## 쿼리 원문

[1] insert into problem_submission (created_at,is_correct,problem_id,selected_option_id,submitted_content,updated_at,user_id) values ($1,$2,$3,$4,$5,$6,$7)
RETURNING *

[2] insert into wrong_answered_note (created_at,problem_id,resolved_at,updated_at,user_id,wrong_count) values ($1,$2,$3,$4,$5,$6)
RETURNING *

[3] select wan1_0.id,wan1_0.created_at,wan1_0.problem_id,wan1_0.resolved_at,wan1_0.updated_at,wan1_0.user_id,wan1_0.wrong_count from wrong_answered_note wan1_0 where wan1_0.problem_id=$1 and wan1_0.user_id=$2

[4] select ls1_0.id from lesson_submission ls1_0 where ls1_0.lesson_id=$1 and ls1_0.user_id=$2 fetch first $3 rows only

[5] select count(ls1_0.id) from lesson_submission ls1_0 where ls1_0.lesson_id=$1 and ls1_0.user_id=$2

[6] select ul1_0.id,ul1_0.created_at,ul1_0.league_id,ul1_0.league_point,ul1_0.season_id,ul1_0.updated_at,ul1_0.user_id from user_league ul1_0 left join users u1_0 on u1_0.id=ul1_0.user_id and (u1_0.deleted_at IS NULL) where u1_0.id=$1

[7] select l1_0.name from user_league ul1_0 join league l1_0 on ul1_0.league_id=l1_0.id where ul1_0.user_id=$1

[8] update users set created_at=$1,deleted_at=$2,email=$3,handle=$4,is_onboarded=$5,last_accessed_at=$6,level=$7,xp=$8,nickname=$9,profile_img_number=$10,provider_id=$11,role=$12,status=$13,updated_at=$14 where id=$15

[9] select count(distinct ls1_0.lesson_id) from lesson_submission ls1_0 where ls1_0.user_id=$1

[10] insert into lesson_submission (accuracy,created_at,learning_time,lesson_id,updated_at,user_id) values ($1,$2,$3,$4,$5,$6)
RETURNING *

[11] update daily_learning_record set solved_date=$1,solved_lesson_count=$2,user_id=$3 where id=$4

[12] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[13] select c1_0.id,u1_0.id,l1_0.id from lesson l1_0 join unit u1_0 on u1_0.id=l1_0.unit_id join chapter c1_0 on c1_0.id=u1_0.chapter_id where l1_0.id=$1

[14] update user_league set created_at=$1,league_id=$2,league_point=$3,season_id=$4,updated_at=$5,user_id=$6 where id=$7

[15] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 join lesson l1_0 on l1_0.unit_id=u1_0.id where l1_0.id=$1

[16] select p1_0.id,p1_0.problem_type from problem p1_0 where p1_0.id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30)

[17] select dlr1_0.id,dlr1_0.solved_date,dlr1_0.solved_lesson_count,dlr1_0.user_id from daily_learning_record dlr1_0 where dlr1_0.user_id=$1 and dlr1_0.solved_date=$2

[18] insert into social_feed (actor_id,created_at,event_type,event_value,updated_at) values ($1,$2,$3,$4,$5)
RETURNING *

[19] BEGIN READ ONLY

[20] select um1_0.id,um1_0.assigned_date,um1_0.completed_at,um1_0.created_at,um1_0.mission_id,um1_0.progress_count,um1_0.updated_at,um1_0.user_id,m1_0.id,m1_0.award_xp,m1_0.code,m1_0.created_at,m1_0.description,m1_0.max_progress_per_event,m1_0.status,m1_0.target_type,m1_0.target_value,m1_0.title,m1_0.updated_at,m1_0.weight from user_mission um1_0 join mission m1_0 on m1_0.id=um1_0.mission_id where um1_0.user_id=$1 and um1_0.assigned_date=$2
