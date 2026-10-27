# [PLAN-573] QA 페르소나 데이터셋과 세트별 재적재 API

> 이슈: #573
> 브랜치: feat/573-qa-persona-fixture

## 목표
gravit-qa의 자동 실행과 수동 QA가 매번 같은 사용자 상태에서 시작하도록 한다. 테스트 API 한 번으로 페르소나 13개와 보조 유저를 세트(`auto`, `manual`)별로 지우고 다시 적재하며, Redis까지 맞춘 뒤 userId 매니페스트를 돌려준다.
지금 이 API를 쓰는 곳은 없으므로 기존 기능의 동작은 바꾸지 않는다. 예외는 S4의 `users/login` 404 하나다. 모든 신규 빈은 `@Profile("!prod")`이고 Flyway 마이그레이션은 추가하지 않는다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/test/fixture/TestQaFixtureController.java` - `POST /api/v1/test/fixtures/qa/reload?set=`
- `src/main/java/gravit/code/test/fixture/docs/TestQaFixtureControllerDocs.java` - `@Tag(name = "Test QA Fixture API")`
- `src/main/java/gravit/code/test/fixture/support/QaFixtureReloader.java` - 실행 순서: 사전 검증 → Redis 제거 → (트랜잭션: 삭제, 적재, 결과 조회) → Redis 반영
- `src/main/java/gravit/code/test/fixture/support/QaFixtureReloadLock.java` - 세트별 재진입 불가 락(`AtomicBoolean`)
- `src/main/java/gravit/code/test/fixture/support/QaFixtureSet.java` - enum `AUTO("auto")`, `MANUAL("manual")`
- `src/main/java/gravit/code/test/fixture/support/QaPersona.java` - enum 13개 (key, description)
- `src/main/java/gravit/code/test/fixture/sql/QaFixtureSql.java` - 사전 검증, 대상 유저와 랭킹 멤버, 매니페스트 조회용 네이티브 SQL 상수(`UserCleanDeletionSql`과 같은 `@UtilityClass` 텍스트 블록)
- `src/main/java/gravit/code/test/fixture/dto/response/QaFixtureManifestResponse.java` - `set`, `loadedAt`, `personas`
- `src/main/java/gravit/code/test/fixture/dto/response/QaPersonaManifestResponse.java` - `personaKey`, `userId`, `description`
- `src/main/java/gravit/code/test/fixture/dto/internal/QaRankMemberDto.java` - `seasonId`, `leagueId`, `userId`, `leaguePoint`
- `src/main/java/gravit/code/test/fixture/dto/internal/QaFixtureLoadResultDto.java` - `personas`, `rankMembers`, `withdrawingUserId`
- `src/main/resources/sql/seed/qa/01_users.sql` - 페르소나 13명과 보조 유저 6명의 `users` 행
- `src/main/resources/sql/seed/qa/02_onboarding.sql` - 온보딩된 유저의 `learning`, `user_mission`, `user_league` 기본 행
- `src/main/resources/sql/seed/qa/03_learning.sql` - learner, streak, chapter-almost, mission의 제출 이력과 파생 값(xp, level, LP, 리그, learning)
- `src/main/resources/sql/seed/qa/04_social.sql` - social과 보조 유저의 팔로우, 피드, 축하, 알림
- `src/main/resources/sql/seed/qa/05_league.sql` - league-edge와 보조 유저의 LP, 리그 이력
- `src/main/resources/sql/seed/qa/06_interview.sql` - interviewer의 세션 4건
- `src/main/resources/sql/seed/qa/07_inquiry.sql` - inquirer의 문의, admin 페르소나의 답변, 알림
- `src/main/resources/sql/seed/qa/08_account.sql` - withdrawing, suspended, admin 상태
- `src/main/resources/sql/seed/qa/PERSONAS.md` - 페르소나 명세(아래 "페르소나 데이터" 표와 같은 내용, 사용 시 주의)
- `src/test/java/gravit/code/test/fixture/TestQaFixtureControllerIntegrationTest.java` - S3
- `src/test/java/gravit/code/test/user/TestUserCheatCreateControllerIntegrationTest.java` - S4

### 수정 파일
- `src/main/java/gravit/code/test/user/TestUserCheatCreateController.java` - `login`의 `findById(userId).get()`를 `.orElseThrow(() -> new RestApiException(USER_NOT_FOUND))`로 바꾼다. 나머지 엔드포인트는 그대로 둔다
- `src/main/java/gravit/code/test/user/docs/TestUserCheatCreateControllerDocs.java` - `login`에 `404 USER_4041` 응답 문서 추가
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `// QA Fixture` 그룹에 3개 추가 (아래 "오류 코드")
- `src/main/resources/sql/README.md` - 폴더 표에 `seed/qa/` 행 추가: "QA 페르소나 데이터셋. 재적재 API 전용(`{set}` 자리표시자 치환), 명세는 `seed/qa/PERSONAS.md` | X"
- 서비스 정책 변경 없음. 테스트 API 전용이며 사용자에게 드러나는 규칙이 바뀌지 않는다

## 전체 흐름

```
POST /api/v1/test/fixtures/qa/reload?set=auto
 1. QaFixtureSet.from("auto")                       없는 세트 → 400 QA_FIXTURE_4001
 2. reloadLock.tryAcquire(AUTO)                     진행 중 → 409 QA_FIXTURE_4091
 3. 사전 검증 (트랜잭션 밖, 조회만)                  ACTIVE 시즌 없음 → 404 SEASON_4041
                                                    리그, 미션 정의, 콘텐츠, 면접 문제 부족 → 409 QA_FIXTURE_4092
 4. 이전 세트 조회: 유저 id, 랭킹 멤버(season, league, user)
 5. Redis 제거: 랭킹 멤버 remove, user:clean:due에서 이전 id 전부 remove
 6. TransactionTemplate {
      SET LOCAL TIME ZONE 'Asia/Seoul'
      이전 유저마다 UserCleanDeletionSql 실행, user_daily_activity 삭제
      01 ~ 08 SQL 실행 ({set} → auto)
      매니페스트, 새 랭킹 멤버, withdrawing id 조회
    }
 7. Redis 반영: 랭킹 멤버 put, withdrawing storeDeletionUser
 8. 락 해제, 200 매니페스트
```

- Redis 제거(5)를 트랜잭션 앞에 둔다. 제거 대상은 지워질 DB 행에서 읽어야 하므로, 이 순서면 트랜잭션이 실패해 재시도하더라도 같은 행에서 다시 읽어 지울 수 있다
- Redis 반영(7)은 커밋 뒤에 한다. 반영이 실패하면 응답은 500이고 DB는 이미 커밋된 상태다. gravit-qa가 5xx를 받으면 한 번 재시도하고, 재시도는 위 1~8을 처음부터 다시 수행해 상태를 맞춘다. 재시도 없이 앱이 재기동되면 `LeagueRankingWarmupRunner.rebuildIfStale`이 DB와 Redis의 건수 차이를 보고 재구성한다
- 락은 Redis 반영까지 잡고 있는다. 같은 세트의 두 요청이 겹치면 한쪽의 put이 다른 쪽의 remove 뒤에 실행되어, 지워진 유저가 랭킹에 남을 수 있기 때문이다

## 적재 방식: 전 페르소나 SQL

- 서비스 호출을 쓰지 않는다. `UserService.onboard`, `LessonFacade.saveLessonSubmission`, `SocialFacade` 같은 경로는 부수 효과를 `AFTER_COMMIT` 리스너(`REQUIRES_NEW`)에서 만들기 때문이다. 그런 부수 효과로는 learning, user_mission, user_league, LP, 미션 진행, 일별 기록, 피드, 알림, 재시도 큐가 있다
  - 이 경우 "삭제와 적재는 한 트랜잭션"이 깨진다
  - 미션은 가중치 랜덤으로 배정돼 값이 매번 달라진다
- `TestScenarioController`에서는 코드가 아니라 규칙만 가져온다. 규칙은 두 가지다. 챕터 완료 직전은 한 챕터의 레슨을 마지막 하나 빼고 모두 제출한 상태이고, 연속 학습은 `consecutive_solved_days = N`, `today_solved = false`인 상태다
  - 코드는 쓰지 않는다. 위의 서비스 호출 경로를 타는 데다, 아래 "조사 중 발견" 1, 2의 결함도 있다
- SQL 파일은 `{set}` 자리표시자를 문자열 치환해 실행한다. 치환 값은 enum key(`auto`, `manual`)뿐이라 외부 입력이 SQL에 들어가지 않는다
  - 실행은 `ScriptUtils.executeSqlScript`로 하고, 연결은 `DataSourceUtils.getConnection(dataSource)`로 얻은 트랜잭션 바인딩 연결을 쓴다
- 식별자는 다음과 같다. IDENTITY가 id를 발급하고, 연관 행은 이메일 서브쿼리로 참조한다
  - `provider_id`: `qa-persona-{set}-{key}`
  - `email`: `qa-persona-{set}-{key}@gravit.test`
  - `handle`: `qa-persona-{set}-{key}`
  - 보조 유저는 `{key}` 자리에 `aux-NN`이 들어간다
- 세트 범위는 `provider_id LIKE 'qa-persona-{set}-%'`로 잡는다. 하이픈까지 포함하므로 `auto`가 `manual`이나 다른 세트를 덮지 않는다
- 시각 기준
  - 트랜잭션 첫 문장 `SET LOCAL TIME ZONE 'Asia/Seoul'`로 `now()`와 `current_date`를 앱과 같은 KST 벽시계로 맞춘다. 앱은 KST 벽시계 값을 `timestamp` 컬럼에 쓴다(`BaseEntity`, `TimeConfig`)
  - 지난 날짜의 시각은 `date_trunc('day', now()) - interval 'N days' + interval '20 hours'`로 고정해 학습 피크 시간대가 매번 같게 한다
  - 오늘 행은 `now()`를 쓴다
- 콘텐츠 순서: 레슨은 `unit.display_order`, `lesson.id` 순으로 고른다. 면접 문제는 주제별 `is_active = true AND difficulty = 'NORMAL'`인 문제를 `id` 오름차순으로 고른다

## 페르소나 데이터

**온보딩 기본 행**은 아래 4개 테이블에 들어가는 행이다. `pre-onboarding`을 뺀 전원과 보조 유저 전원이 갖는다.

| 테이블 | 값 |
|---|---|
| `users` | `is_onboarded = true`, `role = 'USER'`, `status = 'ACTIVE'`, `profile_img_number = 1`, `last_accessed_at = now() - 1일`, `level`과 `xp`는 아래 표의 값(기본 1, 0) |
| `learning` | `consecutive_solved_days = 0`, `planet_conquest_rate = 0`, `today_solved = false`, `recent_solved_chapter_id = 1`. `version` 컬럼은 넣지 않는다(DB 기본값 사용) |
| `user_mission` | `assigned_date = current_date`, 미션 `COMPLETE_LESSON_ONE`, `progress_count = 0`, `completed_at = NULL` |
| `user_league` | ACTIVE 시즌, `league_point`는 아래 표의 값(기본 0), `league_id`는 LP 구간에 맞는 리그 |

- `last_accessed_at`을 어제로 두면 오늘 첫 요청에서 앱이 `user_daily_activity`를 직접 기록한다. 오늘로 두면 기록되지 않는다(`UserAccessService`)
- 닉네임은 2~8자 `[가-힣a-zA-Z0-9]` 규칙을 지킨다. 알림 문구에 들어가고 프로필 수정 API가 검증하기 때문이다

| 키 | 상태 | 만드는 행 (기본 행 외) | 값과 근거 |
|---|---|---|---|
| `pre-onboarding` | 온보딩 전 | `users`만. `is_onboarded = false`, `last_accessed_at = NULL`. 부속 행 없음 | 설계 9-3 그대로 |
| `fresh` | 온보딩 직후 | 없음 | LP 0(브론즈 3), xp 0. 설계 9-3 그대로 |
| `learner` | 학습 진행 중 | 챕터 1 앞 레슨 10개를 D-13, 12, 10, 9, 7, 6, 4, 3, 2, 1일 20:00에 하루 1개씩 제출: `lesson_submission` 10, `problem_submission`은 레슨의 모든 문제 / 3, 6, 9번째 레슨은 id가 작은 문제 2개를 오답 처리 / `wrong_answered_note` 6(`wrong_count = 1`) / `bookmark` 3(1, 2번째 레슨의 첫 문제와 3번째 레슨의 첫 오답 문제) / `daily_learning_record` 10일, 각 1 | 14일 안에 정답과 오답이 섞인다. 마지막 4일(D-4~D-1)이 연속이므로 `consecutive_solved_days = 4`, `today_solved = false`이고 일별 기록과 맞는다. 이번 주와 지난주에 기록이 모두 있어 주간 리포트 증감이 보인다(오늘이 월요일이면 이번 주 칸은 비어 있다). 그 밖의 값: 정확도 = 정답 수 / 문제 수, xp = LP = Σ round(20 × 정확도 / 100), level과 리그는 그 값에서 계산, `recent_solved_chapter_id = 1`, `planet_conquest_rate`는 앱과 같은 식(제출 레슨 수 / 전체 레슨 수) |
| `streak` | 연속 학습 6일 | 챕터 2 앞 레슨 6개를 D-6~D-1 20:00에 하루 1개씩 정확도 100으로 제출 / `daily_learning_record` 6일, 각 1 | `consecutive_solved_days = 6`, `today_solved = false`. 오늘 새 레슨 1개를 풀면 7일이 되어 STREAK_DAYS 피드(마일스톤 7)가 생긴다. 오늘 풀지 않으면 21시 연속 학습 위기 알림 대상이 되고 00:01 정산에서 0이 된다. xp = LP = 120(레벨 2, 브론즈 2) |
| `chapter-almost` | 챕터 마지막 레슨 직전 | 챕터 1 레슨 83개 중 82개를 D-2 20:00부터 1초 간격, 정확도 100으로 제출 / `daily_learning_record`(D-2, 82). 빼는 1개는 마지막 유닛(`display_order` 최대)의 id 최대 레슨 | 챕터 1은 CS 기본 챕터라 어느 화면에서든 노출이 확실하다. 진행률 floor(82/83 × 100) = 98, 마지막 유닛 IN_PROGRESS. 남은 레슨 하나를 제출하면 100이 된다. 연속 학습은 D-1에 끊겼으므로 0이다. xp = LP = 1640(레벨 7, 플래티넘 3). 행 수는 `INSERT ... SELECT` 한 문장이라 문제가 되지 않는다 |
| `social` | 팔로우와 피드 보유 | 아래 "social 상세" | social LP 5(aux-01이 보낸 축하 +5), xp 100(레벨 2, LEVEL_UP 피드와 맞춤) |
| `league-edge` | 승급 경계 | LP 615 / 같은 리그 보조 유저 aux-03 620, aux-04 618, aux-05 540, aux-06 470 / 직전 CLOSED 시즌 `user_league_history` 1건(최종 실버 1, LP 700, 순위 2) | 실버 2 구간은 461~620이다. 정확도 28% 이상인 신규 레슨 1개(+6 LP 이상)로 621이 되어 실버 1로 승급(TIER_PROMOTION)한다. 다른 페르소나가 없는 리그라 순위 비교가 섞이지 않는다. 시즌 중 강등은 없다. 시즌 종료 소프트 리셋은 설계 9-4에 따라 수동이다 |
| `mission` | 미션 완료 직전 | 챕터 3 첫 레슨 1개를 오늘 `now()`에 정확도 100으로 제출 / `daily_learning_record`(오늘, 1) / `user_mission`은 `COMPLETE_LESSONS_TWO`, `progress_count = 1` | 다음 신규 레슨 1개(정확도 무관)로 완료되어 +15 XP를 받는다. 진행률은 50.0이다. PERFECT_*는 정확도 100이 필요하고, 시간 미션은 초 단위라 제외했다. `consecutive_solved_days = 1`, `today_solved = true`, xp = LP = 20 |
| `interviewer` | 면접 이력 보유 | 아래 "interviewer 상세" | xp = LP = 17(COMPLETED 보상 round(30 × 57 / 100)) |
| `inquirer` | 문의 답변 완료 | `inquiry` RESOLVED(BUG_REPORT, D-2) + `inquiry_answer`(`admin_id` = 같은 세트 admin 페르소나, D-1) + `notification` INQUIRY_ANSWERED(`target_id` = 문의 id, D-1, 안 읽음) / 표에 없는 추가: `inquiry` PENDING(FEATURE_SUGGESTION, now() - 1시간) 1건 | RESOLVED 1건으로 답변 보기 흐름을 확인한다. PENDING 1건은 admin 페르소나의 답변 등록 흐름을 확인하려고 넣는다. 제목은 50자 이하로 한다. 본문의 줄바꿈은 `sql/README.md` 작성 주의에 따라 `E'...\n...'` 한 줄로 쓴다 |
| `withdrawing` | 탈퇴 유예 중 | 기본 행 유지, `status = 'DELETED'`, `deleted_at = now()`, `handle = NULL` | 실제 탈퇴(`UserDeletionService.confirmDeleteByMailAuthCode`) 직후와 같은 상태다. Redis 랭킹에서 빼고 `user:clean:due`에 넣는다. `storeDeletionUser`가 점수를 now(clock) + 7일로 고정하므로 `deleted_at = now()`여야 두 값이 맞는다 |
| `suspended` | 정지 | `status = 'SUSPENDED'` | 설계 9-3 그대로 |
| `admin` | 관리자 | `role = 'ADMIN'` | 설계 9-3 그대로. inquirer 답변의 `admin_id`로 쓴다 |

**social 상세** (aux-01 = 맞팔로우, aux-02 = 단방향 팔로워)

| 테이블 | 행 |
|---|---|
| `friends` | social→aux-01, aux-01→social, aux-02→social |
| `social_feed` | social LEVEL_UP `'2'`(D-1), aux-01 STREAK_DAYS `'7'`(D-1), aux-01 TIER_PROMOTION `'브론즈 2'`(D-2) |
| `user_feed` | social 피드 → aux-01, aux-02 / aux-01 피드 2건 → social. 행위자 본인 행은 없다 |
| `congratulation` | aux-01 → social의 LEVEL_UP(D-1) / social → aux-01의 TIER_PROMOTION(D-2). 각 보낸 사람의 `user_feed.congratulated_at`을 채운다 |
| `notification` (social 수신) | FOLLOW ← aux-01(이미 팔로우 중이라 버튼 없음), FOLLOW ← aux-02(맞팔로우 버튼), FRIEND_ACTIVITY 2(aux-01 피드), CONGRATULATION ← aux-01(`target_id = NULL`) |

- aux-01은 LP 155로 브론즈 2다. 150에 social이 보낸 축하 +5를 더한 값이고, TIER_PROMOTION 피드와 맞는다. aux-02는 LP 0으로 브론즈 3이다
- 한 화면에서 세 경우를 모두 볼 수 있다. 맞팔로우와 단방향 팔로우, 축하 가능 피드(aux-01 STREAK)와 축하한 피드(aux-01 TIER)다. 보낸 축하는 D-2라서 오늘 한도(상대당 3회)에 들어가지 않는다
- 보조 유저가 받는 알림은 만들지 않는다. 보조 유저는 로그인하지 않기 때문이다
- 문구는 `NotificationMessageProvider`와 같은 형식으로 쓴다
- `social_feed`, `notification`, `friends`, `inquiry_answer`의 `created_at`은 반드시 채운다. NULL이면 각각 NPE, 알림함 제외, 정렬 왜곡, `answeredAt` 누락이 생긴다

**interviewer 상세** (공통: TEXT 입력, NORMAL, 만점 70/15/15, 시도 차수는 생성 순서)

| 차수 | 상태 | 시각 | 모드, 주제 | 답안, 피드백 |
|---|---|---|---|---|
| 1 | COMPLETED | D-3 20:00, 15분 | COMMON_CS, DATA_STRUCTURE 3 + NETWORK 2 | 답안 5. 1~4번 ANSWERED, 5번 NO_RESPONSE. 피드백 5. 정확도 14/12/9/5/0(기본 비율 1.0/0.875/0.625/0.375/NULL, 배율 1.0), 구조+명료 6/5/4/2/0. 세션 정확도 40, 전달력 17, 총점 57. 4번(7점)과 5번(0점)이 약점(문항 10점 이하) |
| 2 | GRADING_FAILED | D-2 20:00 | 1차와 같음 | 답안 5 ANSWERED, `answered_at = ended_at`, `grading_attempt_count = 1`, 피드백 없음 |
| 3 | GRADING | D-1 20:00 | 1차와 같음 | 2차와 같음. 자동으로 처리하는 경로가 없으므로 채점 중으로 남는다 |
| 4 | IN_PROGRESS | now() - 10분 | JOB_SPECIFIC, JAVA_SPRING_BOOT(SERVER_COMMON 1, JAVA 2, SPRING_BOOT 2) | 답안 5 PENDING, `ended_at = NULL` |

- 두 모드를 모두 포함한다. 정확도 점수는 앱 식 round(기본 비율 × 배율 × 14)와 맞추고, 기본 비율은 반올림 경계(.5)를 피하는 값으로 골랐다
- 세션 종합, 약점 주제, 메인 대시보드는 COMPLETED 1건으로 채워진다

## 구현 계획
1. **Entity / Flyway**: 없음. 데이터셋은 `sql/seed/qa/`에 두고 마이그레이션은 추가하지 않는다
2. **Repository**: 신규 메서드는 없다. 기존 메서드는 아래 둘만 쓴다
   - `UserRepository.cleanUserDeletion(long userId)`: 기존 `UserDeletionRepositoryImpl`. 탈퇴 7일 뒤 실제 삭제와 같은 FK 역순 CTE를 실행한다
   - `SeasonRepository.findByStatus(SeasonStatus.ACTIVE)`: 사전 검증용
   - 그 밖의 조회는 `QaFixtureSql` 상수와 `NamedParameterJdbcTemplate`로 테스트 패키지 안에서 처리한다. 메인 도메인 저장소를 늘리지 않는다
3. **Service**: `QaFixtureReloader`(`@Profile("!prod") @Component`). 테스트 패키지는 도메인 구조를 따르지 않으므로 Facade나 Service 레이어를 두지 않는다. 기존 `TestUserDataCleanController`, `TestSeasonCleanController`가 저장소와 `EntityManager`를 직접 쓰는 것과 같은 수준이다
   - 주입: `NamedParameterJdbcTemplate`, `DataSource`, `TransactionTemplate`, `UserRepository`, `SeasonRepository`, `LeagueRankingStore`, `RedisUserCleanManager`, `QaFixtureReloadLock`, `Clock`
   - `public QaFixtureManifestResponse reload(QaFixtureSet set)`: 위 "전체 흐름" 2~8. 락은 `finally`에서 푼다
   - `private void verifyPrerequisites()`: ACTIVE 시즌이 없으면 `ACTIVE_SEASON_NOT_FOUND`. `QaFixtureSql.PREREQUISITE_SQL` 한 문장으로 아래를 확인하고, 하나라도 부족하면 `QA_FIXTURE_PREREQUISITE_MISSING`을 던진다
     - 리그 15개
     - 미션 정의 `COMPLETE_LESSON_ONE`, `COMPLETE_LESSONS_TWO`
     - 챕터 1, 2, 3의 레슨 수가 각각 10, 6, 1 이상
     - 면접 문제(활성, NORMAL) DATA_STRUCTURE 3, NETWORK 2, SERVER_COMMON 1, JAVA 2, SPRING_BOOT 2 이상
     - `INSERT ... SELECT`가 콘텐츠 부족으로 0행을 넣고 조용히 성공하는 일을 막기 위한 검증이다
   - `private List<Long> findUserIds(QaFixtureSet set)`: `SELECT id FROM users WHERE provider_id LIKE :prefix`. 네이티브 SQL이라 탈퇴 유저도 포함된다
   - `private List<QaRankMemberDto> findRankMembers(QaFixtureSet set)`: `user_league`에 `users`를 조인한다. 대상은 세트 접두어를 가지고 `deleted_at IS NULL`인 유저다. 랭킹 재구성 원본인 `UserLeagueRepository.findRankEntriesBySeasonId`와 같은 기준이다
   - `private void removeFromRedis(List<QaRankMemberDto> members, List<Long> userIds)`: `leagueRankingStore.remove(seasonId, leagueId, userId)`, `redisUserCleanManager.removeUserKey(userId)`
   - `private QaFixtureLoadResultDto deleteAndLoad(QaFixtureSet set)`: 트랜잭션 안. 아래를 차례로 수행한다
     - `SET LOCAL TIME ZONE 'Asia/Seoul'`
     - 이전 id마다 `userRepository.cleanUserDeletion(id)` 실행
     - `DELETE FROM user_daily_activity WHERE user_id IN (:ids)`
     - `SCRIPT_LOCATIONS` 8개를 순서대로 `runScript`로 실행
     - 매니페스트, 새 랭킹 멤버, withdrawing id 조회
   - `private void runScript(String location, QaFixtureSet set)`: `ClassPathResource`를 UTF-8로 읽고 `{set}`을 치환한 뒤, `DataSourceUtils.getConnection(dataSource)`에서 `ScriptUtils.executeSqlScript(connection, new ByteArrayResource(...))`
   - `private void addToRedis(QaFixtureLoadResultDto result)`: 아래 둘을 수행한다
     - 새 랭킹 멤버마다 `leagueRankingStore.put(seasonId, leagueId, userId, leaguePoint)`
     - `redisUserCleanManager.storeDeletionUser(withdrawingUserId)`
   - 매니페스트 조회 결과에서 페르소나 13개가 모두 나오지 않으면 `IllegalStateException`을 던진다. 응답은 500이고 트랜잭션은 롤백된다
4. **Facade**: 불필요. 위 3의 근거
5. **DTO**
   - `QaFixtureManifestResponse(String set, OffsetDateTime loadedAt, List<QaPersonaManifestResponse> personas)`
     - `static of(QaFixtureSet set, OffsetDateTime loadedAt, List<QaPersonaManifestResponse> personas)`
     - `loadedAt = OffsetDateTime.now(clock).truncatedTo(SECONDS)`. 커밋과 Redis 반영 뒤 시각이며 `2026-10-17T14:05:00+09:00` 형식이다
   - `QaPersonaManifestResponse(String personaKey, long userId, String description)`. 순서는 `QaPersona` 선언 순서다. 보조 유저는 넣지 않는다
   - `QaRankMemberDto(long seasonId, long leagueId, long userId, int leaguePoint)`
   - `QaFixtureLoadResultDto(List<QaPersonaManifestResponse> personas, List<QaRankMemberDto> rankMembers, long withdrawingUserId)`
   - `QaFixtureSet`: `getKey()`, `static from(String value)`. 없는 값이면 `QA_FIXTURE_SET_INVALID`를 던진다
   - `QaPersona`: `getKey()`, `description(QaFixtureSet set)`
     - `withdrawing`의 설명에는 토큰 발급이 404이고 복구는 `PATCH /api/v1/users/restore?providerId=qa-persona-{set}-withdrawing`로 한다는 안내를 넣는다
6. **Controller**: `POST /api/v1/test/fixtures/qa/reload?set={auto|manual}` → `TestQaFixtureController.reload(@RequestParam String set)` → `ResponseEntity.status(OK).body(qaFixtureReloader.reload(QaFixtureSet.from(set)))`
   - Docs 응답에 200, 400 `QA_FIXTURE_4001`, 404 `SEASON_4041`, 409 `QA_FIXTURE_4091`/`QA_FIXTURE_4092`를 적는다
   - `/api/v1/test/**`는 permitAll이다. 접근 제한(#15)은 범위 밖이다
7. **QaFixtureReloadLock** (`@Profile("!prod") @Component`)
   - `boolean tryAcquire(QaFixtureSet set)`, `void release(QaFixtureSet set)`
   - 세트별 `AtomicBoolean.compareAndSet`이다. 같은 스레드에서도 두 번 잡히지 않는 락이라, 테스트가 락을 잡은 채 MockMvc를 호출하면 409를 재현할 수 있다
   - dev 앱은 컨테이너 1개(`gravit-server-dev`)이므로 JVM 락이면 충분하다

### 오류 코드 (`// QA Fixture` 그룹 신설)
| 코드 | HTTP | 메시지 | 언제 |
|---|---|---|---|
| `QA_FIXTURE_SET_INVALID` / `QA_FIXTURE_4001` | 400 | 지원하지 않는 QA 페르소나 세트입니다. | `set`이 auto, manual이 아님 |
| `QA_FIXTURE_RELOAD_IN_PROGRESS` / `QA_FIXTURE_4091` | 409 | 같은 세트의 재적재가 진행 중입니다. | 같은 세트 동시 요청 |
| `QA_FIXTURE_PREREQUISITE_MISSING` / `QA_FIXTURE_4092` | 409 | QA 페르소나 적재에 필요한 기준 데이터가 없습니다. | 리그, 미션 정의, 콘텐츠, 면접 문제 부족. 콘텐츠 부족에 409를 쓰는 선례 `INTERVIEW_QUESTION_POOL_INSUFFICIENT`를 따랐다 |

- 기존 코드 재사용
  - ACTIVE 시즌 없음: `SEASON_4041`(404)
  - SQL 실패: `DataAccessException` 계열(`ScriptException` 포함)로 `DB_4001`(400)
  - 그 밖의 예외: `GLOBAL_5001`(500)
- `set` 파라미터가 아예 없으면 `MissingServletRequestParameterException`이 전역 처리기에서 500이 된다. 기존 전역 동작이므로 바꾸지 않는다

### Redis 키
| 키 | 템플릿 | 형식 | 처리 |
|---|---|---|---|
| `league:rank:{activeSeasonId}:{leagueId}` | `rankingRedisTemplate` | ZSET, member = userId 문자열, score = `LeagueRankScore.encode(lp, userId)` | 이전 세트 멤버 `LeagueRankingStore.remove`, 새 세트 멤버 `put`. 탈퇴한 유저는 넣지 않는다(재구성 원본과 같은 기준) |
| `user:clean:due` | `redisTemplate` | ZSET, member = userId 문자열, score = 정리 예정 epoch초 | 이전 세트 id 전부 `RedisUserCleanManager.removeUserKey`, 새 withdrawing은 `storeDeletionUser`(now(clock) + 7일) |

건드리지 않는 키: `season:lastClosedSeasonId`, 시즌 캐시, 팝업 노출, 재시도 큐, 리프레시 토큰. 시즌 같은 전역 상태는 설계 9-4에 따라 그대로 둔다.

## 결정 필요 (Decisions needed)
- [x] Redis 랭킹 반영 방식 - **A 확정: 세트 멤버만 remove, put**. 다른 세트와 실제 dev 유저를 건드리지 않고, auto와 manual이 동시에 돌아도 서로 덮지 않는다 (B: 시즌 전체 `rebuild`는 `replaceAll`이 시즌 키를 지운 뒤 다시 채워, 그 사이 다른 세트의 반영을 덮을 수 있어 제외)
- [x] 이전 세트 삭제 방식 - **A 확정: 유저마다 `UserCleanDeletionSql` 재사용**. 실제 탈퇴 정리와 같은 FK 역순이고 테이블 추가 시 함께 갱신되는 경로라 QA 중 앱이 만든 행까지 지운다 (B: 전용 삭제 SQL은 테이블 추가마다 따로 고쳐야 해 제외)
- [x] 페르소나의 `user_daily_activity` - **삭제 확정**. 재적재마다 id가 바뀌어, 지우지 않으면 QA 접속 기록이 dev DAU에 계속 쌓인다
- [x] `league-edge` 리그 이력의 지난 시즌 - **CLOSED 시즌이 있으면 가장 최근 1건에 넣고, 없으면 이력만 생략 확정**. 시즌은 전역 상태라 만들지 않는다
- [x] 페르소나 세부 값 - **"페르소나 데이터" 표대로 확정**. 표에 없던 추가인 inquirer의 PENDING 문의 1건을 포함하고, `chapter-almost`는 챕터 1(83개)이다

## 검증
- 대상 테스트: `TestQaFixtureControllerIntegrationTest` (S3)
  - 구성: `@TCSpringBootTest`, `@AutoConfigureMockMvc`, `@TestPropertySource(properties = {"spring.flyway.enabled=true", "spring.flyway.clean-disabled=false", "spring.jpa.hibernate.ddl-auto=none"})`
    - 테스트 프로필은 Hibernate가 엔티티로 스키마를 만들고(`ddl-auto: create`, Flyway 꺼짐), 미션 정의 같은 마이그레이션 시드도 없다. 그래서 이 클래스만 Flyway 스키마를 쓰는 별도 컨텍스트로 띄운다. 이 컨텍스트는 Postgres 컨테이너를 따로 가지므로 다른 테스트에 영향이 없다
  - `@BeforeEach`(`DatabaseClearExtension`의 TRUNCATE 뒤):
    - `flyway.clean()`, `flyway.migrate()`로 V1~V47을 적용한다
    - `ResourceDatabasePopulator`로 `sql/README.md` 실행 순서의 콘텐츠를 적재한다: chapter, unit, league, `problem/**`, `interview/**`, `sync`
    - ACTIVE 시즌 1건과 CLOSED 시즌 1건을 넣는다
  - 시나리오 (`@Nested` + `@DisplayName`)
    - 적재 성공
      - 매니페스트: `set`, 고정 시계 `loadedAt`, 키 13개의 순서, 각 userId가 `provider_id`로 찾은 id와 같음, 보조 유저 미포함
      - 페르소나별 상태: 위 표의 핵심 값을 `assertSoftly`로 확인
        - pre-onboarding: 부속 행 0
        - learner: 제출 10건, 14일 이내, 오답 노트 6, 북마크 3
        - streak: 연속 일수 = 일별 기록 수 = 6
        - chapter-almost: 제출 레슨 수 = 챕터 레슨 수 - 1
        - interviewer: 상태별 1건, COMPLETED 피드백 5건, 점수 57
        - withdrawing: `deleted_at`이 있고 `handle`이 NULL
        - suspended, admin: 상태와 역할
        - league-edge: LP와 이력
      - Redis
        - 페르소나와 보조 유저가 각자의 `league:rank:*` 키에 올바른 score로 있다
        - withdrawing은 랭킹에 없고 `user:clean:due`에 있다
    - 같은 세트 재적재: 이전 userId가 DB와 Redis(랭킹, 정리 예약)에서 모두 사라지고 새 userId로 바뀐다
    - 세트 독립: manual 적재 후 auto를 재적재해도 manual 유저의 id와 행 수가 그대로다
    - 같은 세트가 적재 중(락을 잡은 상태)이면 409 `QA_FIXTURE_4091`
    - 없는 세트면 400 `QA_FIXTURE_4001`
    - ACTIVE 시즌이 없으면 404 `SEASON_4041`
    - 콘텐츠가 없으면 409 `QA_FIXTURE_4092`
  - 측정: 적재 요청 소요 시간을 테스트 로그로 남겨 gravit-qa 타임아웃 근거로 보고한다
- 대상 테스트: `TestUserCheatCreateControllerIntegrationTest` (S4)
  - 없는 userId면 404 `USER_4041`
  - 있는 userId면 200과 토큰(기존 동작 유지 확인)
- 회귀: `./gradlew test` 전체 통과. 기존 테스트 API, 메인 코드 경로가 바뀌지 않았는지 확인한다

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다.

- `TestQaFixtureControllerIntegrationTest`: 마이그레이션과 콘텐츠 적재를 `@BeforeEach`가 아니라 성공 경로 테스트의 given(`마이그레이션과_기준_데이터를_적재한다()`)에서 한다. 실패 경로 4건은 `DatabaseClearExtension`이 비운 스키마에서 바로 검증한다 — 이유: 실패 경로는 콘텐츠가 필요 없거나(400, 409 락) 오히려 없어야 해서(404 시즌, 409 기준 데이터) 테스트마다 수 초씩 드는 적재를 건너뛴다
- `QaPersona`: 설명에 providerId를 넣을 때 `String.formatted` 대신 `{providerId}` 문자열 치환을 쓴다 — 이유: `league-edge` 설명의 "28% 이상"이 형식 지정자로 읽혀 `UnknownFormatConversionException`(500)이 났다. 설명 문구에 `%`가 들어가도 깨지지 않게 한다
- `07_inquiry.sql`: 문의 제목을 `[QA] ...` 대신 `QA ...`로 한다 — 이유: 답변 알림 문구가 `[{제목}]에 답변이 달렸어요!`라 `[[QA] ...]`로 겹친다
- `TestQaFixtureControllerIntegrationTest`: 페르소나 상태 검증에 "오늘 제출 시각이 KST 벽시계"인지 확인하는 단언을 추가한다 — 이유: CI는 JVM 기본 시간대가 UTC일 수 있어, `SET LOCAL TIME ZONE`이 스크립트와 같은 트랜잭션에 적용되지 않으면 날짜가 9시간 어긋나는 것을 잡는다. `-Duser.timezone=UTC`로도 통과를 확인했다
- `TestQaFixtureControllerIntegrationTest`: 가드 테스트 `이전_세트_userId를_참조하는_행과_하위_고아_행이_남지_않는다`를 추가한다 — 이유: 리뷰 요청. 유저 참조 컬럼을 `information_schema`에서 동적으로 모아 이전 세트 userId 참조 0건을 확인하고, FK가 없는 하위 테이블(면접 세션 주제, 답안, 피드백, `user_feed`)의 고아 행 0건을 확인한다. QA 접속으로 생기는 `user_daily_activity` 1건을 given에 넣어 그 삭제도 검증한다. 삭제를 빼면 이 테스트가 실패하는 것을 확인했다

## 조사 중 발견 (이번 범위 밖, 보고만)
1. `TestScenarioController.java:80-84`: `new LessonSubmissionSaveRequest(lessonId, FULL_ACCURACY, LEARNING_TIME_SECONDS)`의 인자 순서가 record `(lessonId, learningTime, accuracy)`와 어긋난다. 그래서 정확도 60, 학습 시간 100초로 제출된다
2. `TestScenarioController.java:66`: 챕터 완료 직전 시나리오가 레슨을 1개가 아니라 2개 남긴다. 순서도 `findAll()` 그대로다
3. `sql/seed/dev_seed_users.sql`이 V31 이후 스키마와 맞지 않는다
   - 지금은 정의 테이블이 된 `mission`에 진행 행을 넣어 스크립트 전체가 롤백된다
   - `user_mission`을 만들지 않는다
   - `'2026-S1'` ACTIVE 시즌을 `ON CONFLICT(season_key)`로만 막는다. 그래서 오늘 달력 시즌 `2026-S3`가 ACTIVE인 DB에서는 ACTIVE 시즌이 2건이 되고, `findByStatus(ACTIVE)`가 예외를 던진다
4. `SUSPENDED` 상태를 막는 경로가 없다. 정지 유저도 로그인과 모든 API를 쓸 수 있고 랭킹에도 나온다. `suspended` 페르소나는 관리자 화면의 상태 표시 확인용이 된다
5. 노출 문제: QA 유저(기존 `seed-dev-*`도 마찬가지)가 dev 실사용자 화면에 나온다
   - `user_league`가 있으면 같은 티어와 인접 티어 추천에 나온다
   - 탈퇴하지 않았으면 친구 검색에 나온다. `@qa` 같은 하이픈 사이 조각으로 검색된다
