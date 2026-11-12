# [PLAN-517] 면접 결과 조회 API 구현

> 이슈: #517
> 브랜치: feat/517-interview-result-query

## 목표
`interview.md` 결과 노출 정책의 조회 5종(응시 이력, 세션 종합, 문항별 상세, 메인 화면, 약점 주제)을 구현한다. 세션 생성, 제출, 채점 파이프라인은 범위 밖이며, 이 계획은 COMPLETED 세션과 그 피드백 5건이 이미 저장돼 있다는 전제로 읽기만 한다.

응답 계약은 사용자 제공 스펙(스크래치 `api-spec-517.md`)을 따르며, 스펙에서 확정한 3가지 결정(P3 모집단, accuracyRate 식, 약점 주제 topic 객체화)을 반영한다.

## 배치 기준
- 컨트롤러, Docs, 서비스, internal DTO는 "채점 결과 노출"이 목적이므로 `interviewFeedback/`에 둔다 (`project-structure.md`: interviewFeedback = 면접 채점 결과)
- 응답 record는 중첩하지 않고 파일 하나에 하나씩 두며, 값의 출처 도메인 패키지에 배치한다
  - 세션 자체의 값(이력 항목, 추이 점, 스택 선택지) → `interview/dto/response/`
  - 문제, 개념, 주제 태그 → `interviewQuestion/dto/response/`
  - 채점 결과를 조합한 리포트(세션 종합, 문항별 상세, 약점, 대시보드) → `interviewFeedback/dto/response/`
- 의존 방향은 `interviewFeedback → interview → interviewQuestion`으로만 흐른다. 역방향 참조를 만들지 않는다

## 영향 범위
### 신규 파일

**interviewFeedback/ (조회 진입점과 리포트 응답)**
- `src/main/java/gravit/code/interviewFeedback/controller/InterviewFeedbackController.java` - 조회 5종 엔드포인트 (`/api/v1/interview-sessions`)
- `src/main/java/gravit/code/interviewFeedback/controller/docs/InterviewFeedbackControllerDocs.java` - Swagger 문서 인터페이스
- `src/main/java/gravit/code/interviewFeedback/service/InterviewFeedbackQueryService.java` - 조회 5종 서비스 (읽기 전용)
- `src/main/java/gravit/code/interviewFeedback/dto/internal/InterviewAnswerScoreDto.java` - 세션 종합용 문항 점수 프로젝션
- `src/main/java/gravit/code/interviewFeedback/dto/internal/InterviewAnswerDetailDto.java` - 문항별 상세용 프로젝션
- `src/main/java/gravit/code/interviewFeedback/dto/internal/InterviewTopicAccuracyDto.java` - 주제별 정확도 합계 프로젝션
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewSessionSummaryResponse.java` - 세션 종합 응답
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewAnswerScoreResponse.java` - 세션 종합의 문항별 점수 항목
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewWeakTopicResponse.java` - 세션 종합의 약점 분야 항목 (유닛 + 주제)
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewSessionAnswersResponse.java` - 문항별 상세 응답
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewAnswerDetailResponse.java` - 문항별 상세 항목
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewTopicAccuracyResponse.java` - 약점 주제 항목 (약점 주제 전체 조회, 대시보드 weakestTopics 공용)
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewDashboardResponse.java` - 메인 화면 응답

**interview/ (세션 값 응답, 새 파일만 추가)**
- `src/main/java/gravit/code/interview/domain/InterviewSessionSort.java` - 응시 이력 정렬 enum (`LATEST`, `OLDEST`)
- `src/main/java/gravit/code/interview/dto/response/InterviewStackResponse.java` - `{ stack, displayName }`
- `src/main/java/gravit/code/interview/dto/response/InterviewSessionHistoryResponse.java` - 응시 이력 항목 (대시보드 recentSessions 공용)
- `src/main/java/gravit/code/interview/dto/response/InterviewRecentSessionResponse.java` - 세션 종합의 최근 5개 추이 항목
- `src/main/java/gravit/code/interview/dto/response/InterviewScoreTrendResponse.java` - 대시보드 점수 추이 항목

**interviewQuestion/ (문제 값 응답, 새 파일만 추가)**
- `src/main/java/gravit/code/interviewQuestion/dto/response/InterviewTopicResponse.java` - `{ topic, displayName }`
- `src/main/java/gravit/code/interviewQuestion/dto/response/InterviewConceptResponse.java` - `{ name, type }`

**test**
- `src/test/java/gravit/code/interviewFeedback/fixture/InterviewFeedbackFixture.java` - 완료 세션 + 답안 5건 + 피드백 5건 + 문제/개념 픽스처
- `src/test/java/gravit/code/interviewFeedback/service/InterviewFeedbackQueryServiceIntegrationTest.java` - 서비스 통합 테스트

### 수정 파일
- `src/main/java/gravit/code/interview/domain/InterviewSession.java` - 파생 getter와 판정 메서드 추가 (A트랙 공유 엔티티, 메서드 추가만)
- `src/main/java/gravit/code/interview/repository/InterviewSessionRepository.java` - 조회 메서드 6개 추가 (A트랙 공유 파일, 메서드 추가만)
- `src/main/java/gravit/code/interview/repository/InterviewSessionTopicRepository.java` - `findAllBySessionIdIn` 추가 (A트랙 공유 파일, 메서드 추가만)
- `src/main/java/gravit/code/interviewQuestion/repository/InterviewQuestionConceptRepository.java` - `findAllByQuestionIdIn...` 추가 (공유 파일, 메서드 추가만)
- `src/main/java/gravit/code/interviewFeedback/repository/InterviewFeedbackRepository.java` - 피드백 기준 조인 쿼리 3개 추가
- `src/test/resources/sql/truncate_all.sql` - interview 6개 테이블 TRUNCATE와 IDENTITY 초기화 추가
- `.claude/spec/service-policy/interview.md` - P3 확정, 정확도율 계산식, 반올림 규칙, 미완료 세션 조회 거부, 최근 5개 추이의 기준 시각 명시

> `interview/`, `interviewQuestion/`의 기존 파일은 메서드 추가만 하고 기존 코드를 고치지 않는다 (#503에서 "쿼리 메서드는 각자 브랜치에서 추가한다"로 합의). 이 두 패키지에 새로 두는 응답 record와 enum은 새 파일이라 A트랙 브랜치와 충돌하지 않으며, A트랙의 스택 목록 API도 `InterviewStackResponse`를 그대로 쓸 수 있다.

## 구현 계획

### 1. Entity / Flyway
DB 변경 없음. V41 스키마와 인덱스 `ix_interview_session_user_started (user_id, started_at DESC)`를 그대로 쓴다. 모든 "최신순" 정렬은 이 인덱스를 타도록 `startedAt DESC, id DESC`를 기준으로 한다 (`attempt_count`에는 유니크 제약이 없어 정렬 키로 쓰지 않고 표시값으로만 쓴다).

`InterviewSession`에 아래 메서드를 추가한다 (필드, 생성자, `create`는 손대지 않는다):

```java
public int getScore()                    // accuracyScore + deliveryScore
public int getMaxScore()                 // accuracyMaxScore + structureMaxScore + clarityMaxScore
public int getDeliveryMaxScore()         // structureMaxScore + clarityMaxScore
public int getQuestionMaxScore()         // getMaxScore() / QUESTION_COUNT
public int getQuestionAccuracyMaxScore() // accuracyMaxScore / QUESTION_COUNT
public int getQuestionStructureMaxScore()// structureMaxScore / QUESTION_COUNT
public int getQuestionClarityMaxScore()  // clarityMaxScore / QUESTION_COUNT
public boolean isCompleted()             // status == InterviewSessionStatus.COMPLETED
public boolean isOwnedBy(long userId)    // this.userId == userId
```

### 2. Repository

**`InterviewSessionRepository`** (interview/, 추가만)

```java
Slice<InterviewSession> findAllByUserIdAndStatus(
        long userId,
        InterviewSessionStatus status,
        Pageable pageable
);                                       // 응시 이력. 정렬은 Pageable의 Sort로 전달

long countByUserIdAndStatus(
        long userId,
        InterviewSessionStatus status
);                                       // 완료 세션 수

@Query("""
        SELECT s FROM InterviewSession s
        WHERE s.userId = :userId AND s.status = :status
        ORDER BY s.startedAt DESC, s.id DESC
        """)
List<InterviewSession> findRecentByUserIdAndStatus(
        @Param("userId") long userId,
        @Param("status") InterviewSessionStatus status,
        Pageable pageable
);                                       // 대시보드 최근 5개 (PageRequest.of(0, 5))

@Query("""
        SELECT s FROM InterviewSession s
        WHERE s.userId = :userId AND s.status = :status AND s.startedAt <= :startedAt
        ORDER BY s.startedAt DESC, s.id DESC
        """)
List<InterviewSession> findRecentByUserIdAndStatusStartedAtOrBefore(
        @Param("userId") long userId,
        @Param("status") InterviewSessionStatus status,
        @Param("startedAt") LocalDateTime startedAt,
        Pageable pageable
);                                       // 세션 종합의 "이 세션을 포함한 최근 5개"

@Query("SELECT AVG(s.accuracyScore) FROM InterviewSession s WHERE s.status = :status")
Double findAverageAccuracyScoreByStatus(@Param("status") InterviewSessionStatus status);

@Query("SELECT AVG(s.deliveryScore) FROM InterviewSession s WHERE s.status = :status")
Double findAverageDeliveryScoreByStatus(@Param("status") InterviewSessionStatus status);
                                         // P3 확정: 전체 사용자 완료 세션 평균. 스칼라 2회로 나눠 interview → interviewFeedback 역방향 DTO 의존을 만들지 않는다
```

**`InterviewSessionTopicRepository`** (interview/, 추가만)

```java
List<InterviewSessionTopic> findAllBySessionIdIn(Collection<Long> sessionIds);
```

**`InterviewQuestionConceptRepository`** (interviewQuestion/, 추가만)

```java
List<InterviewQuestionConcept> findAllByQuestionIdInOrderByQuestionIdAscDisplayOrderAsc(Collection<Long> questionIds);
```

**`InterviewFeedbackRepository`** (interviewFeedback/, 소유)

피드백을 루트로 답안, 문제, 세션을 `JOIN ... ON`으로 묶는다 (`UserFeedRepository`의 비연관 조인 선례). COMPLETED 세션은 피드백이 정확히 5건이므로 피드백 루트 조회로 문항 5개가 모두 나온다.

```java
@Query("""
        SELECT new gravit.code.interviewFeedback.dto.internal.InterviewAnswerScoreDto(
            a.displayOrder, q.topic, q.unitId, f.accuracyScore, f.structureScore, f.clarityScore
        )
        FROM InterviewFeedback f
        JOIN InterviewAnswer a ON a.id = f.answerId
        JOIN InterviewQuestion q ON q.id = a.questionId
        WHERE a.sessionId = :sessionId
        ORDER BY a.displayOrder ASC
        """)
List<InterviewAnswerScoreDto> findAnswerScoresBySessionId(@Param("sessionId") long sessionId);

@Query("""
        SELECT new gravit.code.interviewFeedback.dto.internal.InterviewAnswerDetailDto(
            a.displayOrder, q.id, q.topic, q.content, a.content, a.audioKey, q.modelAnswer,
            f.improvementSuggestion, f.accuracyScore, f.structureScore, f.clarityScore
        )
        FROM InterviewFeedback f
        JOIN InterviewAnswer a ON a.id = f.answerId
        JOIN InterviewQuestion q ON q.id = a.questionId
        WHERE a.sessionId = :sessionId
        ORDER BY a.displayOrder ASC
        """)
List<InterviewAnswerDetailDto> findAnswerDetailsBySessionId(@Param("sessionId") long sessionId);

@Query("""
        SELECT new gravit.code.interviewFeedback.dto.internal.InterviewTopicAccuracyDto(
            q.topic, SUM(f.accuracyScore), SUM(s.accuracyMaxScore)
        )
        FROM InterviewFeedback f
        JOIN InterviewAnswer a ON a.id = f.answerId
        JOIN InterviewSession s ON s.id = a.sessionId
        JOIN InterviewQuestion q ON q.id = a.questionId
        WHERE s.userId = :userId AND s.status = :status
        GROUP BY q.topic
        """)
List<InterviewTopicAccuracyDto> findTopicAccuracyByUserIdAndStatus(
        @Param("userId") long userId,
        @Param("status") InterviewSessionStatus status
);
```

- `SUM(s.accuracyMaxScore)`는 문항마다 세션 만점(70)이 더해진 값이므로 문항 정확도 만점 합은 이 값을 `QUESTION_COUNT`로 나눈 것이다. 나눗셈은 서비스에서 한다
- `SUM` 결과는 Hibernate가 `Long`으로 돌려주므로 프로젝션 record의 두 합계 컴포넌트는 `Long`으로 선언한다 (생성자 매칭 실패 방지)

### 3. Service

`InterviewFeedbackQueryService` (`@Service` + `@RequiredArgsConstructor`, 모든 public 메서드 `@Transactional(readOnly = true)`)

주입: `InterviewSessionRepository`, `InterviewSessionTopicRepository` / `InterviewQuestionConceptRepository` / `InterviewFeedbackRepository` (도메인별 빈 줄 그룹핑). 타 패키지 리포지토리 주입은 `AdminUnitService`, `AdminProblemService` 선례를 따른다. interview 3개 패키지는 소유 분리를 위해 나뉜 하나의 도메인이므로 조회 서비스는 하나로 둔다.

상수:

```java
private static final int PAGE_SIZE = 10;
private static final int RECENT_SESSION_COUNT = 5;
private static final int DASHBOARD_RECENT_SESSION_COUNT = 3;
private static final int WEAKEST_TOPIC_COUNT = 3;
private static final int PERCENT = 100;
private static final double DECIMAL_SCALE = 10.0;   // 소수점 첫째 자리 반올림 (UserLevel, Mission 선례)
private static final double EMPTY_AVERAGE = 0.0;
```

**`SliceResponse<InterviewSessionHistoryResponse> getSessionHistory(long userId, int page, InterviewSessionSort sort)`**
1. `safePage = Math.max(0, page)` (`SocialFeedService` 선례)
2. `Sort.Direction direction = sort == LATEST ? DESC : ASC`, `Pageable = PageRequest.of(safePage, PAGE_SIZE, Sort.by(direction, "startedAt").and(Sort.by(direction, "id")))`
3. `Slice<InterviewSession> slice = sessionRepository.findAllByUserIdAndStatus(userId, COMPLETED, pageable)`
4. `List<InterviewSessionHistoryResponse> contents = toHistoryResponses(slice.getContent())`
5. `return SliceResponse.of(slice.hasNext(), contents)`

**`InterviewSessionSummaryResponse getSessionSummary(long userId, long sessionId)`**
1. `InterviewSession session = getCompletedSession(userId, sessionId)`
2. 전체 평균: `Double avgAcc = sessionRepository.findAverageAccuracyScoreByStatus(COMPLETED)`, `Double avgDel = ...DeliveryScore...` → `roundToOneDecimal(Objects.requireNonNullElse(avg, EMPTY_AVERAGE))`. 조회 중인 세션이 COMPLETED이므로 실제로는 null이 아니지만 방어한다
3. 최근 추이: `sessionRepository.findRecentByUserIdAndStatusStartedAtOrBefore(userId, COMPLETED, session.getStartedAt(), PageRequest.of(0, RECENT_SESSION_COUNT))` → 리스트를 뒤집어(오래된 순) `InterviewRecentSessionResponse.from(session)`으로 매핑
4. 문항 점수: `List<InterviewAnswerScoreDto> scores = feedbackRepository.findAnswerScoresBySessionId(sessionId)`
   - `answers`: 각 행을 `InterviewAnswerScoreResponse.from(row)` (deliveryScore = structureScore + clarityScore)
   - `weakTopics`: `(accuracy + structure + clarity) * 2 <= session.getQuestionMaxScore()`인 행만 남기고, `unitId` 기준 첫 등장(표시 순서가 빠른 문항)만 유지 (`Collectors.toMap(unitId, row, (a, b) -> a, LinkedHashMap::new)`) → `InterviewWeakTopicResponse.of(unitId, topic)`
5. `InterviewSessionSummaryResponse.of(session, avgAcc, avgDel, recentSessions, answers, weakTopics)`

**`InterviewSessionAnswersResponse getSessionAnswers(long userId, long sessionId)`**
1. `session = getCompletedSession(userId, sessionId)`
2. `List<InterviewAnswerDetailDto> details = feedbackRepository.findAnswerDetailsBySessionId(sessionId)`
3. `questionIds = details.stream().map(questionId).toList()` → `conceptRepository.findAllByQuestionIdInOrderByQuestionIdAscDisplayOrderAsc(questionIds)` → `Map<Long, List<InterviewConceptResponse>>`으로 그룹핑 (`groupingBy(questionId, LinkedHashMap::new, mapping(InterviewConceptResponse::from, toList()))`)
4. 각 행을 `InterviewAnswerDetailResponse.of(row, conceptsByQuestion.getOrDefault(row.questionId(), List.of()), session)`으로 매핑. 문항 만점 3종은 `session.getQuestionAccuracyMaxScore()` 등에서 가져온다. 무응답 문항은 저장된 값이 그대로 나온다 (`answerContent` null, `improvementSuggestion` null, 점수 0) - 별도 분기 없음
5. `InterviewSessionAnswersResponse.of(sessionId, answers)`

**`InterviewDashboardResponse getDashboard(long userId)`**
1. `long completedCount = sessionRepository.countByUserIdAndStatus(userId, COMPLETED)`
2. `List<InterviewSession> recent = sessionRepository.findRecentByUserIdAndStatus(userId, COMPLETED, PageRequest.of(0, RECENT_SESSION_COUNT))` (최신순 최대 5개)
3. `recentAverageScore`: `recent`가 비어 있으면 `EMPTY_AVERAGE`, 아니면 `roundToOneDecimal(recent.stream().mapToInt(InterviewSession::getScore).average().orElse(EMPTY_AVERAGE))`
4. `recentSessions`: `toHistoryResponses(recent.subList(0, Math.min(DASHBOARD_RECENT_SESSION_COUNT, recent.size())))`
5. `scoreTrends`: `recent`를 뒤집어(오래된 순) `InterviewScoreTrendResponse.from(session)` (`sequence = attemptCount`, `score = getScore()`)
6. `weakestTopics`: `calculateTopicAccuracies(userId)`의 앞 `WEAKEST_TOPIC_COUNT`개
7. `InterviewDashboardResponse.of(completedCount, recentAverageScore, weakestTopics, recentSessions, scoreTrends)`

**`List<InterviewTopicAccuracyResponse> getWeakTopics(long userId)`**
- `return calculateTopicAccuracies(userId)`

**private 메서드**

```java
private InterviewSession getCompletedSession(long userId, long sessionId)
// findById → INTERVIEW_SESSION_NOT_FOUND(4003)
// !isOwnedBy(userId) → INTERVIEW_SESSION_ACCESS_DENIED(4004)
// !isCompleted() → INTERVIEW_FEEDBACK_NOT_READY(4012)   // 순서 고정: 없음 → 권한 → 상태

private List<InterviewSessionHistoryResponse> toHistoryResponses(List<InterviewSession> sessions)
// 비어 있으면 List.of()
// sessionIds 추출 → topicRepository.findAllBySessionIdIn(sessionIds) → Map<Long, List<InterviewTopic>> (InterviewTopic 선언 순으로 정렬: CS → 공통 → 언어 → 프레임워크)
// 세션 순서를 유지하며 InterviewSessionHistoryResponse.of(session, topics.getOrDefault(id, List.of()))

private List<InterviewTopicAccuracyResponse> calculateTopicAccuracies(long userId)
// rows = feedbackRepository.findTopicAccuracyByUserIdAndStatus(userId, COMPLETED)
// rate = roundToOneDecimal(row.accuracyScoreSum() * PERCENT * InterviewSession.QUESTION_COUNT / (double) row.accuracyMaxScoreSum())
//   (= Σ정확도 / Σ문항 정확도 만점 x 100. 분모는 세션 만점 합 / 5. 무응답 문항은 0점으로 분자에 포함된다)
// accuracyRate 오름차순, 같으면 InterviewTopic 선언 순 → InterviewTopicAccuracyResponse.of(topic, rate)

private double roundToOneDecimal(double value)
// Math.round(value * DECIMAL_SCALE) / DECIMAL_SCALE
```

### 4. Facade
불필요 - 단일 Service. Controller가 `InterviewFeedbackQueryService`를 직접 주입한다. 엔티티를 경계 밖으로 내보내지 않고(모두 서비스 안에서 응답 record로 변환), 여러 Service를 조합하지도 않는다.

### 5. DTO

모두 `record`, 파일 하나에 record 하나(중첩 없음). 응답은 정적 팩토리 + `@Builder(access = AccessLevel.PRIVATE)`, 각 필드 `@Schema`. 스펙의 `int` 필드 중 엔티티가 `long`인 것(`sequence`, `completedSessionCount`)은 `long`으로 선언한다 (JSON 표현은 동일하고 내로잉 캐스트를 피한다).

**enum** - `interview/domain/InterviewSessionSort { LATEST, OLDEST }`. 본문 없는 단순 enum. Spring Data `Sort`로의 변환은 서비스 private 로직에 둔다

**internal DTO (쿼리 프로젝션)** - `interviewFeedback/dto/internal/`, 접미사 `Dto`. JPQL 생성자 표현식 대상이라 표준 생성자를 쓴다
- `InterviewAnswerScoreDto(int displayOrder, InterviewTopic topic, long unitId, int accuracyScore, int structureScore, int clarityScore)`
- `InterviewAnswerDetailDto(int displayOrder, long questionId, InterviewTopic topic, String questionContent, String answerContent, String audioKey, String modelAnswer, String improvementSuggestion, int accuracyScore, int structureScore, int clarityScore)`
- `InterviewTopicAccuracyDto(InterviewTopic topic, Long accuracyScoreSum, Long accuracyMaxScoreSum)`

**interviewQuestion/dto/response/** (문제 값)
- `InterviewTopicResponse(InterviewTopic topic, String displayName)` - `from(InterviewTopic)`. enum 타입 그대로 두면 JSON은 이름 문자열로 나가고 Swagger에 값 목록이 실린다
- `InterviewConceptResponse(String name, InterviewConceptType type)` - `from(InterviewQuestionConcept)`

**interview/dto/response/** (세션 값)
- `InterviewStackResponse(InterviewStack stack, String displayName)` - `from(InterviewStack)`. 호출부에서 `stack == null ? null : from(stack)`
- `InterviewSessionHistoryResponse(long sessionId, long sequence, InterviewMode mode, InterviewStackResponse stack, List<InterviewTopicResponse> topics, LocalDateTime startedAt, int score, int maxScore)` - `of(InterviewSession, List<InterviewTopic>)`
- `InterviewRecentSessionResponse(long sessionId, long sequence, int accuracyScore, int deliveryScore)` - `from(InterviewSession)`. 세션 종합의 `recentSessions` 항목
- `InterviewScoreTrendResponse(long sequence, int score)` - `from(InterviewSession)`. 대시보드 `scoreTrends` 항목

**interviewFeedback/dto/response/** (채점 결과 리포트)
- `InterviewAnswerScoreResponse(int displayOrder, InterviewTopicResponse topic, int accuracyScore, int deliveryScore)` - `from(InterviewAnswerScoreDto)`
- `InterviewWeakTopicResponse(long unitId, InterviewTopicResponse topic)` - `of(long unitId, InterviewTopic)`
- `InterviewSessionSummaryResponse(long sessionId, long sequence, LocalDateTime startedAt, int score, int maxScore, int accuracyScore, int accuracyMaxScore, int deliveryScore, int deliveryMaxScore, double averageAccuracyScore, double averageDeliveryScore, List<InterviewRecentSessionResponse> recentSessions, List<InterviewAnswerScoreResponse> answers, List<InterviewWeakTopicResponse> weakTopics)` - `of(InterviewSession, double avgAcc, double avgDel, List<InterviewRecentSessionResponse>, List<InterviewAnswerScoreResponse>, List<InterviewWeakTopicResponse>)`
- `InterviewAnswerDetailResponse(int displayOrder, InterviewTopicResponse topic, String questionContent, String answerContent, String audioKey, String modelAnswer, List<InterviewConceptResponse> concepts, String improvementSuggestion, int accuracyScore, int accuracyMaxScore, int structureScore, int structureMaxScore, int clarityScore, int clarityMaxScore)` - `of(InterviewAnswerDetailDto, List<InterviewConceptResponse>, InterviewSession)`
- `InterviewSessionAnswersResponse(long sessionId, List<InterviewAnswerDetailResponse> answers)` - `of(long sessionId, List<InterviewAnswerDetailResponse>)`
- `InterviewTopicAccuracyResponse(InterviewTopicResponse topic, double accuracyRate)` - `of(InterviewTopic, double)`
- `InterviewDashboardResponse(long completedSessionCount, double recentAverageScore, List<InterviewTopicAccuracyResponse> weakestTopics, List<InterviewSessionHistoryResponse> recentSessions, List<InterviewScoreTrendResponse> scoreTrends)` - `of(...)` 같은 순서

같은 JSON 키를 쓰지만 모양이 다른 두 `recentSessions`는 이름으로 구분한다: 세션 종합은 `InterviewRecentSessionResponse`(4필드), 대시보드는 `InterviewSessionHistoryResponse`(이력 항목과 동일 8필드).

### 6. Controller

`InterviewFeedbackController` (`@RestController`, `@RequestMapping("/api/v1/interview-sessions")`, `implements InterviewFeedbackControllerDocs`, `InterviewFeedbackQueryService` 주입). A트랙의 세션 생성, 제출 컨트롤러와 base path를 공유하지만 개별 매핑이 겹치지 않는다 (`/dashboard`, `/weak-topics`는 1세그먼트, `/{sessionId}/summary`, `/{sessionId}/answers`는 2세그먼트).

| HTTP | 경로 | 메서드 | 응답 |
|---|---|---|---|
| GET | `` (base) | `getSessionHistory(@AuthenticationPrincipal LoginUser, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "LATEST") InterviewSessionSort sort)` | `200 SliceResponse<InterviewSessionHistoryResponse>` |
| GET | `/{sessionId}/summary` | `getSessionSummary(LoginUser, @PathVariable long sessionId)` | `200 InterviewSessionSummaryResponse` |
| GET | `/{sessionId}/answers` | `getSessionAnswers(LoginUser, @PathVariable long sessionId)` | `200 InterviewSessionAnswersResponse` |
| GET | `/dashboard` | `getDashboard(LoginUser)` | `200 InterviewDashboardResponse` |
| GET | `/weak-topics` | `getWeakTopics(LoginUser)` | `200 List<InterviewTopicAccuracyResponse>` |

- 모두 `ResponseEntity.status(HttpStatus.OK).body(...)`
- `size` 파라미터는 받지 않는다 (스펙: 기본 10, 명시 X)

`InterviewFeedbackControllerDocs`: `@Tag(name = "Interview Feedback API")`, 각 메서드에 `@Operation`(summary, `🔐 <strong>Jwt 필요</strong>`), `@Parameter`(page, sort, sessionId), `@ApiResponses`(200 예시 JSON, 세션 조회 2종은 404 `INTERVIEW_4003` / 403 `INTERVIEW_4004` / 409 `INTERVIEW_4012`, 전부 500 `GLOBAL_5001`). 세부 표기는 `api-docs-convention.md`를 따른다.

### 7. 테스트 리소스

`truncate_all.sql`에 추가 (FK 순서는 `session_replication_role = replica`로 무시되므로 순서 무관):

```sql
TRUNCATE TABLE interview_feedback CASCADE;
TRUNCATE TABLE interview_answer CASCADE;
TRUNCATE TABLE interview_session_topic CASCADE;
TRUNCATE TABLE interview_session CASCADE;
TRUNCATE TABLE interview_question_concept CASCADE;
TRUNCATE TABLE interview_question CASCADE;
-- IDENTITY 초기화 6줄
```

`interview_question`은 현재 Flyway 시딩이 없어 지운다. 이후 A트랙이 문제 시딩 마이그레이션을 넣으면 `mission`처럼 제외 대상으로 바꿔야 한다 (계획서 하단 "나중에 고려할 문제").

### 8. 서비스 정책 갱신 (`interview.md`)

- **결과 노출**
  - "전체 평균의 모집단은 미결 과제(P3)다" → "전체 평균은 서비스 전체 사용자의 완료 세션 평균이다"
  - 최근 5개 추이 기준 추가: "세션 종합의 최근 5개는 조회 중인 세션의 시작 시각 이전(포함)에 시작한 완료 세션이다"
  - 추가: "완료되지 않은 세션의 종합, 문항별 상세 조회는 거부한다(채점 미완료 오류). 다른 사용자의 세션은 접근 거부다"
  - 추가: "평균 점수와 정확도율은 소수점 첫째 자리까지 반올림한다"
  - 추가: "응시 이력과 최근 세션의 정렬 기준은 시작 시각이다. 세션의 주제 목록은 태그 선언 순(CS, 직군 공통, 언어, 프레임워크)으로 나간다"
- **약점 판정**: "정확도율은 주제별 완료 세션 문항의 정확도 점수 합을 문항 정확도 만점 합으로 나눈 값(0~100)이다. 무응답 문항은 0점으로 포함한다"
- **미결 과제** 표: P3 행을 "확정 - 전체 사용자 완료 세션 평균. 산정 비용(status 전체 스캔)은 데이터가 늘면 재검토"로 갱신

## 결정 필요 (Decisions needed)
- [x] P3 평균 모집단 - 전체 사용자의 COMPLETED 세션 평균 (사용자 확정, 2026-09-04)
- [x] accuracyRate 계산식 - Σ정확도 점수 / Σ문항 정확도 만점 x 100, 무응답 0점 포함 (사용자 확정)
- [x] 약점 주제 응답의 topic 형태 - `{ topic, displayName }` 객체로 통일 (사용자 확정, 스펙 3곳 수정)
- [x] 응답 record 구조 - 중첩하지 않고 파일 하나에 하나, 값의 출처 도메인 패키지에 배치 (사용자 확정. 재사용 시 꺼내는 비용보다 단일 용도 파일이 늘어나는 쪽을 감수)

계획에서 기본값으로 정한 사항 (이의 없으면 유지):
- 소수 값 반올림: 평균과 정확도율 모두 소수점 첫째 자리 (`Math.round(x * 10) / 10.0`, `UserLevel`, `Mission` 선례)
- "이 세션을 포함한 최근 5개"의 기준: 조회 세션의 `startedAt` 이하인 완료 세션 (오래된 세션을 조회해도 그 시점의 추이가 나온다)
- 미완료 세션(진행 중, 채점 중, 채점 실패, 취소)의 종합/상세 요청은 모두 `INTERVIEW_4012`로 거부. 취소 세션에는 메시지("채점이 완료되지 않아")가 약간 어긋나지만 새 코드를 만들지 않는다
- 응시 이력 `page` 음수는 0으로 보정 (`SocialFeedService` 선례). 1-based가 아니라 스펙대로 0-based
- 컨트롤러, Docs, 서비스의 접두는 패키지 도메인 그대로 `InterviewFeedback*` (`{Domain}Controller`, `{Domain}QueryService` 컨벤션. 처음 잡았던 `InterviewResult*`는 존재하지 않는 도메인명이라 사용자 지시로 변경)
- 조회 서비스는 하나(`InterviewFeedbackQueryService`)로 두고 3개 패키지 리포지토리를 직접 주입한다. 패키지별 서비스 3개 + Facade로 나누면 조합 로직만 늘고 얻는 것이 없다

## 검증
- `InterviewFeedbackQueryServiceIntegrationTest` (`@TCSpringBootTest`, `truncate_all.sql`)
  - 픽스처 `InterviewFeedbackFixture`: `InterviewQuestion.create` + `InterviewQuestionConcept.create`로 문제를 만들고, `InterviewSession.create` 후 `ReflectionTestUtils.setField`로 `status`, `accuracyScore`, `deliveryScore`, `startedAt`을 세팅 (`LearningFixture`의 비-id 필드 setField 선례), 답안 5건은 `create` 후 `status`/`content` setField, 피드백 5건은 `InterviewFeedback.create`
  - 응시 이력: COMPLETED만 나오고 IN_PROGRESS/ABANDONED는 제외, `LATEST`/`OLDEST` 정렬, 11건일 때 `hasNextPage` true, `topics`가 태그 선언 순
  - 세션 종합: 점수와 만점 4쌍, 전체 평균이 다른 사용자 세션까지 포함해 계산되는지, 최근 5개가 오래된 순이고 조회 세션이 포함되는지, `weakTopics`가 절반 이하 문항의 유닛만 중복 없이 담는지
  - 문항별 상세: 5문항 표시 순, 개념 목록이 문제별로 붙는지, 무응답 문항의 null과 0점, 문항 만점(14/3/3)
  - 대시보드: 완료 수, 최근 5개 평균(소수점 첫째 자리), 최신 3개, 추이 오래된 순, 약점 주제 하위 3개, 완료 세션이 없을 때 0과 빈 목록
  - 약점 주제: 정확도율 계산값(예: 정확도 7/14 → 50.0), 오름차순 정렬, 다른 사용자 데이터 미포함
  - 예외: 없는 세션 → `INTERVIEW_SESSION_NOT_FOUND`, 타인 세션 → `INTERVIEW_SESSION_ACCESS_DENIED`, IN_PROGRESS 세션 → `INTERVIEW_FEEDBACK_NOT_READY` (errorCode까지 검증, static import)
- `./gradlew build`로 컴파일과 기존 테스트 전체 통과 확인

## 나중에 고려할 문제
- 정렬 파라미터에 enum 밖의 값이 오면 `MethodArgumentTypeMismatchException`이 전역 `Exception` 핸들러로 떨어져 500이 난다. 전역 핸들러에 400(`GLOBAL_4001`) 매핑을 추가하는 것은 공통 모듈 변경이라 별도 이슈로 뺀다 (기존 코드에도 enum `@RequestParam`이 없어 지금까지 드러나지 않았다)
- 전체 평균 쿼리는 `interview_session.status`에 인덱스가 없어 테이블 전체를 읽는다. 데이터가 쌓이면 `(status)` 부분 인덱스나 집계 캐시를 검토한다
- `interview_question` 시딩 마이그레이션이 들어오면 `truncate_all.sql`에서 제외해야 한다
- A트랙의 스택 목록 API(`interview/`)가 `InterviewStackResponse`를 그대로 쓰도록 머지 시점에 알린다. 같은 모양을 따로 만들면 중복이 된다

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
- `interview/dto/response/InterviewSessionHistorySliceResponse.java`: Swagger 문서 전용 슬라이스 record 추가 — 이유: 제네릭 `SliceResponse<T>`는 `@Schema(implementation)`에 항목 타입이 실리지 않아, 기존 목록 API(`SocialFeedSliceResponse`, `FollowerSliceResponse`)와 같은 방식으로 문서 전용 record를 둔다. 런타임 응답은 계획대로 `SliceResponse<InterviewSessionHistoryResponse>`다
- `interviewFeedback/controller/InterviewFeedbackController.java`, `controller/docs/InterviewFeedbackControllerDocs.java`, `service/InterviewFeedbackQueryService.java`: `InterviewResult*`에서 이름 변경 — 이유: 사용자 지시. 존재하지 않는 도메인명 대신 패키지 도메인(`{Domain}Controller`, `{Domain}QueryService`) 컨벤션을 따른다. Swagger 태그도 `Interview Feedback API`로 변경
- `InterviewSessionSummaryResponse`, `InterviewDashboardResponse`: `averageAccuracyScore`, `averageDeliveryScore`, `recentAverageScore`를 `double`(소수 첫째 자리)에서 `int`(반올림 정수)로 변경 — 이유: 사용자 리뷰. 정수 점수의 평균에 소수점은 정보를 더하지 않는다. `accuracyRate`(비율)는 소수 첫째 자리 유지. `interview.md` 반올림 문장 갱신
- `InterviewQuestionConceptRepository`: 네이밍 메서드 `findAllByQuestionIdInOrderByQuestionIdAscDisplayOrderAsc`를 JPQL `findAllByQuestionIds`로 전환 — 이유: 사용자 리뷰. 긴 네이밍 메서드는 무엇을 하는 쿼리인지 드러나지 않는다
- `InterviewFeedbackQueryService`: Map 변수명을 `{키}To{값}` 형태로 변경(`questionIdToConcepts`, `sessionIdToTopics`, `unitIdToTopic`) — 이유: 사용자 리뷰. `{값}By{키}`는 리포지토리 메서드처럼 읽힌다. `common.md` 네이밍 규칙 추가
- `global/util/DecimalRounding.java` 신규, 서비스의 `roundToOneDecimal` 제거 — 이유: 사용자 리뷰. 도메인과 무관한 반올림이 서비스 private에 있었고 `UserLevel`, `Mission`에도 같은 식이 중복돼 있어 공용 유틸로 올림(기존 두 곳은 범위 밖)
- `InterviewSessionSort`: `Sort.Direction` 속성과 `by(String... properties)` 추가, 서비스의 `toSort` 제거 — 이유: 사용자 리뷰. 정렬 방향 의미는 enum이, 정렬 필드명은 서비스가 갖도록 분리
- `InterviewSessionRepository.findAverageScoresByStatus` + `interview/dto/internal/InterviewSessionAverageDto`: AVG 스칼라 쿼리 2개를 생성자 표현식 1개로 통합, `COALESCE(AVG, 0.0)`으로 null 방어를 쿼리로 이동 — 이유: 사용자 리뷰. DTO를 출처 도메인(`interview/`)에 두는 규칙이 생겨 역방향 의존 문제가 사라짐. 서비스의 `Objects.requireNonNullElse` 제거
- `InterviewSession.isWeakAnswer(int earnedScore)` 추가, `InterviewAnswerScoreDto.earnedScore()` 추가, 서비스의 `isWeak`/`HALF` 제거 — 이유: 사용자 리뷰. 약점 판정은 세션 채점 정책이라 만점을 아는 엔티티가 갖는다
- `InterviewTopicAccuracyDto.accuracyRate()` 추가, 서비스의 `calculateAccuracyRate`/`PERCENT` 제거. 정렬은 응답 대신 행 DTO 기준(`accuracyRate`, `topic`)으로 — 이유: 사용자 리뷰. 산식은 행이 가진 값으로 결정되므로 행 DTO가 갖는다
- `InterviewFeedbackQueryService.getDashboard`: 엔티티 목록 `recentCompletedSessions`, 응답 목록 `recentSessions`로 이름 분리, `subList` → `stream().limit()`. 상수 `RECENT_SESSIONS` → `RECENT_SESSION_PAGE`, private 메서드 `getConceptsByQuestionId` → `groupConceptsByQuestionId` — 이유: 사용자 리뷰(가독성, 네이밍 규칙 일관성)
- `InterviewSessionSort`: 정렬 필드명(`startedAt`, `id`)을 enum 안으로 옮기고 `by(String...)` → `toSort()`. 서비스의 `SORT_*` 상수 제거 — 이유: 사용자 리뷰. 세션 전용 enum이 "최신순"의 정의를 통째로 갖는 것이 응집도가 높다
- `src/test/resources/sql/truncate_all.sql`: 계획의 interview 6개 테이블 추가를 되돌림 — 이유: `TCSpringBootTest`의 `DatabaseClearExtension`이 매 테스트 전에 `pg_tables` 기준으로 public 테이블 전부를 TRUNCATE하므로 스크립트 갱신이 불필요(통합 테스트 89개 중 88개가 `@Sql` 미사용). `test-convention.md`의 `@Sql` 안내는 실제 관행과 어긋나 후속 정리 대상
