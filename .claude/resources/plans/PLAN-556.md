# [PLAN-556] AI 면접 문제 재출제 우선순위 적용

> 이슈: #556
> 브랜치: feat/556-interview-question-reselection

## 목표
지금은 세션을 만들 때 태그별 후보를 섞어 앞에서부터 몫만큼 자르므로, 전에 푼 문제가 바로 다음 세션에 다시 나올 수 있다.
후보를 섞은 뒤 "안 본 문제 → 최근 정확성 점수가 낮은 문제 → 점수가 같으면 오래전에 나온 문제" 순으로 정렬하고 자른다.
반복 체감은 줄이고, 다시 나올 때는 약한 문제를 복습하게 하려는 것이다.

정책 원문: [AI 면접 문제 재출제 정책](https://app.notion.com/p/3e44c7fd3dd181aba356d5a2b542fec5)

## 설계 기준
- **정렬은 "섞은 뒤 안정 정렬"로 한다.** `List.sort`는 안정 정렬(TimSort)이라 비교 결과가 같은 원소끼리는 섞인 순서가 그대로 남는다. 그래서 안 본 문제끼리, 그리고 점수와 출제 시점이 같은 문제끼리는 지금처럼 무작위가 유지된다. 무작위를 따로 구현할 필요가 없다
- **우선순위 판단은 `InterviewQuestionAllocationPolicy`에 둔다.** 이미 "어떤 문제를 몇 개 고를지"를 정하는 정책 컴포넌트다. 출제 규칙이 한 곳에 모이고, 기존 `select` 흐름(몫 배분 → 태그별 선택 → 모드별 순서)에서 태그별 선택 단계만 바뀐다
- **출제 이력은 `interview` 도메인에서 조회한다.** 이력의 주체는 답안(`interview_answer`)과 세션(`interview_session`)이다. 점수(`interview_feedback`)는 없을 수도 있어서 LEFT JOIN으로 붙인다. 같은 방식의 도메인 간 JPQL 조인 선례가 있다(`InterviewAnswerRepository.findQuestionsBySessionId`의 `InterviewQuestion` 조인, `InterviewFeedbackRepository`의 `InterviewSession` 조인)
- **이력은 풀에 있는 문제로만 좁혀 조회한다.** 쓰는 곳은 이번 선택 후보뿐이므로 `a.questionId IN (풀 문제 id)`로 행 수를 제한한다. 풀은 이미 활성 여부와 난이도를 걸러 둔 목록이라 다른 조건을 반복할 필요가 없다
- **"최근 점수"는 가장 최근에 나온 한 번의 기록으로 정한다.** 최근 출제 순으로 정렬해 받고 문제별 첫 행만 남긴다. 점수 여부도 그 한 번의 기록으로 판단한다(결정 필요 2)
- **점수가 있는지는 피드백 행이 있는지로 판단한다.** 피드백은 `completeGrading`과 같은 트랜잭션에서 5건이 함께 저장된다(`InterviewGradingFacade.save`). 그래서 피드백이 있는 것과 세션이 COMPLETED인 것은 같은 뜻이고, LEFT JOIN 결과가 null이면 "본 문제, 점수 없음"이다. 무응답은 0점 피드백으로 저장되므로 자연스럽게 가장 먼저 돌아온다
- **취소한 세션은 쿼리에서 뺀다.** 노션 정책대로 취소한 세션의 문제는 안 본 문제로 친다. 취소 세션을 빼면 이력이 없는 문제가 되고, 그 문제는 1순위로 간다
- **스키마 변경과 인덱스 추가는 없다.** 조회 경로마다 이미 인덱스가 있다
  - 세션은 `ix_interview_session_user_started (user_id, started_at DESC)`로 찾는다. 정렬(`started_at DESC`)도 이 인덱스를 따른다
  - 답안은 `uq_interview_answer_session_question (session_id, question_id)`로 조인한다
  - 피드백은 `uq_interview_feedback_answer (answer_id)`로 조인한다
- **세션 생성 실패 조건은 바뀌지 않는다.** 정렬은 후보 수를 바꾸지 않는다. `candidates.size() < quota` 검사도 그대로다
- **정책 변경이다.** `interview.md`의 "재출제 회피는 미결 과제(P4)" 규칙을 확정된 출제 규칙으로 바꾼다
- **API, 응답 스키마, Swagger 문서는 바뀌지 않는다.** `InterviewSessionControllerDocs`에는 출제 방식을 설명한 문구가 없다

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/interview/dto/internal/InterviewQuestionHistoryDto.java` - 문제 한 번의 출제 이력을 담는다(문제 id, 출제 시점, 정확성 점수)
- `src/test/java/gravit/code/interview/service/InterviewAnswerQueryServiceIntegrationTest.java` - 이력 조회 검증

### 수정 파일
- `src/main/java/gravit/code/interview/repository/InterviewAnswerRepository.java` - 사용자 출제 이력 조회 쿼리 추가
- `src/main/java/gravit/code/interview/service/InterviewAnswerQueryService.java` - 문제별 최근 이력 맵을 반환하는 메서드 추가
- `src/main/java/gravit/code/interview/policy/InterviewQuestionAllocationPolicy.java` - `select`가 이력을 받고, 태그별 선택에서 섞은 뒤 우선순위로 정렬
- `src/main/java/gravit/code/interview/facade/InterviewSessionFacade.java` - 풀 조회 뒤 이력을 조회해 `select`에 넘김
- `.claude/spec/service-policy/interview.md` - 출제 규칙에 재출제 우선순위 추가, P4 확정 처리
- `src/test/java/gravit/code/interview/policy/InterviewQuestionAllocationPolicyIntegrationTest.java` - 기존 `select` 호출에 이력 인자 추가, 우선순위 테스트 추가
- `src/test/java/gravit/code/interview/facade/InterviewSessionFacadeIntegrationTest.java` - 두 번째 세션이 안 본 문제를 먼저 받는지 검증 추가

## 구현 계획

### 1. Entity / Flyway
변경 없음. 필요한 컬럼은 모두 있다: `interview_answer.question_id`, `interview_session.user_id, status, started_at`, `interview_feedback.answer_id, accuracy_score`.

### 2. DTO (internal): `InterviewQuestionHistoryDto` (신규)
```java
package gravit.code.interview.dto.internal;

import java.time.LocalDateTime;

public record InterviewQuestionHistoryDto(

        long questionId,

        LocalDateTime presentedAt,

        Integer accuracyScore
) {
}
```
- **왜**: 쿼리 결과(문제 id, 출제 시점, 점수)를 정책까지 넘겨야 한다. JPQL 생성자 표현식의 대상이라 `dto.md`의 Internal 규칙대로 표준 생성자만 둔다
- **`presentedAt`**: 세션의 `startedAt`이다. 세션 생성 시점에 5문항이 확정되므로(`interview.md` "세션 생성"), 세션 시작 시각이 곧 문제가 나온 시각이다. 정책의 "오래된 순" 비교에 쓴다
- **`accuracyScore`가 `Integer`인 이유**: LEFT JOIN이라 피드백이 없으면 null이 온다. null이 "본 문제, 점수 없음"을 뜻하는 값이다. `InterviewFeedback.accuracyScore`는 `int`이지만 프로젝션 대상은 null을 받아야 한다
- **어떻게 쓰이나**: 리포지토리가 행 단위로 반환한다. 서비스가 문제별 최신 행만 남겨 `Map<Long, InterviewQuestionHistoryDto>`로 만들고, 정책이 정렬 키로 쓴다

### 3. Repository: `InterviewAnswerRepository.findQuestionHistoriesByUserIdExcludingStatus` (추가)
```java
@Query("""
        SELECT new gravit.code.interview.dto.internal.InterviewQuestionHistoryDto(
            a.questionId, s.startedAt, f.accuracyScore
        )
        FROM InterviewAnswer a
        JOIN InterviewSession s ON s.id = a.sessionId
        LEFT JOIN InterviewFeedback f ON f.answerId = a.id
        WHERE s.userId = :userId AND s.status <> :excludedStatus AND a.questionId IN :questionIds
        ORDER BY s.startedAt DESC, s.id DESC
""")
List<InterviewQuestionHistoryDto> findQuestionHistoriesByUserIdExcludingStatus(
        @Param("userId") long userId,
        @Param("questionIds") Collection<Long> questionIds,
        @Param("excludedStatus") InterviewSessionStatus excludedStatus
);
```
- **왜 `JOIN InterviewSession`**: 답안에는 사용자 id가 없다. 사용자와 세션 상태, 출제 시점은 세션에 있다
- **왜 `LEFT JOIN InterviewFeedback`**: 채점 전이거나 채점에 실패한 세션의 답안도 "본 문제"로 남겨야 한다. 내부 조인이면 이 행들이 빠져 안 본 문제로 잘못 분류된다. 그러면 제출 직후 새 세션에서 방금 푼 문제가 1순위로 다시 나온다
- **왜 `s.status <> :excludedStatus`**: 서비스가 `ABANDONED`를 넘긴다. 취소한 세션에서 나온 문제는 이력에서 빠져 안 본 문제가 된다. 상태를 인자로 받는 방식은 이 리포지토리들의 기존 관례를 따른 것이다(`findRecentByUserIdAndStatus`, `findTopicAccuracyByUserIdAndStatus`)
- **왜 `ORDER BY s.startedAt DESC, s.id DESC`**: 서비스가 "문제별 첫 행 = 가장 최근 출제"로 줄이기 위해서다. `s.id`는 시작 시각이 같을 때 순서를 확정한다. 기존 `findRecentByUserIdAndStatus`와 같은 정렬 기준이다
- **포맷**: `repository.md`의 `@Query` 텍스트 블록 규칙(여는 `"""` 붙이기, 본문 8칸 들여쓰기, 최상위 절마다 줄바꿈)을 따른다. 파라미터가 2개 이상이라 줄바꿈 선언이다
- **import 추가**: `gravit.code.interview.domain.InterviewSessionStatus`, `gravit.code.interview.dto.internal.InterviewQuestionHistoryDto`, `java.util.Collection`

### 4. Service: `InterviewAnswerQueryService.getQuestionIdToLatestHistory` (추가)
```java
@Transactional(readOnly = true)
public Map<Long, InterviewQuestionHistoryDto> getQuestionIdToLatestHistory(
        long userId,
        Collection<Long> questionIds
) {
    if (questionIds.isEmpty()) {
        return Map.of();
    }

    return interviewAnswerRepository.findQuestionHistoriesByUserIdExcludingStatus(
                    userId, questionIds, InterviewSessionStatus.ABANDONED).stream()
            .collect(Collectors.toMap(
                    InterviewQuestionHistoryDto::questionId,
                    Function.identity(),
                    (latest, older) -> latest
            ));
}
```
- **왜 이 서비스인가**: 조회 대상의 주체가 `interview_answer`이고, 이 서비스는 이미 `InterviewAnswerRepository`를 가진 조회 서비스다. 새 서비스를 만들 이유가 없다. 다른 도메인 서비스를 호출하지 않으므로 `service.md`의 단일 도메인 규칙에 맞는다
- **왜 `(latest, older) -> latest`**: 쿼리가 최근 출제 순으로 정렬되어 있고, 순차 스트림의 `toMap`은 먼저 들어온 값을 `existing` 인자로 준다. 그래서 먼저 들어온 값, 즉 가장 최근 출제 기록이 남는다. 노션 정책의 "같은 문제를 여러 번 풀었다면 가장 최근 점수"를 이 한 줄이 구현한다
- **왜 빈 목록 검사**: 풀이 비어 있으면 어차피 정책의 `select`가 `INTERVIEW_QUESTION_POOL_INSUFFICIENT`를 던진다. 그 전에 DB를 한 번 더 부르지 않으려는 것이다. 빈 컬렉션 `IN ()`이 SQL로 어떻게 풀릴지에 기대지 않으려는 이유도 있다
- **맵 이름**: `common.md`의 `{키}To{값}` 규칙에 따라 `questionIdToHistory` 계열로 짓는다
- **import 추가**: `InterviewSessionStatus`, `InterviewQuestionHistoryDto`, `java.util.Collection`, `java.util.Map`, `java.util.function.Function`, `java.util.stream.Collectors`

### 5. Policy: `InterviewQuestionAllocationPolicy` (수정)
**상수 추가** (클래스 상단, 기존 상수 아래)
```java
private static final Comparator<InterviewQuestionHistoryDto> RESELECTION_ORDER = Comparator.nullsFirst(
        Comparator.comparing(
                        InterviewQuestionHistoryDto::accuracyScore,
                        Comparator.nullsLast(Comparator.<Integer>naturalOrder())
                )
                .thenComparing(InterviewQuestionHistoryDto::presentedAt)
);
```
이 비교기 하나로 노션 정책의 우선순위가 모두 표현된다. 비교 대상은 `questionIdToHistory.get(questionId)`의 결과다.

| 후보 상태 | 비교 값 | 정렬 위치 |
|------|------|------|
| 안 본 문제 (이력 없음, 취소 세션만 있음) | `get`이 null | `nullsFirst`로 맨 앞 (1순위) |
| 본 문제, 점수 있음 | `accuracyScore` 값 | 점수 오름차순, 같으면 `presentedAt` 오름차순(오래된 순) (2순위) |
| 본 문제, 점수 없음 (진행 중, 채점 중, 채점 실패) | `accuracyScore`가 null | `nullsLast`로 점수 있는 문제 뒤. 그 안에서 `presentedAt` 오름차순 |

- **왜 상수인가**: 사용자별로 달라지는 값이 없는 고정 규칙이다. `common.md` 상수 규칙대로 클래스 상단 `private static final`에 둔다
- **왜 순위 번호(0, 1, 2)를 쓰지 않나**: 1순위와 점수 없음 구분이 null 위치로 표현되므로 매직넘버 상수를 추가로 둘 필요가 없다

**`select` 시그니처 변경**
```java
public List<Long> select(
        InterviewMode mode,
        Map<InterviewTopic, Integer> topicToQuota,
        List<InterviewQuestionPoolDto> pool,
        Map<Long, InterviewQuestionHistoryDto> questionIdToHistory
) {
    Map<InterviewTopic, List<Long>> topicToQuestionIds = pickByQuota(topicToQuota, pool, questionIdToHistory);

    return orderByMode(mode, topicToQuestionIds);
}
```
- **왜 인자로 받나**: 정책은 지금처럼 리포지토리에 의존하지 않는 순수 규칙으로 둔다. 조회는 파사드가 서비스로 하고, 정책은 받은 값으로 판단만 한다

**`pickByQuota` 변경** (파라미터 추가, 섞은 직후 정렬 한 줄 추가)
```java
private Map<InterviewTopic, List<Long>> pickByQuota(
        Map<InterviewTopic, Integer> topicToQuota,
        List<InterviewQuestionPoolDto> pool,
        Map<Long, InterviewQuestionHistoryDto> questionIdToHistory
) {
    // ... topicToCandidates 구성은 그대로
    for (...) {
        // ... 부족 검사 그대로
        Collections.shuffle(candidates);
        candidates.sort(Comparator.comparing(questionIdToHistory::get, RESELECTION_ORDER));

        topicToQuestionIds.put(topic, List.copyOf(candidates.subList(0, quota)));
    }
    // ...
}
```
- **왜 섞은 다음에 정렬하나**: 정렬이 안정적이라 동순위끼리는 섞인 순서가 남는다. 순서를 거꾸로 하면 섞기가 정렬 결과를 덮어써 우선순위가 사라진다
- **왜 태그별로 정렬하나**: 몫은 태그 단위로 이미 정해져 있다. 정책 문서의 "선별 단위는 태그"를 따라 태그 안에서만 우선순위를 비교한다. 태그 간 배분과 모드별 문항 순서(`orderByMode`)는 바뀌지 않는다
- **import 추가**: `gravit.code.interview.dto.internal.InterviewQuestionHistoryDto`, `java.util.Comparator`

### 6. Facade: `InterviewSessionFacade.create` (수정)
새 Facade는 필요 없다. 기존 `InterviewSessionFacade`가 이미 `interviewQuestion`과 `interview` 두 도메인 서비스를 조합하고 있고, 여기에 같은 도메인 조회 서비스 하나가 더해질 뿐이다.

```java
private final InterviewQuestionQueryService interviewQuestionQueryService;
private final InterviewSessionCommandService interviewSessionCommandService;
private final InterviewAnswerQueryService interviewAnswerQueryService;

private final InterviewQuestionAllocationPolicy interviewQuestionAllocationPolicy;

public InterviewSessionCreateResponse create(
        long userId,
        InterviewSessionCreateRequest request
) {
    Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
            request.mode(), request.stack(), request.topics());

    List<InterviewQuestionPoolDto> pool = interviewQuestionQueryService.getPool(
            topicToQuota.keySet(), request.difficulty());

    List<Long> poolQuestionIds = pool.stream()
            .map(InterviewQuestionPoolDto::questionId)
            .toList();
    Map<Long, InterviewQuestionHistoryDto> questionIdToHistory = interviewAnswerQueryService.getQuestionIdToLatestHistory(
            userId, poolQuestionIds);

    List<Long> orderedQuestionIds = interviewQuestionAllocationPolicy.select(
            request.mode(), topicToQuota, pool, questionIdToHistory);

    long sessionId = interviewSessionCommandService.create(
            userId, InterviewSessionCreateDto.of(request, topicToQuota.keySet(), orderedQuestionIds));

    return InterviewSessionCreateResponse.from(sessionId);
}
```
- **주입 필드 순서**: `common.md`에 따라 Service 묶음 안에 추가한다. 같은 종류 안의 순서는 자유다
- **트랜잭션 경계**: 추가하지 않는다. 새 호출은 읽기 전용 서비스 호출 하나다. `facade.md`의 기준(엔티티를 경계 밖으로 반환하는지, REPEATABLE READ 스냅샷이 필요한지)에 둘 다 해당하지 않는다. 쓰기는 지금처럼 `InterviewSessionCommandService.create`의 트랜잭션 안에서만 일어난다
- **동시성**: 같은 사용자가 세션 두 개를 동시에 만들면 두 요청이 같은 이력을 읽어 같은 문제를 받을 수 있다. 결과는 "지금처럼 겹칠 수 있다"는 수준이고 데이터가 깨지지는 않는다. 그래서 잠금은 두지 않는다

### 7. DTO (request, response) / Controller
변경 없음. `POST` 세션 생성 API의 요청과 응답은 그대로다.

### 8. 서비스 정책: `.claude/spec/service-policy/interview.md` (수정)
"출제" 절의 마지막 줄을 교체한다.
- 기존: `- 같은 사용자의 과거 세션에 나온 문제를 제외하는 규칙은 없다. 재출제 회피는 미결 과제(P4)다`
- 변경:
  ```
  - 태그 안에서는 우선순위대로 몫만큼 고른다. 1순위는 이 사용자에게 나온 적 없는 문제, 2순위는 이미 나온 문제 중 최근 정확성 점수가 낮은 문제다. 점수가 같으면 오래전에 나온 문제가 먼저다. 1순위 안과 동순위끼리는 랜덤이다
  - 점수는 정확성 점수만 본다. 같은 문제가 여러 번 나왔으면 가장 최근에 나온 세션의 기록을 쓴다. 무응답은 0점이라 가장 먼저 돌아온다
  - 취소한 세션에서 나온 문제는 나온 적 없는 문제로 친다
  - 가장 최근에 나온 세션이 진행 중, 채점 중, 채점 실패라서 점수가 없는 문제는 점수 있는 문제 뒤에 오래된 순으로 둔다. 제출 직후 새 세션을 만들어도 방금 푼 문제가 곧바로 다시 나오지 않게 하기 위해서다
  - 우선순위는 후보 수를 바꾸지 않는다. 몫에 미달하면 실패하는 규칙은 그대로다
  ```
- 미결 과제 표 P4 행: `| P4 | 재출제 회피 | 확정 - 안 본 문제 우선, 이후 최근 정확성 점수 낮은 순, 동점이면 오래된 순. 쿨다운(직전 N회 제외)은 없음 |`
- 표기 규칙(가운데점 대신 콤마, 긴 대시 대신 짧은 대시)을 따른다

## 결정 필요 (Decisions needed)
- [x] 1. (확정: A) 진행 중(IN_PROGRESS) 세션의 문제를 어떻게 볼지 - 노션 정책은 취소, 채점 중, 채점 실패만 다루고 진행 중 세션은 다루지 않는다. 정책상 진행 중 세션이 있어도 새 세션을 만들 수 있다(P1)
  - A (추천): "본 문제, 점수 없음"으로 본다. 문제는 세션 생성 시 이미 화면에 나갔고, 열어 둔 세션 두 개에 같은 문제가 나오는 것을 막는다. 위 쿼리(취소만 제외)가 그대로 이 동작이다
  - B: 안 본 문제로 친다. 쿼리에서 IN_PROGRESS도 제외해야 한다. 두 세션을 연달아 만들면 같은 문제가 겹칠 수 있다
- [x] 2. (확정: A) 가장 최근에 나온 기록에는 점수가 없고, 그 전 기록에는 점수가 있는 문제 - 예: 1회차에 3점, 2회차는 채점 중
  - A (추천): 가장 최근 기록 기준으로 "점수 없음"에 둔다. 노션 정책의 "채점 중 문제는 점수 있는 문제 뒤"라는 의도(방금 푼 문제의 즉시 재출제 방지)를 지킨다. 위 서비스 구현(첫 행만 남김)이 그대로 이 동작이다
  - B: 점수가 있는 가장 최근 기록(3점)을 쓴다. 2회차에 푼 문제가 3회차에 바로 다시 나올 수 있다

## 검증
- `InterviewQuestionAllocationPolicyIntegrationTest.Select`
  - 기존 `select` 호출에 `Map.of()`를 넘긴다. 이력이 없으면 지금과 같은 동작(몫만큼 중복 없이, 조합과 순서가 고정되지 않음)인지 확인한다
  - 신규: 안 본 문제가 몫 이상이면 이력이 있는 문제는 뽑히지 않는다
  - 신규: 안 본 문제가 모자라면 나머지를 정확성 점수가 낮은 순으로 채운다
  - 신규: 점수가 같으면 `presentedAt`이 이른 문제가 먼저 뽑힌다
  - 신규: 점수 없는 이력은 점수 있는 이력보다 뒤에 뽑힌다
  - 신규: 안 본 문제가 몫보다 많으면 매번 같은 조합이 나오지 않는다(무작위 유지)
- `InterviewAnswerQueryServiceIntegrationTest` (신규)
  - 같은 문제가 여러 세션에 나오면 가장 최근 세션의 기록만 남는다
  - 취소한 세션에만 나온 문제는 결과에 없다
  - 채점 중, 채점 실패, 진행 중 세션의 문제는 `accuracyScore`가 null이다
  - 무응답으로 채점된 문제는 `accuracyScore`가 0이다
  - 다른 사용자의 세션 기록은 섞이지 않는다
  - 빈 목록을 주면 빈 맵을 반환한다
- `InterviewSessionFacadeIntegrationTest`
  - 신규: 태그 하나에 문제가 10개 있을 때 같은 주제로 두 번 만들면 두 세션의 문제가 겹치지 않는다
  - 신규: 문제 10개에서 첫 세션을 만들고, 두 번째 세션을 만든 뒤 취소하면, 세 번째 세션은 두 번째 세션과 같은 5문항을 받는다(취소 세션 문제는 안 본 문제로 돌아가고, 첫 세션 문제는 2순위라서)
  - 기존 `Create` 테스트 전체 통과
- `./gradlew build` (flyway validate 포함) 통과

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
- `src/test/java/gravit/code/interview/**`: "검증"의 신규 테스트(`InterviewAnswerQueryServiceIntegrationTest` 생성, 정책과 파사드 신규 케이스)는 작성하지 않고, 기존 `InterviewQuestionAllocationPolicyIntegrationTest`의 `select` 호출 7곳에 `Map.of()`만 넘김 - 이유: 테스트 작성은 implement 스킬 범위 밖(`write-test`)이고, 시그니처 변경으로 깨지는 기존 호출만 컴파일이 되도록 맞춤
