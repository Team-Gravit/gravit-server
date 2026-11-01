# [PLAN-590] 채점 중 면접 세션 그만두기 허용

> 이슈: #590
> 브랜치: fix/590-abandon-grading-session

## 목표
기획은 채점 중에도 세션을 그만둘 수 있고 그만둔 세션의 결과는 이력에 남지 않는 것인데, 현재는 `IN_PROGRESS`만 취소할 수 있어 `GRADING` 요청이 409 `INTERVIEW_4026`으로 거부된다.
`GRADING` 세션을 `ABANDONED`로 바꿀 수 있게 하고, 취소와 채점 저장이 겹쳐도 결과가 하나로 정해져 취소된 세션에 피드백과 보상이 남지 않게 한다.

## 현재 코드의 문제
- 세션 상태 변경은 전부 `findById` + dirty checking이라 UPDATE에 상태 조건이 없다. 두 트랜잭션이 같은 상태를 읽고 쓰면 나중 커밋이 이긴다
- `GRADING`을 취소 가능하게만 바꾸면 다음 두 가지가 생긴다
  - 취소가 나중에 커밋: 상태는 `ABANDONED`인데 피드백 5건이 남고 XP, 리그 점수까지 지급된다
  - 채점 저장이 나중에 커밋: 취소 응답은 200인데 세션은 `COMPLETED`가 된다
- `InterviewGradingFacade.grade`는 모든 `RuntimeException`을 `log.error` 후 `failGrading`으로 넘긴다. 취소된 세션이 이 경로로 오는 경우는 셋이고, 어느 쪽이든 `INTERVIEW_SESSION_NOT_GRADING`이 다시 나서 error 로그가 2줄 남는다
  1. 채점 스레드가 시작하기 전에 취소됨: `getGradingSession` 실패
  2. 판정 끝나고 저장 시점에 취소를 발견: `completeGrading` 실패
  3. 취소된 뒤 판정 호출이 실패: LLM 예외 후 `failGrading` 실패

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/java/gravit/code/interview/domain/InterviewSession.java` - `abandon` 검증을 `validateAbandonable`로 교체
- `src/main/java/gravit/code/interview/repository/InterviewSessionRepository.java` - 행 잠금 조회 `findByIdForUpdate` 추가
- `src/main/java/gravit/code/interview/service/InterviewSessionCommandService.java` - 상태 변경 4개 메서드를 잠금 조회로 전환, `failGrading`을 `failGradingUnlessAbandoned`로 변경
- `src/main/java/gravit/code/interviewFeedback/facade/InterviewGradingFacade.java` - 취소된 세션을 채점 실패와 분리해 종료
- `src/main/java/gravit/code/interview/controller/docs/InterviewSessionControllerDocs.java` - `abandon` description과 409 응답 설명 수정
- `.claude/spec/service-policy/interview.md` - 정책 변경: 취소 규칙, 상태 전이표, 채점
- `src/test/java/gravit/code/interview/service/InterviewSessionCommandServiceIntegrationTest.java` - 채점 중 취소, 제출과 취소 경합 테스트, 기존 테스트 수정
- `src/test/java/gravit/code/interviewFeedback/facade/InterviewGradingFacadeIntegrationTest.java` - 채점 중 취소, 취소와 채점 저장 경합 테스트

## 구현 계획

### 1. Entity / Flyway

Flyway 변경 없음.

`InterviewSession`:

```java
public void abandon(LocalDateTime endedAt) {
    validateAbandonable();

    this.status = InterviewSessionStatus.ABANDONED;
    this.endedAt = endedAt;
}

private void validateAbandonable() {
    if (isAbandoned()) {
        throw new RestApiException(INTERVIEW_SESSION_ABANDONED);
    }
    if (!isInProgress() && !isGrading()) {
        throw new RestApiException(INTERVIEW_SESSION_ALREADY_SUBMITTED);
    }
}
```

- `validateAbandonable`은 호출자 `abandon` 바로 아래에 둔다
- `validateInProgress`는 문항 조회, 업로드 URL, 변환, 제출이 계속 쓰므로 그대로 둔다
- `endedAt`은 `GRADING`에서 취소해도 취소 시각으로 덮어쓴다. "취소하면 종료 시각을 기록한다"는 기존 규칙을 유지하는 선택이고, 메인 코드에 `getEndedAt` 호출이 없어 영향이 없다. 제출 시각은 답안의 `answeredAt`에 남는다
- `gradingAttemptCount`는 그대로 1로 남는다

### 2. Repository - `InterviewSessionRepository`

```java
@Lock(LockModeType.PESSIMISTIC_WRITE)
@Query("""
        SELECT s
        FROM InterviewSession s
        WHERE s.id = :id
""")
Optional<InterviewSession> findByIdForUpdate(@Param("id") long id);
```

### 3. Service - `InterviewSessionCommandService`

`abandon`, `submit`, `completeGrading`, `failGrading`의 조회를 `findSessionForUpdate`로 바꾼다. 네 메서드 모두 트랜잭션 안에 외부 호출이 없어 잠금은 짧게 끝난다. LLM 호출은 트랜잭션 밖이다.

```java
private InterviewSession findSessionForUpdate(long sessionId) {
    return interviewSessionRepository.findByIdForUpdate(sessionId)
            .orElseThrow(() -> new RestApiException(INTERVIEW_SESSION_NOT_FOUND));
}

@Transactional
public boolean failGradingUnlessAbandoned(long sessionId) {
    InterviewSession session = findSessionForUpdate(sessionId);

    if (session.isAbandoned()) {
        return false;
    }

    session.failGrading();

    return true;
}
```

- 쓰지 않게 되는 `findSession`은 삭제한다
- 경합 결과는 잠금 순서로 정해진다

| 먼저 잠근 쪽 | 나중 쪽 결과 | 최종 상태 |
|------|------|------|
| 취소 | `completeGrading`이 `INTERVIEW_SESSION_NOT_GRADING`, 피드백 롤백, 보상 이벤트 미발행 | ABANDONED |
| 채점 저장 | 취소가 `INTERVIEW_4026` | COMPLETED, 보상 지급 |
| 취소 | 제출이 `INTERVIEW_4025` | ABANDONED |
| 제출 | 취소 성공, 채점 스레드는 취소를 발견하고 종료 | ABANDONED |

- 피드백 저장(`saveAll`)이 세션 잠금보다 먼저 실행되지만 같은 트랜잭션이라 함께 롤백된다. 저장 순서는 바꾸지 않는다
- `submit`까지 잠그는 이유: 이슈의 "취소된 세션에 피드백과 보상이 남지 않아야 한다"는 취소와 제출이 겹칠 때도 깨진다. 취소 200 뒤에 제출이 `GRADING`으로 덮어쓰면 채점과 보상이 그대로 진행된다
- `submit`을 잠그면 `create`의 일괄 취소(`abandonInProgressByUserId`)와 제출의 경합도 함께 해결된다. 일괄 UPDATE가 행 잠금을 기다린 뒤 상태 조건을 다시 평가하므로 제출된 세션을 건드리지 않는다. `create`의 코드 변경은 없다
- `create`는 `IN_PROGRESS`만 취소한다. 새 세션을 만들어도 `GRADING` 세션은 그대로 채점된다

### 4. Facade - `InterviewGradingFacade`

```java
public void grade(long sessionId) {
    try {
        ...
    } catch (RuntimeException e) {
        handleGradingFailure(sessionId, e);
    }
}

private void handleGradingFailure(
        long sessionId,
        RuntimeException cause
) {
    try {
        if (interviewSessionCommandService.failGradingUnlessAbandoned(sessionId)) {
            log.error("면접 채점 실패 - sessionId: {}", sessionId, cause);
            return;
        }

        log.info("취소된 면접 세션의 채점 종료 - sessionId: {}", sessionId);
    } catch (RuntimeException e) {
        log.error("면접 채점 실패 - sessionId: {}", sessionId, cause);
        log.error("면접 채점 실패 상태 전이 실패 - sessionId: {}", sessionId, e);
    }
}
```

문항 판정 전 상태 확인을 추가한다. `gradeAnswers`와 `gradeAnswer`에 `long sessionId`를 첫 파라미터로 받고, `gradeAnswer`의 무응답 분기 뒤, `judge` 호출 앞에서 확인한다.

```java
private InterviewGradedAnswerDto gradeAnswer(
        long sessionId,
        InterviewAnswer answer,
        InterviewQuestion question,
        List<InterviewQuestionConcept> concepts
) {
    if (!answer.isAnswered()) {
        return InterviewGradedAnswerDto.of(answer.getId(), InterviewScoreDto.noResponse());
    }

    interviewSessionQueryService.getGradingSession(sessionId);

    InterviewGradingJudgmentDto judgment = interviewGradingService.judge(
            InterviewGradingInputDto.of(question, concepts, answer.getContent())
    );

    return InterviewGradedAnswerDto.of(answer.getId(), interviewScoringPolicy.score(judgment, concepts));
}
```

- 무응답 문항은 LLM을 호출하지 않으므로 확인하지 않는다
- 이 확인은 잠금 없는 조회라 호출 절약용이다. 정합성은 저장 시점의 잠금이 보장한다. 판정 호출 중에 취소되면 그 호출은 끝까지 간다
- 취소를 발견하면 `INTERVIEW_SESSION_NOT_GRADING`이 나서 다른 경로와 같은 catch로 모인다
- 위 "현재 코드의 문제"의 세 경로도 모두 catch로 모인다. 판단을 잠금 안의 `failGradingUnlessAbandoned` 한 곳에서 하므로, 먼저 상태를 조회하고 나서 전이할 때 생기는 틈이 없다
- 기존 `markGradingFailed`는 `handleGradingFailure`로 대체한다
- 취소가 아닌 세션(없는 세션, 완료된 세션)의 로그는 지금과 같이 error 2줄이다

### 5. DTO
- 변경 없음

### 6. Controller
- `InterviewSessionController` 변경 없음. `PATCH /api/v1/interview-sessions/{sessionId}/abandon` 그대로다

`InterviewSessionControllerDocs.abandon`:

```
진행 중(IN_PROGRESS)이거나 채점 중(GRADING)인 세션을 취소(ABANDONED)합니다.<br>
취소된 세션은 채점 결과를 저장하지 않고 보상을 지급하지 않으며 결과와 통계에도 포함하지 않습니다.<br>
취소된 세션은 INTERVIEW_4025, 채점이 끝난 세션(COMPLETED, GRADING_FAILED)은 INTERVIEW_4026으로 거부됩니다.<br>
채점 완료와 겹치면 먼저 처리된 쪽이 결과가 되며, 완료가 먼저면 INTERVIEW_4026으로 거부됩니다.<br>
🔐 <strong>Jwt 필요</strong>
```

- 409 `@ApiResponse` description: `"🚨 취소할 수 없는 세션"`
- 409 예시 이름: `"제출된 세션"` → `"채점이 끝난 세션"`. value는 `CustomErrorCode` 그대로 둔다
- 다른 API의 "제출 이후 세션은 INTERVIEW_4026" 문구는 지금도 맞으므로 고치지 않는다

### 7. 서비스 정책 - `interview.md`

**취소** 섹션
- 130행 교체: `진행 중(IN_PROGRESS)과 채점 중(GRADING) 세션을 취소할 수 있다. 채점이 끝난 세션(COMPLETED, GRADING_FAILED)과 이미 취소된 세션은 취소할 수 없다`
- 추가: `새 세션 생성은 진행 중 세션만 취소한다. 채점 중 세션은 그대로 채점된다`
- 131행 교체: `취소하면 종료 시각을 기록하고 세션은 취소(ABANDONED)가 된다. 채점 중 세션을 취소하면 종료 시각은 취소 시각으로 바뀐다. 취소된 세션은 채점 결과를 저장하지 않고 보상을 지급하지 않으며 결과와 통계에 포함하지 않는다`
- 추가: `취소와 채점 완료가 겹치면 먼저 처리된 쪽이 결과가 된다. 취소가 먼저면 세션은 취소로 남고, 완료가 먼저면 취소는 거부되고 세션은 완료로 남는다`
- 추가: `채점 중에 취소한 세션의 문제도 나온 적 없는 문제로 친다`

**세션 상태** 섹션
- GRADING 행 나가는 전이: `저장 성공 → COMPLETED, 채점 실패 → GRADING_FAILED, 취소 → ABANDONED`
- ABANDONED 행 진입 조건: `사용자 명시 요청(IN_PROGRESS, GRADING에서) 또는 같은 사용자의 새 세션 생성(IN_PROGRESS에서)`
- 상태 전이도에 `GRADING --취소--> ABANDONED` 반영
- 154행 나열에서 취소를 빼고 표 아래에 추가: `취소 요청은 세션 상태가 ABANDONED면 INTERVIEW_4025, COMPLETED, GRADING_FAILED면 INTERVIEW_4026으로 거부한다. GRADING은 거부하지 않는다`

**채점 실패** 섹션
- 추가: `채점 도중 세션이 취소되면 남은 문항을 판정하지 않고, 채점 실패로 바꾸지 않고 끝낸다. 판정이 실패했더라도 세션은 취소로 남는다`

## 결정 필요 (Decisions needed)
- [x] 세션 상태 동시성 처리 방식 — 비관적 락 `PESSIMISTIC_WRITE`로 확정. 마이그레이션이 없고 진 쪽이 기존 도메인 오류로 떨어진다
- [x] 채점 중 취소 시 남은 문항의 LLM 판정 — 문항 판정 전마다 상태를 확인해 조기 종료로 확정. 취소 후 최대 4회의 LLM 호출을 아낀다

## 검증
- 대상 테스트: `InterviewSessionCommandServiceIntegrationTest`, `InterviewGradingFacadeIntegrationTest`
- 경합 테스트는 `UserDeletionServiceIntegrationTest`의 패턴을 따른다. 한쪽이 `transactionTemplate` 안에서 행을 잠근 채 래치로 대기하고, 다른 쪽이 막히는 것을 `Future.get` 타임아웃으로 확인한 뒤 풀어 준다

`InterviewSessionCommandServiceIntegrationTest`
- `Abandon`
  - 신규 `채점_중인_세션을_취소로_바꾸고_종료_시각을_남긴다`: 응답, 상태, `endedAt`, `gradingAttemptCount` 유지
  - 수정 `제출_이후_세션이면_예외를_던지고_상태와_종료_시각이_그대로다`: `names`에서 `GRADING` 제거, 이름을 `채점이_끝난_세션이면_예외를_던지고_상태와_종료_시각이_그대로다`로 변경. `INTERVIEW_SESSION_ALREADY_SUBMITTED` 검증 유지
- `FailGrading`
  - 호출을 `failGradingUnlessAbandoned`로 변경하고 `true` 반환 검증 추가
  - 신규 `취소된_세션이면_상태를_바꾸지_않고_false를_반환한다`
- 신규 경합
  - `취소가_먼저_잠그면_제출이_중단된_세션_예외로_거부된다`: `INTERVIEW_SESSION_ABANDONED`, 답안 미제출 유지
  - `제출이_먼저_잠그면_취소는_채점_중_세션을_취소한다`: 최종 `ABANDONED`

`InterviewGradingFacadeIntegrationTest`
- `Grade`
  - 신규 `이미_취소된_세션이면_판정하지_않고_상태를_유지한다`: `callCount` 0, `ABANDONED`
  - 신규 `판정_도중_취소되면_남은_문항을_판정하지_않고_피드백_없이_취소로_남는다`: 스텁 `respondWith` 안에서 `abandon` 호출, `callCount` 1
  - 신규 `판정_도중_취소되고_판정이_실패해도_채점_실패가_되지_않는다`: 스텁에서 `abandon` 후 예외, 상태 `ABANDONED`
  - 신규 `취소된_세션은_채점_실패_로그를_남기지_않는다`: `OutputCaptureExtension`으로 `면접 채점 실패` 미포함 확인
- `Reward`
  - 신규 `판정_도중_취소되면_보상을_지급하지_않는다`: XP, LP 0
- 신규 경합
  - `취소가_먼저_잠그면_채점_저장이_무효가_된다`: `ABANDONED`, 피드백 0건, XP와 LP 0
  - `채점_저장이_먼저_잠그면_취소가_거부되고_완료로_남는다`: `INTERVIEW_SESSION_ALREADY_SUBMITTED`, `COMPLETED`, 피드백 5건, 보상 1회

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
