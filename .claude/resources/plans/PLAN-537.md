# [PLAN-537] 면접 완료 시 XP, 리그 점수 지급

> 이슈: #537
> 브랜치: feat/537-interview-reward (base: dev)
>
> **착수 시점 작업 트리에 커밋되지 않은 변경이 있고, 그대로는 컴파일되지 않는다.** `UserLeaguePointService.addLeaguePoints` → `addLeaguePointsForLesson` 개명이 호출부 3곳 중 `UserLeagueEventListener` 1곳에만 반영됐다. `LeaguePointRetryTarget:46`, `SocialFacade:107`, 테스트 8곳(`UserLeaguePointServiceIntegrationTest` 7곳, `UserLeagueEventListenerIntegrationTest:190`)이 옛 이름을 부른다. 이 계획은 개명을 유지하고 나머지 호출부를 절 3에서 정리한다.
>
> **#536(레슨 제출 응답에 레벨업, 승급 여부)은 브랜치만 있고 커밋과 계획서가 없다.** `feat/536-lesson-levelup-promotion-flags`가 이 브랜치와 같은 커밋(`f7fc2a3e`)을 가리킨다. 이슈가 "#536과 맞춤"이라 한 레벨업, 승급 처리는 맞출 대상이 아직 없으므로, 이번 이슈는 피드 이벤트까지만 맞추고 클라이언트 노출은 #536 뒤로 미룬다 (D3).

## 목표

면접 세션이 채점 완료(COMPLETED)되면 세션 점수에 비례한 XP와 리그 점수를 지급해, 면접 학습도 레벨과 리그에 반영되게 한다. 레벨업과 티어 승급은 레슨과 같은 소셜 피드 이벤트로 이어진다.

API 계약 변경은 없다. 채점은 제출 응답 뒤 백그라운드에서 끝나므로 보상도 응답과 무관하게 지급된다.

## 배치 기준

- **보상은 채점 완료 트랜잭션 밖에서 지급한다 (D3).** `facade.md`의 판정 질문 "채점 완료는 커밋됐는데 보상이 실패한 상태를 사용자가 봐도 되는가"에 답이 "된다"이므로 보상은 계층 2(보정 가능한 파생)다. 반대로 XP를 완료 트랜잭션에 넣으면 XP 실패가 피드백 5건 저장까지 롤백시키고, `InterviewGradingFacade.grade()`의 catch가 세션을 GRADING_FAILED로 보낸다. 채점 실패 세션은 복구 경로가 없다(P2). LLM 5회 호출로 만든 결과를 보상 때문에 잃게 된다
- **레슨 XP가 제출 트랜잭션 안에 있는 것과 다른 이유.** `learning.md`가 "결과 화면의 레벨과 XP는 제출 트랜잭션에서 함께 커밋되므로 이번 제출이 항상 반영되어 있다"를 보장하기 때문이다. 면접은 채점이 비동기라 결과를 실을 동기 응답이 없고, 레벨을 보여주는 면접 화면도 없다. 트랜잭션에 끌어들일 이유가 없다
- **이벤트는 `InterviewSessionCommandService.completeGrading()`이 발행한다.** 제출이 `submit()` 안에서 `InterviewSubmittedEvent`를 발행하는 것과 같은 자리다. COMPLETED 전이와 보상 발행이 한 메서드에 묶여, 나중에 재채점(P2)이 생겨도 완료 경로가 보상을 빠뜨리지 않는다. `completeGrading()`은 Facade의 `TransactionTemplate` 경계 안에서 호출되므로 이벤트는 피드백 5건과 COMPLETED가 커밋된 뒤에 나간다 (`facade.md` "이벤트 발행은 반드시 경계 안에서 하라")
- **지급량은 한 곳(`interview/policy/InterviewRewardPolicy`)에서 계산하고, 이벤트는 확정된 양만 싣는다.** 레슨은 이벤트가 기본 점수 20과 정답률을 싣고 `UserService`와 `UserLeaguePointService`가 각자 `round(점수 × 정답률 × 0.01)`를 계산한다. 산식이 두 도메인에 복제돼 있다. 면접은 그 구조를 따르지 않는다. user, userLeague 도메인은 "몇 점을 더한다"만 알고 면접 산식을 모른다
- **정책은 `interview/`에 둔다.** 입력(세션 점수, 세션 만점)이 전부 `InterviewSession`에 있고 호출자도 `interview/service`다. `interviewFeedback/policy/InterviewScoringPolicy`는 문항 판정에서 점수를 만드는 일이라 성격이 다르다. 의존 방향 `interviewFeedback -> interview -> interviewQuestion`도 지킨다
- **점수를 더하는 API는 확정된 양을 받는 범용 메서드로 연다.** `UserService.addXp(userId, xp)`, `UserLeaguePointService.addLeaguePoints(userId, earnedPoints)`. 작업 트리의 개명(`addLeaguePointsForLesson`)은 유지해 정답률 비율을 적용하는 레슨 전용 진입점으로 두고, 범용 진입점을 그 옆에 세운다
- **축하 LP는 범용 메서드로 옮긴다.** `SocialFacade`는 지금 `addLeaguePoints(actorId, 5, 100)`으로 정답률 100%를 흉내 내 5점을 준다. 개명 후 `addLeaguePointsForLesson`을 부르게 두면 축하가 레슨처럼 읽힌다. `addLeaguePoints(actorId, CONGRATULATION_LP)`로 바꾸고 `FULL_ACCURACY` 상수를 지운다. 지급량은 같다
- **레벨업 판정은 한 곳에 둔다.** `UserService`의 레슨 경로(`updateUserLevelAndXp`)에서 조회 → XP 누적 → 레벨 비교 → `LevelUpFeedEvent` 발행 부분을 private `applyXp`로 뽑아 레슨과 면접이 함께 쓴다. 면접으로 레벨이 올라도 피드에 올라간다(`friend-social.md` "소셜 피드에 올라가는 활동은 ... 레벨업"). #536이 같은 메서드에서 레벨업 여부를 꺼내게 되므로 머지 순서에 따라 충돌이 난다. 뽑아 둔 `applyXp`가 #536의 판정 지점이 되면 면접 경로도 판정을 함께 얻는다
- **티어 승급은 새로 할 일이 없다.** `UserLeaguePointService`가 이미 승급 시 `TierPromotionFeedEvent`, 점수 변경 시 `LeagueRankChangedEvent`를 발행한다. 범용 메서드가 같은 본문을 타면 면접 LP도 피드와 랭킹 동기화를 그대로 얻는다
- **XP와 LP는 리스너도 재시도 큐도 따로다.** 보상은 각각 독립 커밋, 독립 재시도한다(`facade.md` "보상의 실제 성질"). LP는 기존 `UserLeagueEventListener`에 메서드를 더하고, XP는 user 도메인에 리스너가 없어 `user/listener/UserEventListener`를 새로 만든다. 두 서비스 메서드 모두 `REQUIRES_NEW`다. AFTER_COMMIT 리스너에서 기본 전파로 부르면 이미 커밋된 트랜잭션에 참여해 변경이 커밋되지 않는다(`MissionService:59` 주석과 같은 이유)
- **기존 `league-points-retry` 큐를 재사용하지 않는다.** 그 큐의 페이로드는 `{userId, points, accuracy}`이고 대상이 레슨 전용 진입점을 부른다. `accuracy=100`을 실어 넣으면 동작은 하지만 면접 실패가 레슨 큐에 섞이고, 축하 LP에서 걷어내는 정답률 흉내를 새로 하나 더 만드는 셈이다. `league-points-interview-retry`, `user-xp-interview-retry` 두 큐를 새로 연다
- **Facade는 손대지 않는다.** `InterviewGradingFacade.save()`가 이미 `completeGrading()`을 경계 안에서 부르므로 발행이 서비스 안이면 Facade 변경이 없다. 새 Facade도 만들지 않는다. 보상을 도메인별로 나눠 받는 쪽은 리스너이고, 호출되는 서비스는 각자 단일 도메인이다
- **반복 지급 제한은 두지 않는다 (D2).** 완료 세션마다 지급한다. 반복 수령 대응은 미결 과제(P16)로 미룬다
- **DB 변경 없음.** 보상 판정은 `completeGrading()`이 이미 불러온 세션의 점수와 만점만 쓰고 추가 조회가 없다

## 영향 범위

### 신규 파일

**main**
- `src/main/java/gravit/code/global/event/InterviewCompletedEvent.java` - 보상 이벤트 `{ userId, sessionId, rewardPoints }`
- `src/main/java/gravit/code/interview/policy/InterviewRewardPolicy.java` - 지급량 산식
- `src/main/java/gravit/code/user/listener/UserEventListener.java` - 면접 완료 XP 지급, 실패 시 재시도 큐 적재
- `src/main/java/gravit/code/user/infrastructure/UserXpInterviewRetryTarget.java` - `user-xp-interview-retry` 재처리
- `src/main/java/gravit/code/userLeague/infrastructure/LeaguePointInterviewRetryTarget.java` - `league-points-interview-retry` 재처리

**test**
- `src/test/java/gravit/code/interview/policy/InterviewRewardPolicyIntegrationTest.java`
- `src/test/java/gravit/code/user/listener/UserEventListenerIntegrationTest.java`
- `src/test/java/gravit/code/user/infrastructure/UserXpInterviewRetryTargetIntegrationTest.java`
- `src/test/java/gravit/code/userLeague/infrastructure/LeaguePointInterviewRetryTargetIntegrationTest.java`

### 수정 파일

**main**
- `src/main/java/gravit/code/userLeague/service/UserLeaguePointService.java` - 범용 `addLeaguePoints(long, int)` 추가, 본문을 private `applyLeaguePoints`로 추출 (개명 `addLeaguePointsForLesson`은 작업 트리 그대로 유지)
- `src/main/java/gravit/code/userLeague/listener/UserLeagueEventListener.java` - `handleInterviewCompleted` 추가, 재시도 불가 판정을 `isNonRetryable`로 추출 (레슨 호출부 개명은 작업 트리에 이미 있음)
- `src/main/java/gravit/code/userLeague/infrastructure/LeaguePointRetryTarget.java` - `addLeaguePointsForLesson` 호출로 수정 (개명 누락 복구)
- `src/main/java/gravit/code/social/facade/SocialFacade.java` - 축하 LP를 범용 `addLeaguePoints(actorId, CONGRATULATION_LP)`로 변경, `FULL_ACCURACY` 삭제
- `src/main/java/gravit/code/user/service/UserService.java` - `addXp(long, int)` 추가, 레벨업 판정을 private `applyXp`로 추출
- `src/main/java/gravit/code/interview/service/InterviewSessionCommandService.java` - `completeGrading`에서 보상 이벤트 발행, `InterviewRewardPolicy` 주입

**test**
- `src/test/java/gravit/code/interviewFeedback/facade/InterviewGradingFacadeIntegrationTest.java` - 보상 시나리오 추가
- `src/test/java/gravit/code/interview/service/InterviewSessionCommandServiceIntegrationTest.java` - 보상 발행 시나리오 추가
- `src/test/java/gravit/code/userLeague/service/UserLeaguePointServiceIntegrationTest.java` - 7곳 `addLeaguePointsForLesson`, 범용 메서드 시나리오 추가
- `src/test/java/gravit/code/userLeague/listener/UserLeagueEventListenerIntegrationTest.java` - 190행 스텁 개명, 면접 완료 수신 시나리오 추가
- `src/test/java/gravit/code/user/service/UserServiceIntegrationTest.java` - `addXp` 시나리오 추가

**정책**
- `.claude/spec/service-policy/interview.md` - "완료 보상" 절 신설, 미결 과제 P15, P16 추가
- `.claude/spec/service-policy/user.md` - XP 획득 경로에 면접 완료 추가
- `.claude/spec/service-policy/league-season.md` - 리그 점수 획득 경로에 면접 완료와 축하 수신 추가
- `.claude/spec/service-policy/friend-social.md` - 축하 수신 5 LP 명시

> **DB 변경 없음.** 엔티티와 마이그레이션을 건드리지 않는다.
>
> **정책 변경 있음.** `user.md`의 "XP를 얻는 경로는 레슨 첫 제출과 미션 완료 두 가지다", `league-season.md`의 "리그 점수는 레슨 첫 제출에서만 오른다"를 바꾸는 작업이다.
>
> **정책과 코드 불일치 정리.** `league-season.md:9`는 리그 점수가 레슨 첫 제출에서만 오른다고 적지만, 코드는 피드 축하를 받은 사용자에게 5 LP를 지급한다(`SocialFacade:107`, #358부터, `SocialFacadeIntegrationTest.축하받은_유저에게_5LP가_지급된다`로 고정). `friend-social.md`에도 축하 LP가 없다. 배포된 동작을 문서에 옮겨 적는다 (D4). 코드 동작은 바뀌지 않는다.

## 구현 계획

### 1. Entity / Flyway

변경 없음. `InterviewSession`의 기존 `getUserId()`, `getScore()`, `getMaxScore()`를 그대로 쓴다.

### 2. Repository

변경 없음.

### 3. Service

**`userLeague/service/UserLeaguePointService`** (수정)

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void addLeaguePointsForLesson(
        Long userId,
        int points,
        int accuracy
)
    // applyLeaguePoints(userId, (int) Math.round(points * accuracy * 0.01))

@Transactional(propagation = Propagation.REQUIRES_NEW)
public void addLeaguePoints(
        long userId,
        int earnedPoints
)
    // applyLeaguePoints(userId, earnedPoints)

private void applyLeaguePoints(
        long userId,
        int earnedPoints
)
    // 기존 본문 그대로
    // findByUserId -> USER_LEAGUE_NOT_FOUND
    // userLeague.addLeaguePoints(earnedPoints) -> findByLpBetween -> LEAGUE_NOT_MATCH_LEAGUE_POINT
    // 승급 판정, updateLeagueIfDifferent, LeagueRankChangedEvent 발행, 승급이면 TierPromotionFeedEvent 발행
```

레슨 산식(`Math.round(... * 0.01)`)은 그대로 둔다. 두 public 메서드가 서로를 부르지 않고 private 메서드를 공유한다. 같은 빈 안의 호출은 프록시를 거치지 않아 전파 속성이 적용되지 않는데, private 공유로 두면 그 사실에 기댈 일이 없다.

**`userLeague/infrastructure/LeaguePointRetryTarget`** (수정)

- `reprocess`: `pointService.addLeaguePoints(userId, points, accuracy)` → `pointService.addLeaguePointsForLesson(userId, points, accuracy)`. 개명 누락으로 깨진 컴파일을 복구한다. 큐 키와 페이로드는 그대로다

**`social/facade/SocialFacade`** (수정)

- `congratulateFeed`: `userLeaguePointService.addLeaguePoints(actorId, CONGRATULATION_LP, FULL_ACCURACY)` → `userLeaguePointService.addLeaguePoints(actorId, CONGRATULATION_LP)`
- `private static final int FULL_ACCURACY = 100;` 삭제. 지급량은 `round(5 × 100 × 0.01) = 5`와 같다

**`user/service/UserService`** (수정)

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void addXp(
        long userId,
        int xp
)
    // applyXp(userId, xp)

private UserLevelResponse updateUserLevelAndXp(
        long userId,
        int xp,
        int accuracy
)
    // return applyXp(userId, (int) Math.round(xp * accuracy * 0.01))

private UserLevelResponse applyXp(
        long userId,
        int earnedXp
)
    // 기존 updateUserLevelAndXp 본문
    // findById -> USER_NOT_FOUND
    // oldLevel -> user.getLevel().updateXp(earnedXp) -> newLevel
    // newLevel > oldLevel 이면 LevelUpFeedEvent(userId, newLevel) 발행
    // return UserLevelResponse.create(newLevel, user.getLevel().getXp())
```

`addXp`는 `void`다. 리스너와 재시도 대상 누구도 반환값을 쓰지 않는다. `User`가 `@SQLRestriction("deleted_at IS NULL")`이라 채점 중 탈퇴한 사용자는 `USER_NOT_FOUND`가 된다.

`MissionService.awardMissionXp`는 이 메서드로 옮기지 않는다. 미션 서비스는 다른 도메인 서비스를 부를 수 없고(`service.md`), 미션 XP의 레벨업 판정 누락은 #536의 "미션 완료 보상 XP로 인한 레벨업 포함 여부 결정" 과제다.

**`interview/policy/InterviewRewardPolicy`** (`@Component`, 신규)

```java
private static final BigDecimal BASE_REWARD_POINTS = BigDecimal.valueOf(30);
private static final int REWARD_SCALE = 0;

public int calculate(
        int score,
        int maxScore
)
    // BASE_REWARD_POINTS.multiply(BigDecimal.valueOf(score))
    //         .divide(BigDecimal.valueOf(maxScore), REWARD_SCALE, RoundingMode.HALF_UP)
    //         .intValue()
```

곱한 뒤 한 번만 나누며 반올림하므로 중간 오차가 없다. `InterviewScoringPolicy`와 같은 `BigDecimal` + `HALF_UP`이다. `maxScore`는 세션 스냅샷(100)이라 0이 될 수 없다. 기본값 30에 만점 100이면 점수 끝자리가 5일 때 소수부가 .5가 되고(5점 → 1.5, 15점 → 4.5), `HALF_UP`이 올린다. 레슨의 `Math.round`도 양수에서 같은 결과다.

**`interview/service/InterviewSessionCommandService`** (수정)

```java
private static final int NO_REWARD = 0;

private final InterviewAudioKeyPolicy interviewAudioKeyPolicy;
private final InterviewRewardPolicy interviewRewardPolicy;      // policy 그룹에 추가

@Transactional
public void completeGrading(
        long sessionId,
        int accuracyScore,
        int deliveryScore
) {
    InterviewSession session = findSession(sessionId);

    session.completeGrading(accuracyScore, deliveryScore);

    publishReward(session);
}

private void publishReward(InterviewSession session)
    // int rewardPoints = interviewRewardPolicy.calculate(session.getScore(), session.getMaxScore())
    // if (rewardPoints == NO_REWARD) return
    //
    // publisher.publishEvent(InterviewCompletedEvent.of(session.getUserId(), session.getId(), rewardPoints))
```

- **보상이 0이면 발행하지 않는다.** 5문항 모두 무응답이면 세션 점수가 0이고, 1점도 반올림으로 0이 된다. 레슨은 정답률 0%여도 이벤트를 발행해 0점을 더하는데, 그러면 LP가 그대로인데도 `LeagueRankChangedEvent`가 나가 랭킹 저장소 쓰기가 한 번 생긴다. 면접은 발행 자체를 막는다
- 점수 범위 검증은 엔티티의 `completeGrading()`이 먼저 하므로, 여기까지 오면 점수는 0 이상 만점 이하다

### 4. Event / Listener / Retry

**`global/event/InterviewCompletedEvent`** (신규)

```java
@Builder(access = AccessLevel.PRIVATE)
public record InterviewCompletedEvent(
        long userId,
        long sessionId,
        int rewardPoints
) {
    public static InterviewCompletedEvent of(
            long userId,
            long sessionId,
            int rewardPoints
    )
}
```

`global/event/`에 둔다. 소비자가 user, userLeague 두 도메인이라 `LessonCompletedEvent`와 같은 자리다. `InterviewSubmittedEvent`가 `interview/dto/event/`에 있는 것은 소비자가 면접 쪽(`interviewFeedback`) 하나이기 때문이다. 생성은 `InterviewSubmittedEvent`처럼 private `@Builder` + `of`다.

`sessionId`는 지급에 쓰지 않는다. 리스너 실패 로그에 남겨 어느 세션의 보상이 유실됐는지 추적하는 용도다. 재시도 페이로드에는 싣지 않는다.

**`userLeague/listener/UserLeagueEventListener`** (추가)

```java
@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
public void handleInterviewCompleted(InterviewCompletedEvent event)
    // try: pointService.addLeaguePoints(event.userId(), event.rewardPoints())
    // catch RestApiException e:
    //     isNonRetryable(e) -> log.error("면접 완료 리그 포인트 반영 실패(재시도 불가, 확인 필요): userId={}, sessionId={}, errorCode={}", ...) return
    //     그 외 -> queueInterviewLeaguePointsRetry(event, e)
    // catch Exception e -> queueInterviewLeaguePointsRetry(event, e)

private void queueInterviewLeaguePointsRetry(
        InterviewCompletedEvent event,
        Exception cause
)
    // log.error("면접 완료 리그 포인트 반영 실패, 재시도 큐 적재: userId={}, sessionId={}", ...)
    // retryEventPublisher.publish("league-points-interview-retry", Map.of(
    //         "userId", String.valueOf(event.userId()),
    //         "points", String.valueOf(event.rewardPoints())))

private boolean isNonRetryable(RestApiException e)
    // USER_LEAGUE_NOT_FOUND || LEAGUE_NOT_MATCH_LEAGUE_POINT
```

`handleLessonCompleted`의 같은 조건도 `isNonRetryable`로 바꾼다. `MissionEventListener.isNonRetryable`과 같은 모양이다. 큐 키와 필드명은 기존 리스너, 재시도 대상 쌍처럼 문자열 리터럴로 쓴다.

**`userLeague/infrastructure/LeaguePointInterviewRetryTarget`** (`RetrySweepTarget`, 신규)

```java
private static final int MAX_ATTEMPTS = 10;
private static final Set<ErrorCode> NON_RETRYABLE_ERRORS = Set.of(
        CustomErrorCode.USER_LEAGUE_NOT_FOUND,
        CustomErrorCode.LEAGUE_NOT_MATCH_LEAGUE_POINT
);

private final UserLeaguePointService pointService;

public String queueKey()     // "league-points-interview-retry"
public int maxAttempts()     // MAX_ATTEMPTS
public void reprocess(Map<String, String> fields)
    // userId = Long.valueOf(fields.get("userId")), points = Integer.parseInt(fields.get("points"))
    // pointService.addLeaguePoints(userId, points)
    // RestApiException이 NON_RETRYABLE_ERRORS -> log.error("면접 완료 리그 포인트 반영 실패(재시도 불가, 확인 필요), 재시도 종료: ...") return
    // 그 외 rethrow
```

`LeaguePointRetryTarget`과 같은 모양이다.

**`user/listener/UserEventListener`** (`@Component`, 신규)

```java
private final UserService userService;
private final RetryEventPublisher retryEventPublisher;

@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
public void handleInterviewCompleted(InterviewCompletedEvent event)
    // try: userService.addXp(event.userId(), event.rewardPoints())
    // catch RestApiException e:
    //     USER_NOT_FOUND -> log.error("면접 완료 XP 지급 실패(재시도 불가, 확인 필요): userId={}, sessionId={}, errorCode={}", ...) return
    //     그 외 -> queueInterviewXpRetry(event, e)
    // catch Exception e -> queueInterviewXpRetry(event, e)

private void queueInterviewXpRetry(
        InterviewCompletedEvent event,
        Exception cause
)
    // log.error("면접 완료 XP 지급 실패, 재시도 큐 적재: userId={}, sessionId={}", ...)
    // retryEventPublisher.publish("user-xp-interview-retry", Map.of(
    //         "userId", String.valueOf(event.userId()),
    //         "xp", String.valueOf(event.rewardPoints())))
```

**`user/infrastructure/UserXpInterviewRetryTarget`** (`RetrySweepTarget`, 신규)

```java
private static final int MAX_ATTEMPTS = 10;

private final UserService userService;

public String queueKey()     // "user-xp-interview-retry"
public int maxAttempts()     // MAX_ATTEMPTS
public void reprocess(Map<String, String> fields)
    // userId = Long.valueOf(fields.get("userId")), xp = Integer.parseInt(fields.get("xp"))
    // userService.addXp(userId, xp)
    // RestApiException이 USER_NOT_FOUND -> log.error("면접 완료 XP 지급 실패(재시도 불가, 확인 필요), 재시도 종료: ...") return
    // 그 외 rethrow
```

XP와 LP 리스너의 실행 순서는 보장하지 않는다. 서로의 결과에 기대지 않으므로 순서가 필요 없다. 리스너는 채점 실행기 스레드(`interviewGradingAsync`)에서 `TransactionTemplate` 커밋 직후 동기로 돈다. 리스너 예외는 스프링이 삼키고 두 리스너 모두 스스로 잡으므로, 보상 실패가 `grade()`의 catch에 닿아 세션을 GRADING_FAILED로 보내는 경로는 없다.

### 5. Facade

불필요 - `InterviewGradingFacade`는 변경 없음. 보상 발행은 `completeGrading()` 안이고, 도메인별 지급은 리스너가 나눠 받는다. 이유는 배치 기준에 적었다.

### 6. DTO

신규, 변경 없음. 이벤트 record는 절 4에 적었다.

### 7. Controller

변경 없음. API 계약, Swagger 문서도 변경 없음.

### 8. 정책 문서

**`interview.md`** - "채점 실패" 절 다음에 "## 완료 보상" 절 신설

- 세션이 완료(COMPLETED)되면 XP와 리그 점수를 같은 양 지급한다. 채점 중, 채점 실패, 취소 세션은 지급하지 않는다
- 지급량은 `30 × 세션 점수 ÷ 세션 만점`을 반올림한 값이다. 만점은 세션의 스냅샷 값이다
- 지급량이 0이면 지급하지 않는다. 5문항 모두 무응답인 세션이 여기 해당한다
- 완료 세션마다 지급한다. 같은 날 여러 번 완료해도 횟수 제한은 없다. 반복 수령 제한은 미결 과제(P16)다
- 보상은 채점 결과와 따로 확정된다. 지급이 실패해도 세션은 완료로 남고 지급은 재시도로 메운다
- 레벨이나 리그 티어가 오르면 소셜 피드에 올라간다. 피드 규칙은 `friend-social.md`를 따른다
- 레벨업, 승급 결과를 면접 화면에 알리지 않는다. 노출 방식은 미결 과제(P15)다

미결 과제 표에 두 줄 추가

| ID | 과제 | 현재 기본값 |
|------|------|------|
| P15 | 면접 보상의 레벨업, 승급 결과 노출 | 노출 안 함. 피드에만 올라간다. 레슨 제출(#536)의 판정 방식이 정해진 뒤 맞춘다 |
| P16 | 면접 보상 반복 수령 제한 | 없음. 완료 세션마다 지급한다 |

**`user.md:9`**

- 변경 전: XP를 얻는 경로는 레슨 첫 제출과 미션 완료 두 가지다. 지급량은 `learning.md`와 `mission.md`를 따른다
- 변경 후: XP를 얻는 경로는 레슨 첫 제출, 미션 완료, 면접 완료 세 가지다. 지급량은 `learning.md`, `mission.md`, `interview.md`를 따른다

**`league-season.md:9`**

- 변경 전: 리그 점수는 레슨 첫 제출에서만 오른다. 지급량 산식은 `learning.md`를 따른다
- 변경 후: 리그 점수는 레슨 첫 제출, 면접 완료, 소셜 피드 축하 수신에서 오른다. 지급량은 `learning.md`, `interview.md`, `friend-social.md`를 따른다

**`friend-social.md`** - 축하 제한 줄 다음에 추가

- 축하를 받은 사용자는 축하 1회당 리그 점수 5점을 받는다. 축하를 보낸 사용자는 받지 않는다

### 9. 커밋 순서

1. `docs: 면접 완료 보상 정책 확정과 구현 계획서 추가(#537)` - 정책 4파일, PLAN-537
2. `refactor: XP와 리그 점수 지급에 확정량 진입점 추가(#537)` - `UserLeaguePointService` 개명과 범용 메서드, `LeaguePointRetryTarget`, `SocialFacade`, `UserLeagueEventListener`의 레슨 호출부 개명과 `isNonRetryable` 추출, `UserService.addXp`/`applyXp`, 기존 테스트 8곳 개명 반영. **작업 트리의 미커밋 개명이 이 커밋에 들어간다.** 이 커밋 단독으로 빌드가 통과해야 한다
3. `feat: 면접 완료 시 XP, 리그 점수 지급(#537)` - 이벤트, 보상 정책, `completeGrading` 발행, 리스너 2개, 재시도 대상 2개
4. `test: 면접 완료 보상 통합 테스트 추가(#537)` - 신규 시나리오

정책 문서를 맨 앞에 둔다. 리뷰어가 3번 커밋의 산식을 볼 때 근거가 이미 저장소에 있어야 한다.

## 결정 필요 (Decisions needed)

- [x] **D1 지급량 산식** - `round(30 × 세션 점수 ÷ 세션 만점)`, XP와 LP 같은 양. 사용자 지정 값이다(제안안은 20, 50). 만점 면접 1회가 30으로 만점 레슨 1회(20)보다 크고, 레벨 1→2 구간(100 XP)의 30%다
- [x] **D2 반복 지급 제한** - 제한 없음. 완료 세션마다 지급한다. 반복 수령 대응은 `interview.md` 미결 과제 P16으로 남긴다
- [x] **D3 XP 지급 경계와 레벨업, 승급 노출** - COMPLETED 커밋 후 이벤트로 XP, LP를 각각 지급하고 실패하면 재시도 큐에 넣는다. 레벨업, 승급은 피드로만 나가고 클라이언트 노출은 #536 결정 후 맞춘다(P15)
- [x] **D4 축하 LP 문서 불일치** - 배포된 동작을 문서에 옮긴다. `league-season.md` 지급 경로에 축하 수신을 넣고 5 LP는 `friend-social.md`에 적는다

## 검증

모두 `@TCSpringBootTest` 통합 테스트다. Docker(Testcontainers)가 필요하다.

**픽스처**

- 새 픽스처 없음. 세션은 기존 `InterviewSessionFixture.상태_세션`, 유저와 리그는 `UserFixture`, `LeagueFixture`, `SeasonFixture`, `UserLeagueFixture`를 쓴다
- XP가 있는 유저는 `userFixture.일반_유저(n)` 뒤 `ReflectionTestUtils.setField(user, "level", UserLevel.create(1, 90), UserLevel.class)`로 만든다 (`test-convention.md` VO 규칙)

**기존 테스트 수정과 회귀**

- `UserLeaguePointServiceIntegrationTest` 7곳, `UserLeagueEventListenerIntegrationTest:190` → `addLeaguePointsForLesson`
- `SocialFacadeIntegrationTest.축하받은_유저에게_5LP가_지급된다` → 수정 없이 통과해야 한다 (시그니처 변경 회귀)
- `InterviewGradingFacadeIntegrationTest` 기존 7건 → 수정 없이 통과해야 한다. `USER_ID = 1` 유저 행이 없어 완료 3건에서 XP 리스너는 `USER_NOT_FOUND`, LP 리스너는 `USER_LEAGUE_NOT_FOUND`로 로그만 남긴다. 세션 상태 단언이 그대로 통과하는 것이 곧 "보상 실패가 채점 결과에 닿지 않는다"는 회귀 확인이다
- `InterviewSessionCommandServiceIntegrationTest.CompleteGrading` 기존 4건 → 수정 없이 통과해야 한다

**`InterviewRewardPolicyIntegrationTest`** (`@Nested` "지급량을 계산할 때")

- 100점 → 30, 0점 → 0, 60점 → 18, 80점 → 24
- 반올림: 1점 → 0(0.3), 2점 → 1(0.6), 5점 → 2(1.5), 15점 → 5(4.5), 57점 → 17(17.1), 59점 → 18(17.7)

**`InterviewSessionCommandServiceIntegrationTest`** (`@Nested` "채점 완료로 전이할 때"에 추가, 클래스에 `@RecordApplicationEvents` - `AdminInquiryServiceIntegrationTest` 선례)

보상 발행 조건은 여기서 이벤트로 검증한다. 유저와 리그를 준비하지 않아도 된다.

- 정확도 56 + 전달력 24 완료 → `InterviewCompletedEvent(userId, sessionId, 24)` 1건 발행
- 0점 완료 → 미발행
- 같은 사용자의 세션 둘을 차례로 완료하면 각각 발행된다 (D2 제한 없음 고정)
- 만점 초과, 채점 중 아님, 없는 세션 → 기존 예외 그대로이고 미발행

**`InterviewGradingFacadeIntegrationTest`** (`@Nested` "채점이 끝나면 보상을" 추가, `UserFixture`, `LeagueFixture`, `SeasonFixture`, `UserLeagueFixture`, `UserRepository`, `UserLeagueRepository` 주입)

실제 진입점에서 이벤트 → 리스너 → 서비스까지 끝단 효과를 본다. `grade()`가 반환하면 AFTER_COMMIT 리스너까지 끝나 있다 (`facade.md`). 세션의 `userId`는 픽스처로 만든 유저의 id를 쓴다.

- 5문항 만점 완료 → XP 30, LP 30
- 5문항 모두 무응답 → COMPLETED이고 XP, LP 그대로
- 판정 실패로 GRADING_FAILED → XP, LP 그대로
- XP 90인 유저가 30을 받으면 레벨 2가 된다
- LP 90(브론즈 3)인 유저가 30을 받으면 브론즈 2로 승급한다 (`leagueFixture.브론즈_2()` 준비)
- 유저 리그가 없어도 세션은 COMPLETED이고 XP는 지급된다 (XP와 LP의 독립성)

**`UserServiceIntegrationTest`** (`@Nested` "확정된 XP를 지급할 때" 추가, `@RecordApplicationEvents`)

- XP가 그대로 누적된다
- XP 99에서 1을 받으면 레벨 2가 되고 `LevelUpFeedEvent(userId, 2)`가 발행된다
- 레벨이 그대로면 `LevelUpFeedEvent`가 발행되지 않는다
- 없는 유저, 탈퇴한 유저 → `USER_NOT_FOUND`
- 기존 `UpdateUserLevelByLessonSubmission` 3건이 그대로 통과한다 (`applyXp` 추출 회귀)

**`UserLeaguePointServiceIntegrationTest`** (`@Nested` "확정된 리그 포인트를 추가할 때" 추가)

- LP가 그대로 누적된다
- 다음 리그 범위에 진입하면 승급한다
- 유저 리그가 없으면 `USER_LEAGUE_NOT_FOUND`

**`UserLeagueEventListenerIntegrationTest`** (`@Nested` "면접 완료 이벤트를 수신할 때" 추가, 기존 `TestTransaction` 구성 그대로)

- LP가 지급량만큼 누적된다
- 유저 리그가 없으면 `league-points-interview-retry`에 적재하지 않는다
- LP가 매칭되는 리그가 없으면 적재하지 않는다
- 일시적 오류(`doThrow(...).when(pointService).addLeaguePoints(userId, 30)`) → `league-points-interview-retry`에 `{userId, points: "30"}` 적재

**`UserEventListenerIntegrationTest`** (신규, `UserLeagueEventListenerIntegrationTest`와 같은 구성: `@MockitoBean RetryEventPublisher`, `@MockitoSpyBean UserService`, `TestTransaction`)

- XP가 지급량만큼 누적된다
- 유저가 없으면 `user-xp-interview-retry`에 적재하지 않는다
- 일시적 오류(`doThrow(...).when(userService).addXp(userId, 30)`) → `user-xp-interview-retry`에 `{userId, xp: "30"}` 적재

**`UserXpInterviewRetryTargetIntegrationTest`**, **`LeaguePointInterviewRetryTargetIntegrationTest`** (신규)

기존 `RetrySweepTarget` 구현에는 테스트가 없다. 새 대상은 리스너가 적재하는 필드명(`xp`, `points`)과 대상이 읽는 필드명이 두 클래스에 따로 적힌 문자열이라, 어긋나도 컴파일과 리스너 테스트가 모두 통과한다. 그 계약을 여기서 고정한다.

- 리스너 테스트가 단언한 것과 같은 페이로드로 `reprocess`하면 XP / LP가 누적된다
- 재시도 불가 코드(`USER_NOT_FOUND` / `USER_LEAGUE_NOT_FOUND`)면 예외 없이 끝난다
- 그 외 예외는 다시 던진다 (스위퍼가 재적재하도록)

**실행**: `./gradlew test --tests 'gravit.code.interview*' --tests 'gravit.code.user*' --tests 'gravit.code.social*'`

## 나중에 고려할 문제

| 항목 | 현재 기본값 |
|---|---|
| 레벨업, 승급 결과 노출 (P15) | 피드에만 올라간다. 면접은 채점이 비동기라 결과를 실을 쓰기 응답이 없고, 노출하려면 결과를 저장해야 한다. LP 승급은 커밋 후 지급이라 #536과 같은 판정 문제를 안는다. #536 결정 후 맞춘다 |
| 보상 반복 수령 (P16) | 제한 없음. 세션 생성 제한(P1)과 재출제 회피(P4)가 없고 결과 화면에 모범답안이 나와, 같은 문제를 외워 반복 제출하면 리그 점수를 계속 쌓을 수 있다. 보상이 반복 제출의 동기가 되면 세션당 LLM 5회 호출 비용도 함께 는다. 제출일 기준 하루 N회 한도는 `ended_at` 범위 카운트 쿼리 1개로 DB 변경 없이 붙일 수 있다 |
| 보상 지급 기록 | 저장하지 않는다. 세션이 보상을 받았는지 조회할 방법이 없다. P16을 "보상받은 세션 수"로 걸려면 필요하다 |
| 재시도 멱등성 | 재시도 큐에 멱등 키가 없다. `RetryQueueSweeper`가 재처리 성공 뒤 항목 제거에 실패하면 다음 스윕에서 다시 지급된다. 레슨 LP, 미션 재시도와 같은 기존 성질 |
| 동시 XP 갱신 유실 | `User`에 버전 컬럼이 없어 레슨 제출과 면접 XP 지급이 같은 행을 동시에 갱신하면 한쪽 증가분이 사라질 수 있다. 미션 XP와 같은 기존 성질 |
| 미션 XP의 레벨업 피드 | 미션 완료로 레벨이 올라도 피드에 안 올라간다. #536 과제 |
| 레슨과 면접의 반올림 구현 차이 | 레슨은 `Math.round(double)`, 면접은 `BigDecimal HALF_UP`. 양수 입력에서 결과는 같다 |
| 재채점(P2) 도입 시 | 완료 경로가 `completeGrading()` 하나라 보상도 따라온다. 별도 처리가 필요 없다 |

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)

- `.claude/spec/service-policy/README.md`: `interview.md` 범위 행에 "완료 보상" 추가 — 이유: 계획서 영향 범위에 없던 파일이지만, 목록이 새 절을 반영하지 않으면 "필요한 도메인 파일만 읽고 끝낸다"는 README 목적과 어긋나서.
- `.claude/spec/service-policy/interview.md`, `friend-social.md`: frontmatter `description`에 "완료 보상", "보상" 추가 — 이유: 본문에 새 절을 넣고 description을 그대로 두면 문서 요약과 내용이 어긋나서.
- 테스트: 기존 테스트 8곳의 `addLeaguePointsForLesson` 개명만 반영하고, 계획서 "검증"의 신규 시나리오와 신규 테스트 파일 4개는 작성하지 않음 — 이유: 테스트 작성은 implement 스킬 범위 밖(`write-test`). 개명은 테스트 소스 컴파일 복구에 필요해 포함했다.
- `UserLeaguePointService`: 범용 `addLeaguePoints(long, int)`를 `addLeaguePointsForInterview`와 `addLeaguePointsForCongratulation`으로 나누고 호출부를 연결(`UserLeagueEventListener`, `LeaguePointInterviewRetryTarget` → `ForInterview`, `SocialFacade` → `ForCongratulation`) — 이유: 구현 후 사용자 지시. `addLeaguePointsForLesson`과 같은 용도별 진입점으로 맞췄다. 계획서 본문과 "검증"의 `addLeaguePoints(...)` 표기는 면접 경로면 `ForInterview`, 축하 경로면 `ForCongratulation`으로 읽는다.
