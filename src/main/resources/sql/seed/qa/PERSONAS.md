# QA 페르소나 데이터셋

gravit-qa의 자동 실행(`auto`)과 수동 QA(`manual`)가 매번 같은 사용자 상태에서 시작하도록 만든 데이터셋이다.
수동으로 실행하지 않는다. 재적재 API만 이 폴더의 SQL을 실행한다.

## 사용법

1. `POST /api/v1/test/fixtures/qa/reload?set={auto|manual}`을 호출한다. 응답 매니페스트에 페르소나별 `userId`가 담긴다
2. `POST /api/v1/test/users/login?userId={userId}`로 토큰을 받는다

```json
{
  "set": "auto",
  "loadedAt": "2026-10-17T14:05:00+09:00",
  "personas": [
    { "personaKey": "learner", "userId": 123, "description": "최근 14일 제출 이력(정답, 오답 혼합), 오답노트, 북마크, 주간 기록" }
  ]
}
```

- `userId`는 재적재마다 바뀐다. 보조 유저는 매니페스트에 넣지 않는다(토큰 발급 대상 아님)
- 다른 세트의 데이터는 건드리지 않는다. 같은 세트를 동시에 재적재하면 409(`QA_FIXTURE_4091`)다

| 응답 | 코드 | 원인 |
|---|---|---|
| 400 | `QA_FIXTURE_4001` | `set`이 auto, manual이 아님 |
| 404 | `SEASON_4041` | ACTIVE 시즌 없음 (시즌 롤오버 자정 직후 등) |
| 409 | `QA_FIXTURE_4091` | 같은 세트 재적재 진행 중 |
| 409 | `QA_FIXTURE_4092` | 리그, 미션 정의, 콘텐츠(챕터 1~3 레슨), 면접 문제 부족 |
| 400 | `DB_4001` | SQL 실행 실패 (스키마 변경으로 데이터셋이 깨진 경우) |

## 식별과 처리 순서

- `provider_id`, `handle`은 `qa-persona-{set}-{key}`, `email`은 `qa-persona-{set}-{key}@gravit.test`다. 보조 유저의 `{key}`는 `aux-NN`이다
- id는 IDENTITY가 발급한다. 연관 행은 이메일로 유저를 찾는다
- 재적재는 다음 순서로 진행한다
  1. 사전 검증
  2. Redis에서 이전 세트의 랭킹 멤버와 정리 예약을 제거
  3. 한 트랜잭션으로 이전 세트 삭제와 `01`~`08` 적재
  4. Redis에 새 랭킹 멤버와 withdrawing 정리 예약을 반영
- 이전 세트 삭제는 탈퇴 7일 뒤 실제 삭제와 같은 SQL(`UserCleanDeletionSql`)을 쓰고, `user_daily_activity`도 함께 지운다
- 모든 시각은 실행 시점 `now()` 기준 상대값이다. API가 `SET LOCAL TIME ZONE 'Asia/Seoul'`을 먼저 실행하므로 `now()`와 `current_date`는 KST다. 지난 날짜의 시각은 그날 20:00으로 고정한다
- 레슨은 챕터 안에서 `unit.display_order`, `lesson.id` 순으로, 면접 문제는 주제별 활성 NORMAL 문제를 `id` 순으로 고른다

| 파일 | 내용 |
|---|---|
| `01_users.sql` | 페르소나 13명, 보조 유저 6명 |
| `02_onboarding.sql` | 온보딩 기본 행 (learning, user_mission, user_league) |
| `03_learning.sql` | learner, streak, chapter-almost, mission의 제출 이력과 파생 값 |
| `04_social.sql` | social과 aux-01, aux-02의 팔로우, 피드, 축하, 알림 |
| `05_league.sql` | league-edge와 aux-03~06의 LP, 리그 이력 |
| `06_interview.sql` | interviewer의 면접 세션 4건 |
| `07_inquiry.sql` | inquirer의 문의, admin의 답변, 답변 알림 |
| `08_account.sql` | withdrawing, suspended, admin 상태 |

## 온보딩 기본 행

`pre-onboarding`을 뺀 전원과 보조 유저 전원이 갖는다.

| 테이블 | 값 |
|---|---|
| `users` | 온보딩 완료, USER, ACTIVE, 프로필 1, 30일 전 가입, 마지막 접속 어제 |
| `learning` | 연속 0일, 정복률 0, 오늘 미학습, 최근 챕터 1 |
| `user_mission` | 오늘 배정, `COMPLETE_LESSON_ONE`, 진행 0 |
| `user_league` | ACTIVE 시즌, LP 0(브론즈 3) |

## 페르소나

| 키 | 상태 | 데이터 |
|---|---|---|
| `pre-onboarding` | 온보딩 전 | 유저 행만 있다. 학습, 미션, 리그 행 없음 |
| `fresh` | 온보딩 직후 | 기본 행만 있다 |
| `learner` | 학습 진행 중 | 챕터 1 앞 레슨 10개를 D-13, 12, 10, 9, 7, 6, 4, 3, 2, 1일에 하루 1개 제출. 3, 6, 9번째 레슨은 문제 2개 오답(정확도 67). 문제 제출 60, 오답 노트 6, 북마크 3, 일별 기록 10일. 연속 4일, 오늘 미학습, XP와 LP 179(레벨 2, 브론즈 2) |
| `streak` | 연속 학습 6일 | 챕터 2 앞 레슨 6개를 D-6~D-1에 하루 1개 제출. 오늘 새 레슨 1개를 풀면 7일이 되어 STREAK_DAYS 피드가 생긴다. XP와 LP 120(레벨 2, 브론즈 2) |
| `chapter-almost` | 챕터 마지막 레슨 직전 | 챕터 1 레슨을 마지막 유닛의 id 최대 레슨 1개만 빼고 D-2에 모두 제출. 진행률 98, 마지막 유닛 진행 중. XP와 LP 1640(레벨 7, 플래티넘 3) |
| `social` | 팔로우, 피드 보유 | 아래 "social" 참고. XP 100(레벨 2), LP 5 |
| `league-edge` | 승급 경계 | 실버 2(461~620)에 LP 615. 같은 리그에 aux-03 620, aux-04 618, aux-05 540, aux-06 470. 정확도 28% 이상인 신규 레슨 1개로 실버 1 승급. 가장 최근 CLOSED 시즌이 있으면 리그 이력 1건(최종 실버 1, LP 700, 순위 2) |
| `mission` | 미션 완료 직전 | 오늘 챕터 3 첫 레슨 1개 제출. 미션 `COMPLETE_LESSONS_TWO` 진행 1/2라 신규 레슨 1개로 완료(+15 XP). 연속 1일, 오늘 학습함, XP와 LP 20 |
| `interviewer` | 면접 이력 보유 | 아래 "interviewer" 참고. XP와 LP 17(완료 보상) |
| `inquirer` | 문의 답변 완료 | RESOLVED 문의(D-2 접수)와 admin 답변(D-1), 답변 알림 1. PENDING 문의 1(1시간 전) |
| `withdrawing` | 탈퇴 유예 중 | DELETED, 탈퇴 시각 = 적재 시각, 핸들 반납. 랭킹에서 빠지고 `user:clean:due`에 7일 뒤 정리로 예약된다 |
| `suspended` | 정지 | status SUSPENDED |
| `admin` | 관리자 | role ADMIN. inquirer 문의의 답변자 |

### social

aux-01은 맞팔로우, aux-02는 단방향 팔로워다.

| 테이블 | 행 |
|---|---|
| `friends` | social→aux-01, aux-01→social, aux-02→social |
| `social_feed` | social LEVEL_UP `2`(D-1), aux-01 STREAK_DAYS `7`(D-1), aux-01 TIER_PROMOTION `브론즈 2`(D-2) |
| `user_feed` | social 피드 → aux-01, aux-02 / aux-01 피드 2건 → social |
| `congratulation` | aux-01 → social LEVEL_UP(D-1) / social → aux-01 TIER_PROMOTION(D-2) |
| `notification` (social 수신) | FOLLOW ← aux-01(버튼 없음), FOLLOW ← aux-02(맞팔로우 버튼), FRIEND_ACTIVITY 2, CONGRATULATION ← aux-01 |

- social의 피드에서 aux-01 STREAK는 축하할 수 있고, aux-01 TIER는 이미 축하한 상태다. 보낸 축하는 D-2라서 오늘 한도(상대당 3회)에 들어가지 않는다
- aux-01은 LP 155(브론즈 2)다

### interviewer

TEXT 입력, NORMAL, 만점 70/15/15다.

| 차수 | 상태 | 시각 | 모드, 주제 | 답안, 피드백 |
|---|---|---|---|---|
| 1 | COMPLETED | D-3 20:00, 15분 | COMMON_CS, DATA_STRUCTURE 3 + NETWORK 2 | 1~4번 답변, 5번 무응답. 정확도 14/12/9/5/0, 구조+명료 6/5/4/2/0, 총점 57. 4번, 5번이 약점 |
| 2 | GRADING_FAILED | D-2 20:00 | 1차와 같음 | 5문항 답변, 피드백 없음 |
| 3 | GRADING | D-1 20:00 | 1차와 같음 | 5문항 답변, 피드백 없음. 자동으로 처리하는 경로가 없어 계속 채점 중이다 |
| 4 | IN_PROGRESS | 적재 10분 전 | JOB_SPECIFIC, JAVA_SPRING_BOOT | 5문항 미제출 |

## 사용 시 주의

- 날짜에 묶인 상태는 적재한 KST 날짜에만 맞다
  - 자정(00:00)에 새 미션이 배정되어 `mission`의 진행이 사라진다
  - 00:01 정산에서 오늘 학습하지 않은 연속 일수가 0이 된다
  - 실행 직전에 재적재하고, 00:00~00:02 사이의 재적재는 피한다
- `withdrawing`은 탈퇴 상태라 `users/login`이 404다. 복구는 `PATCH /api/v1/users/restore?providerId=qa-persona-{set}-withdrawing`으로 하고, 복구한 뒤에는 같은 userId로 토큰을 받을 수 있다
- `league-edge`로 시즌 결과·시작 팝업을 보려면 `POST /api/v1/test/season/popup?userId={league-edge userId}`를 먼저 부른다. 가장 최근 CLOSED 시즌을 Redis `lastClosedSeasonId`로 기록하고 그 유저의 `season:seen` 키를 지우므로, 다음 `GET /api/v1/league/home`이 `containsPopup=true`를 준다(한 번 본 뒤 다시 보려면 또 부른다). 배치가 남기는 캐시가 없어도 되고 다른 유저에게 영향이 없다
- `suspended`를 막는 서버 경로가 없다. 정지 상태여도 로그인과 모든 API를 쓸 수 있으므로 관리자 화면의 상태 표시 확인용이다
- `interviewer`의 IN_PROGRESS 세션을 제출하면 실제 LLM 채점이 돌고 XP와 LP가 지급된다
- QA 유저는 dev 실사용자의 친구 검색, 추천(같은 티어와 인접 티어)에 나온다
- 재적재 요청이 클라이언트 타임아웃으로 끊겨도 서버에서는 계속 진행된다. 이때 바로 재시도하면 409를 받을 수 있다

## 유지보수

- 스키마가 바뀌면 `TestQaFixtureControllerIntegrationTest`(Flyway 마이그레이션 → 콘텐츠 적재 → 재적재 → 매니페스트와 상태 검증)가 깨져 알려준다
- `ScriptUtils`로 실행하므로 `sql/README.md`의 작성 주의를 따른다. 문자열 안의 줄이 `--`로 시작하면 안 되고, 따옴표 앞에 백슬래시를 쓰면 안 된다
