# [PLAN-500] AI 면접 시뮬레이터 도메인 모델 정의

> 이슈: #500
> 브랜치: feat/500-interview-domain

## 목표

AI 면접 시뮬레이터의 기반이 되는 Entity 10종과 enum, 이를 생성하는 Flyway 마이그레이션을 정의한다.
세션 생성, 답변 제출, 비동기 채점 등 서비스 로직은 이번 범위가 아니며, 후속 이슈가 이 모델 위에 구현한다.

## 배경

### 설계 전제

| 항목 | 확정 |
|---|---|
| 질문 | 사전 저장 |
| 핵심 개념 | 개념명 + 필수/보조 구분까지만 사전 저장 |
| 인정 기준 | 저장하지 않음 (채점 시점 AI 판단) |
| 누락 시 피드백 문구 | 저장하지 않음 (채점 시점 AI 생성) |
| 모범답안 | 저장하지 않음 |
| 채점 | 전 과정 AI 위임. 단 점수 계산은 고정 규칙 코드 |

인정 기준과 피드백 문구를 저장하지 않으므로 채점 프롬프트가 개념명만 받아 판정한다.
따라서 `interview_question_concept.name`은 판정 가능한 문장이어야 한다 (`"시간복잡도"`가 아니라 `"평균 시간복잡도가 O(n log n)임을 언급"`).
이 제약은 코드로 강제할 수 없으므로 `.claude/spec/service-policy/interview.md`에 정책으로 남긴다.

### 연관관계 매핑 방식

팀 JPA 컨벤션대로 `@ManyToOne` 없이 plain ID 컬럼(`long categoryId`)을 쓰고 조인은 JPQL로 수동 작성한다.
`UserMission.missionId`, `LessonSubmission.lessonId`가 같은 방식이다.

### 명세와 달라지는 지점

계획 단계에서 그대로 옮기면 깨지거나 근거를 남겨야 하는 항목이 다섯 있다.

**1. `InterviewAnswer.order` → `displayOrder`**

`order`는 SQL 예약어라 컬럼명으로 쓰면 `ORDER BY`와 파서 충돌이 난다. `@Column(name = "\"order\"")`로 따옴표 이스케이프하는 방법도 있으나, 이후 모든 네이티브 쿼리에서 같은 이스케이프를 반복해야 한다.
필드명 `displayOrder`, 컬럼명 `display_order`로 바꾼다. 의미(1~5 표시용)도 그대로 드러난다.

**2. `content`, `quote` 등 장문 컬럼은 `TEXT`**

`interview_question.content`, `interview_answer.content`, `improvement_suggestion`, `quote`, `missing_feedback_text`, `quoted_text`, `correction_text`는 `VARCHAR(255)`를 넘긴다.
`Notice.content`, `Inquiry.content`와 동일하게 `@Column(columnDefinition = "TEXT")`로 잡는다.

**3. 난이도와 레벨을 왜 나누는가**

`InterviewQuestion.difficulty`와 `InterviewSession.level`은 값 집합이 `HIGH`/`MEDIUM`/`LOW`로 같지만 enum 타입을 나눈다.

세션 레벨이 질문을 어떻게 고르는지가 아직 정해지지 않았다. `POST /interview-sessions`의 "사전 정의 풀에서 조건에 맞는 문제 N개 선별"이 명세의 전부다. 두 갈래가 있다.

- **일치 필터** - HIGH 세션은 `difficulty = HIGH`인 질문만 뽑는다. 이러면 두 값이 같은 척도라 타입이 하나여도 된다.
- **구성 프로파일** - HIGH 세션은 상 3 + 중 2처럼 난이도를 섞어 5문항을 뽑는다. 이러면 `level`은 난이도가 아니라 문항 구성 규칙의 이름이고, 나중에 `MIXED` 같은 값이 붙어도 질문 난이도는 세 단계로 남는다.

후자로 갈 가능성이 높다. 일치 필터는 특정 카테고리에 해당 난이도 질문이 5개 미만이면 세션 생성이 실패하고, 난이도별로 질문 풀을 균등하게 채워야 하는 운영 부담을 만든다.

이번 이슈에서는 어느 쪽이든 컬럼이 `VARCHAR(255) CHECK IN ('HIGH','MEDIUM','LOW')` 두 개로 동일하다. 나눠 뒀다가 나중에 합치는 것은 한쪽을 지우고 참조를 바꾸면 되지만, 합쳐 뒀다가 나누려면 사용처를 전부 훑어야 한다. 되돌리기 쉬운 쪽을 택한다.

**선별 규칙 자체는 세션 생성 서비스를 만드는 후속 이슈에서 확정한다.**

**4. 문항 수는 5개, 세션 총점은 100점**

최초 명세는 `accuracyMaxScore = 84 (14 × 6)`, `coherenceMaxScore = 36 (6 × 6)`으로 6문항 기준이었으나, 확정된 배점표는 5문항 기준이다.

| 축 | 판정 근거 | 문항당 |
|---|---|---|
| 정확도 | 핵심 개념 커버리지 + 보조 가산 + 잘못된 개념 감점 | 14 |
| 조리 - 구조성 | 결론 먼저 | 3 |
| 조리 - 명료성 | 군더더기 차감 | 3 |
| **문항당 합** | | **20** |
| **세션 총점** | 20점 × 5문항 | **100** |

따라서 `accuracyMaxScore = 70`, `coherenceMaxScore = 30`이고 `interview_answer.display_order`는 1~5다.

문항당 배점(14 / 3 / 3)은 최초 명세와 일치하며 갈린 것은 문항 수뿐이다. 엔티티는 만점을 상수로 박지 않고 `create()`가 `questionCount`로 계산하므로 문항 수가 다시 바뀌어도 컬럼과 마이그레이션은 손대지 않는다.

**5. `gradedAnswerCount` 증분에 `@Version`을 붙이지 않는다**

채점 5건이 병렬로 돌면 카운터 경합이 생긴다. 다만 이 프로젝트는 #498에서 `Learning`의 낙관적 락을 걷어냈고 현재 `@Version`을 가진 엔티티가 없다.
엔티티에는 `increaseGradedAnswerCount()`만 두고, 실제 증분을 원자적 UPDATE로 할지 락으로 할지는 채점 흐름을 구현하는 후속 이슈에서 정한다. 이번 이슈는 그 선택지를 좁히지 않는다.

## 영향 범위

### 신규 파일

**enum (`src/main/java/gravit/code/interview/domain/enums/`)**

- `InterviewMode.java` — `COMMON_CS`, `JOB_SPECIFIC`
- `InterviewAxis.java` — `COMMON`, `FRAMEWORK`, `LANGUAGE`
- `InterviewJobRole.java` — `BACKEND`, `FRONTEND`, `ANDROID`, `IOS`
- `InterviewDifficulty.java` — `HIGH`, `MEDIUM`, `LOW` (질문 하나의 난이도)
- `InterviewLevel.java` — `HIGH`, `MEDIUM`, `LOW` (세션 전체 난이도, 아래 "난이도와 레벨을 왜 나누는가" 참조)
- `InterviewConceptType.java` — `ESSENTIAL`, `SUPPLEMENTARY`
- `InterviewInputType.java` — `TEXT`, `VOICE`
- `InterviewSessionStatus.java` — `IN_PROGRESS`, `GRADING`, `COMPLETED`, `ABANDONED`
- `InterviewAnswerStatus.java` — `PENDING`, `ANSWERED`, `NO_RESPONSE`

**Entity (`src/main/java/gravit/code/interview/domain/`, 성격별 하위 패키지)**

`master/` — 사전 저장

- `InterviewCategory.java` — 채점 집계 단위
- `InterviewTechStack.java` — 온보딩 스택 선택지
- `InterviewStackAxis.java` — 스택의 축별 카테고리 매핑
- `InterviewQuestion.java` — 질문
- `InterviewQuestionConcept.java` — 질문별 핵심 개념

`session/` — 진행 상태

- `InterviewSession.java` — 면접 세션
- `InterviewAnswer.java` — 답변

`grading/` — 채점 결과

- `InterviewFeedback.java` — 답변 1건의 채점 결과 (1:1)
- `InterviewAnswerConceptResult.java` — 개념별 전달/누락 판정
- `InterviewAnswerWrongConcept.java` — 잘못 말한 개념과 교정

**기타**

- `src/main/resources/db/migration/V40__add_interview_tables.sql` — 테이블 10개, 제약, 인덱스
- `src/test/java/gravit/code/interview/domain/InterviewEntityMappingIntegrationTest.java` — 엔티티 매핑과 팩토리 검증
- `.claude/spec/service-policy/interview.md` — 신규 도메인 정책 파일

### 수정 파일

- `.claude/spec/service-policy/README.md` — 도메인별 파일 목록에 `interview.md` 한 줄 추가
- `.claude/rules/project-structure.md` — 디렉토리 트리에 `interview/` 추가
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — `// Interview` 그룹과 에러코드 2종 (리뷰 반영으로 추가)

`CustomErrorCode`는 애초에 손대지 않을 계획이었으나, PR 리뷰에서 값 조합 검증 부재가 지적되어 2종을 추가했다. 아래 "Entity 내부 검증" 참조.

## 구현 계획

### 1. enum

`domain/enums/` 하위에 9개 파일. 상수 나열만 하고 필드나 메서드를 두지 않는다 (`MissionStatus`와 동일한 형태).

```java
package gravit.code.interview.domain.enums;

public enum InterviewSessionStatus {
    IN_PROGRESS,
    GRADING,
    COMPLETED,
    ABANDONED
}
```

> **배치 주의**: 기존 도메인(`mission`)은 enum을 `domain/` 바로 아래 둔다. 이번엔 Entity가 10개라 같은 디렉토리에 20개 파일이 섞이는 걸 피하려 `domain/enums/`로 내린다. 사용자가 확정한 배치다.

### 2. Entity

공통 골격은 전부 동일하다.

```java
@Getter
@Entity
@Table(name = "interview_xxx")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewXxx extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ... 필드

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewXxx(...) { ... }

    public static InterviewXxx create(...) { ... }
}
```

- 10종 모두 `BaseEntity`를 상속한다. 마스터 5종은 정의가 바뀐 시점을, 세션과 채점 5종은 생성 시점을 남긴다.
- 클래스명과 테이블명이 스네이크 변환으로 일치하더라도 `@Table(name = ...)`을 명시한다 (`UserMission` 사례).
- 파라미터 2개 이상이면 줄바꿈한다.

#### 2.1 마스터 (사전 저장)

**`InterviewCategory`** — 채점 집계 단위

| 필드 | 타입 | 컬럼 |
|---|---|---|
| id | Long | `id` |
| mode | InterviewMode | `mode` NOT NULL |
| name | String | `name` NOT NULL |
| axis | InterviewAxis | `axis` NULL (COMMON_CS는 null) |

```java
public static InterviewCategory create(
        InterviewMode mode,
        String name,
        InterviewAxis axis
)
```

`create()`는 `validateModeAxis()`로 모드와 축의 조합을 검사한다. `COMMON_CS`인데 축이 있거나 `JOB_SPECIFIC`인데 축이 없으면 `INTERVIEW_CATEGORY_AXIS_INVALID`를 던진다.
`interview_stack_axis`가 (스택, 축) → 카테고리 매핑이라 `JOB_SPECIFIC` 카테고리는 반드시 어떤 축에 붙는다. 축 없는 직무별 카테고리는 매핑될 자리가 없다.
같은 규칙을 DB CHECK로도 걸자는 리뷰 의견이 있었으나 넣지 않았다. 아래 "CHECK 제약" 참조.

**`InterviewTechStack`** — 온보딩 스택 선택지

| 필드 | 타입 | 컬럼 |
|---|---|---|
| jobRole | InterviewJobRole | `job_role` NOT NULL |
| code | String | `code` NOT NULL UNIQUE (`SPRING_BOOT`, `NESTJS`) |
| displayName | String | `display_name` NOT NULL ("Java + Spring Boot") |
| sortOrder | int | `sort_order` NOT NULL |

```java
public static InterviewTechStack create(
        InterviewJobRole jobRole,
        String code,
        String displayName,
        int sortOrder
)
```

**`InterviewStackAxis`** — 스택의 축별 카테고리 매핑

| 필드 | 타입 | 컬럼 |
|---|---|---|
| techStackId | long | `tech_stack_id` NOT NULL |
| axis | InterviewAxis | `axis` NOT NULL |
| categoryId | long | `category_id` NOT NULL |

`(tech_stack_id, axis)`에 UNIQUE. 한 스택의 한 축이 두 카테고리를 가리키면 채점 집계가 갈라진다.

**`InterviewQuestion`**

| 필드 | 타입 | 컬럼 |
|---|---|---|
| categoryId | long | `category_id` NOT NULL |
| unitId | long | `unit_id` NOT NULL (약점 이동 목적지) |
| content | String | `content` TEXT NOT NULL |
| difficulty | InterviewDifficulty | `difficulty` NOT NULL |

**`InterviewQuestionConcept`**

| 필드 | 타입 | 컬럼 |
|---|---|---|
| questionId | long | `question_id` NOT NULL |
| name | String | `name` TEXT NOT NULL |
| type | InterviewConceptType | `type` NOT NULL |

#### 2.2 세션

**`InterviewSession`**

| 필드 | 타입 | 컬럼 |
|---|---|---|
| userId | long | `user_id` NOT NULL |
| mode | InterviewMode | `mode` NOT NULL |
| inputType | InterviewInputType | `input_type` NOT NULL |
| jobRole | InterviewJobRole | `job_role` NULL |
| techStackId | Long | `tech_stack_id` NULL |
| level | InterviewLevel | `level` NOT NULL |
| status | InterviewSessionStatus | `status` NOT NULL |
| accuracyScore | int | `accuracy_score` NOT NULL DEFAULT 0 |
| accuracyMaxScore | int | `accuracy_max_score` NOT NULL |
| coherenceScore | int | `coherence_score` NOT NULL DEFAULT 0 |
| coherenceMaxScore | int | `coherence_max_score` NOT NULL |
| gradedAnswerCount | int | `graded_answer_count` NOT NULL DEFAULT 0 |
| startedAt | LocalDateTime | `started_at` NOT NULL |
| endedAt | LocalDateTime | `ended_at` NULL |

- `jobRole`, `techStackId`는 `JOB_SPECIFIC`일 때만 채워지므로 래퍼 타입 `Long`과 nullable 컬럼을 쓴다. 나머지 ID는 `long`.
- 점수는 `int`로 두고 nullable로 만들지 않는다. "채점 전"은 `status`가 이미 구분하므로 null을 겹쳐 둘 이유가 없다.
- `accuracyMaxScore`, `coherenceMaxScore`는 세션 생성 시점에 문항 수로 계산해 채운다. 정책이 바뀌어도 과거 세션의 만점이 보존된다.

상수와 팩토리:

```java
private static final int ACCURACY_SCORE_PER_QUESTION = 14;
private static final int COHERENCE_SCORE_PER_QUESTION = 6;

public static InterviewSession create(
        long userId,
        InterviewMode mode,
        InterviewInputType inputType,
        InterviewJobRole jobRole,
        Long techStackId,
        InterviewLevel level,
        int questionCount
)
```

`create()`가 `status = IN_PROGRESS`, `startedAt = LocalDateTime.now(TimeZoneConst.KST)`,
`accuracyMaxScore = ACCURACY_SCORE_PER_QUESTION * questionCount`,
`coherenceMaxScore = COHERENCE_SCORE_PER_QUESTION * questionCount`,
나머지 카운터를 0으로 세팅한다. 문항 5개면 70점과 30점, 합 100점이 된다.

`COHERENCE_SCORE_PER_QUESTION = 6`은 구조성 3점과 명료성 3점의 합이다. 두 축의 개별 상한(각 3점)은 엔티티에 두지 않는다. `structureScore`와 `clarityScore`가 각각 별도 컬럼이라 합계 상수와 개별 상한이 세 곳에 흩어지고, 배점이 바뀔 때 어긋날 여지가 생긴다. 개별 상한은 채점 프롬프트와 채점 코드가 지키고, 정책 파일에 값을 남긴다.

상태 전이 메서드:

```java
public void startGrading()                       // IN_PROGRESS → GRADING
public void complete(int accuracyScore,
                     int coherenceScore)         // GRADING → COMPLETED, endedAt 기록
public void abandon()                            // IN_PROGRESS → ABANDONED, endedAt 기록
public void increaseGradedAnswerCount()
public boolean isAllGraded(int questionCount)    // gradedAnswerCount >= questionCount
```

**이번 이슈의 전이 메서드는 진입 상태를 검사하지 않고 전이만 수행한다.** 검사하려면 위반 시 던질 에러코드가 필요한데, 그 이름과 HTTP 상태는 서비스 흐름이 정해져야 잡힌다 (아래 "Entity 내부 검증" 참조).

다만 `complete()`의 점수 범위는 예외로 검사한다. 리뷰 반영으로 `validateScoreInRange()`가 두 점수 모두에 `0 <= score <= maxScore`를 적용하고, 벗어나면 `INTERVIEW_SESSION_SCORE_INVALID`를 던진다.
상태 전이 검증과 달리 이 규칙은 서비스 흐름이 정해지기를 기다릴 필요가 없다. 만점이 이미 엔티티 안에 있고, 점수가 만점을 넘으면 완료 세션의 점수 표시와 과거 점수 보존이 깨진다는 것도 지금 확정된 사실이다.
DB CHECK가 아니라 엔티티에 둔 이유는 아래 "CHECK 제약" 참조.

**`InterviewAnswer`**

| 필드 | 타입 | 컬럼 |
|---|---|---|
| sessionId | long | `session_id` NOT NULL |
| questionId | long | `question_id` NOT NULL |
| displayOrder | int | `display_order` NOT NULL |
| status | InterviewAnswerStatus | `status` NOT NULL |
| content | String | `content` TEXT NULL |
| audioUrl | String | `audio_url` TEXT NULL |
| answeredAt | LocalDateTime | `answered_at` NULL |

```java
public static InterviewAnswer createPending(
        long sessionId,
        long questionId,
        int displayOrder
)

public void submit(
        String content,
        String audioUrl
)
```

`submit()`은 `content`를 trim해 빈 문자열이면 `NO_RESPONSE`, 아니면 `ANSWERED`로 잡고 `answeredAt`을 채운다.
`content`가 null이거나 공백뿐인 경우가 같은 경로를 타므로 VOICE의 STT 결과가 비었을 때도 자동으로 `NO_RESPONSE`가 된다.
inputType별 필수 검증(VOICE에 audioFile 필수 등)은 서비스 책임이라 엔티티에 넣지 않는다.

`audioUrl`만 있고 `content`가 비면 `ANSWERED`로 잡아야 한다는 리뷰 의견이 있었으나 반려했다.
정상적인 음성 답변은 `submit(STT_변환결과, audioUrl)`이고, `content`가 빈 채로 `audioUrl`만 오는 것은 STT가 실패했거나 무음인 경우다.
정책(`interview.md`)이 "음성 입력의 변환 결과가 비어 있는 경우도" 무응답과 같이 0점 처리하라고 규정하고, 채점은 전부 텍스트 기반(개념 커버리지, 근거 구간 인용, 오개념 교정)이라 `content` 없이는 채점할 대상이 없다.
`audioUrl`은 판정과 무관하게 그대로 저장되므로 음성 파일이 유실되지도 않는다.

`(session_id, display_order)`에 UNIQUE. 같은 순번이 두 번 생기면 화면 순서가 깨진다.

#### 2.3 채점 결과

**`InterviewFeedback`** — 답변과 1:1

| 필드 | 타입 | 컬럼 |
|---|---|---|
| answerId | long | `answer_id` NOT NULL UNIQUE |
| accuracyScore | int | `accuracy_score` NOT NULL |
| structureScore | int | `structure_score` NOT NULL |
| clarityScore | int | `clarity_score` NOT NULL |
| irrelevantStatementCount | int | `irrelevant_statement_count` NOT NULL |
| accuracyMultiplier | BigDecimal | `accuracy_multiplier` NUMERIC(2,1) NOT NULL |
| improvementSuggestion | String | `improvement_suggestion` TEXT NULL |

```java
public static InterviewFeedback create(
        long answerId,
        int accuracyScore,
        int structureScore,
        int clarityScore,
        int irrelevantStatementCount,
        BigDecimal accuracyMultiplier,
        String improvementSuggestion
)

public static InterviewFeedback createNoResponse(long answerId)
```

`createNoResponse()`는 점수 3종과 `irrelevantStatementCount`를 0, `accuracyMultiplier`를 `BigDecimal.ONE`, `improvementSuggestion`을 null로 채운다.
무응답 답변은 LLM을 호출하지 않고 코드가 0점을 직접 기록하는 경로이므로, 그 규칙이 호출부마다 흩어지지 않게 팩토리로 고정한다.

`accuracyMultiplier`가 `BigDecimal`인 것은 명세를 따른 것이다. 1.0 / 0.5 / 0.2 세 값만 쓰므로 `NUMERIC(2,1)`이면 충분하다.

**`InterviewAnswerConceptResult`**

| 필드 | 타입 | 컬럼 |
|---|---|---|
| answerId | long | `answer_id` NOT NULL |
| conceptId | long | `concept_id` NOT NULL |
| covered | boolean | `covered` NOT NULL |
| quote | String | `quote` TEXT NULL |
| missingFeedbackText | String | `missing_feedback_text` TEXT NULL |

```java
public static InterviewAnswerConceptResult covered(
        long answerId,
        long conceptId,
        String quote
)

public static InterviewAnswerConceptResult missing(
        long answerId,
        long conceptId,
        String missingFeedbackText
)
```

`covered`가 true면 `quote`만, false면 `missingFeedbackText`만 의미가 있다. 필드 조합을 호출부가 직접 정하게 두면 잘못된 조합이 저장되므로 팩토리를 둘로 나눈다.
무응답 답변은 전체 개념을 `missing(answerId, conceptId, null)`로 적재한다.

`(answer_id, concept_id)`에 UNIQUE.

**`InterviewAnswerWrongConcept`**

| 필드 | 타입 | 컬럼 |
|---|---|---|
| answerId | long | `answer_id` NOT NULL |
| quotedText | String | `quoted_text` TEXT NOT NULL |
| correctionText | String | `correction_text` TEXT NOT NULL |

```java
public static InterviewAnswerWrongConcept create(
        long answerId,
        String quotedText,
        String correctionText
)
```

무응답 답변에는 생성하지 않는다.

#### 2.4 Entity 내부 검증

`domain.md`는 검증 로직을 Entity의 private 메서드로 두라고 하고, `common.md`는 `RestApiException(CustomErrorCode.XXX)`을 쓰라고 한다.

애초 계획은 **에러코드를 하나도 추가하지 않고 검증도 넣지 않는 것**이었다. 근거는 검증이 필요한 항목들이 모두 서비스 흐름에 달려 있다는 것이었다.

- `InterviewSession`의 상태 전이 - 진입 상태가 아닌데 전이하면 실패해야 한다
- `InterviewSession.create()`의 모드별 필수값 - `JOB_SPECIFIC`인데 `jobRole`이나 `techStackId`가 null이면 실패해야 한다

이 둘은 여전히 후속 이슈의 몫이다. 코드 이름과 HTTP 상태가 이 값이 어느 API에서 어떻게 드러나는지에 달려 있고,
`INTERVIEW_INPUT_TYPE_MISMATCH(400)`처럼 이슈 명세에 이미 나온 코드도 답변 제출 API의 것이라 이번 범위 밖이다.
반쯤 맞는 이름의 에러코드를 지금 박아두면 후속 이슈에서 지우고 다시 만들게 된다.

**PR 리뷰를 반영해 다음 두 검증과 에러코드는 이번 이슈에 넣었다.** 위 둘과 달리, 지켜야 할 규칙이 서비스 흐름과 무관하게 엔티티 안에서 이미 확정되어 있는 항목이다.

| 검증 | 위치 | 에러코드 |
|---|---|---|
| 모드와 축의 조합 | `InterviewCategory.validateModeAxis()` | `INTERVIEW_CATEGORY_AXIS_INVALID` (400) |
| 세션 점수의 범위 | `InterviewSession.validateScoreInRange()` | `INTERVIEW_SESSION_SCORE_INVALID` (400) |

두 규칙 모두 판단에 필요한 값이 엔티티 안에 전부 있다. 축 조합은 `mode`와 `axis`만 보면 되고, 점수 범위는 생성 시점에 계산해 둔 만점과 비교하면 된다.
`CustomErrorCode`에는 `// CS-NOTE` 뒤, `// Global` 앞에 `// Interview` 그룹을 만들어 두 코드를 넣는다.

### 3. Flyway

**`V40__add_interview_tables.sql` 신규 작성** (현재 최신 V39)

작성 규칙:
- 최상단에 파일명 주석
- 각 `CREATE TABLE` 앞에 목적 주석
- PK는 `BIGINT GENERATED BY DEFAULT AS IDENTITY`
- enum은 `VARCHAR(255)` + `CHECK`
- `TIMESTAMP(6)`, `created_at`/`updated_at` 포함 (전 테이블이 `BaseEntity` 상속)
- 인덱스는 `CREATE INDEX IF NOT EXISTS ix_{테이블}_{용도}`

테이블 생성 순서는 참조 방향을 따라 category → tech_stack → stack_axis → question → question_concept → session → answer → feedback → concept_result → wrong_concept.

예시 (한 개만, 나머지도 같은 형태):

```sql
-- V40__add_interview_tables.sql

-- 1) 채점 집계 단위. 공통 CS는 axis가 없고, 직무별은 축(공통/프레임워크/언어)을 가진다
CREATE TABLE interview_category
(
    id         BIGINT       GENERATED BY DEFAULT AS IDENTITY,
    mode       VARCHAR(255) NOT NULL CHECK (mode IN ('COMMON_CS', 'JOB_SPECIFIC')),
    name       VARCHAR(255) NOT NULL,
    axis       VARCHAR(255) CHECK (axis IN ('COMMON', 'FRAMEWORK', 'LANGUAGE')),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_interview_category_mode_name UNIQUE (mode, name)
);
```

UNIQUE 제약 목록:

| 제약명 | 대상 | 이유 |
|---|---|---|
| `uq_interview_category_mode_name` | `(mode, name)` | 같은 모드에 동명 카테고리가 둘이면 집계가 갈라진다 |
| `uq_interview_tech_stack_code` | `(code)` | 온보딩 선택지 식별자 |
| `uq_interview_stack_axis_stack_axis` | `(tech_stack_id, axis)` | 스택의 한 축은 카테고리 하나 |
| `uq_interview_answer_session_order` | `(session_id, display_order)` | 순번 중복 방지 |
| `uq_interview_feedback_answer` | `(answer_id)` | 답변과 1:1 |
| `uq_interview_answer_concept_result` | `(answer_id, concept_id)` | 개념당 판정 1건 |

CHECK 제약:

- `interview_session.accuracy_score >= 0`, `coherence_score >= 0`, `graded_answer_count >= 0`
- `interview_feedback` 점수 3종 `>= 0`, `irrelevant_statement_count >= 0`
- `interview_tech_stack.sort_order >= 0`
- `interview_answer.display_order > 0`

상한(예: `accuracy_score <= 14`)은 걸지 않는다. 점수 배분이 바뀔 때마다 마이그레이션을 새로 쳐야 하고, 상한은 채점 코드가 지킬 규칙이다.

**여러 컬럼을 함께 보는 CHECK도 걸지 않는다.** 리뷰에서 다음 둘이 제안됐다.

- `interview_category` - `COMMON_CS`면 `axis IS NULL`, `JOB_SPECIFIC`이면 `axis IS NOT NULL`
- `interview_session` - `accuracy_score <= accuracy_max_score`, `coherence_score <= coherence_max_score`

둘 다 규칙 자체는 맞고, 같은 행의 컬럼끼리 비교하는 형태라 위의 "배점이 바뀌면 마이그레이션을 새로 쳐야 한다"는 근거는 적용되지 않는다. 그래도 넣지 않은 이유는 셋이다.

1. 기존 마이그레이션 39개에 여러 컬럼을 함께 보는 CHECK가 하나도 없다. CHECK는 enum 값 열거와 단일 컬럼 범위 검사에만 쓰고 있다
2. 위반 시 터지는 것이 flush 시점의 `DataIntegrityViolationException`이라 어느 로직이 잘못했는지 드러나지 않는다. 특히 점수는 AI 채점을 5문항 다 돌린 뒤 트랜잭션 전체가 롤백된다. 엔티티에서 막으면 잘못 만든 지점에서 에러코드와 함께 즉시 실패한다
3. 축 조합은 마스터 데이터 내용이 아직 확정되지 않았다. 지금 스키마로 굳히면 축 없는 직무별 카테고리가 필요해질 때 제약 해제 마이그레이션이 한 번 더 필요하다

대신 두 규칙 모두 엔티티 검증으로 넣었다. 위 "Entity 내부 검증" 참조.
`interview_session`의 `mode`와 `job_role`, `tech_stack_id` 조합도 같은 성격의 규칙인데, 이쪽은 검증 자체가 후속 이슈로 밀려 있어 DB와 엔티티 어느 쪽에도 두지 않았다.

인덱스:

| 인덱스 | 대상 | 용도 |
|---|---|---|
| `ix_interview_question_category_difficulty` | `interview_question (category_id, difficulty)` | 세션 생성 시 조건에 맞는 문제 풀 선별 |
| `ix_interview_question_concept_question` | `interview_question_concept (question_id)` | 채점 시 질문의 개념 목록 조회 |
| `ix_interview_tech_stack_job_role` | `interview_tech_stack (job_role, sort_order)` | 온보딩 선택지 노출 |
| `ix_interview_stack_axis_stack` | `interview_stack_axis (tech_stack_id)` | 스택 → 카테고리 3종 조회 |
| `ix_interview_session_user_started` | `interview_session (user_id, started_at DESC)` | 사용자 세션 이력 |
| `ix_interview_answer_session` | `interview_answer (session_id)` | 세션 상세 조회 |
| `ix_interview_answer_concept_result_answer` | `interview_answer_concept_result (answer_id)` | 답변별 개념 판정 조회 |
| `ix_interview_answer_wrong_concept_answer` | `interview_answer_wrong_concept (answer_id)` | 답변별 오개념 조회 |

`uq_interview_feedback_answer`, `uq_interview_answer_session_order`, `uq_interview_answer_concept_result`는 UNIQUE가 인덱스를 겸하므로 별도로 만들지 않는다.

FK 제약은 걸지 않는다. `V31`의 `user_mission`이 `user_id`, `mission_id` 모두 FK 없이 plain 컬럼으로 간 것과 같은 방식이고, plain ID 매핑과 일관된다. (아래 "결정 필요" 참조)

### 4. Repository

이번 범위 밖이다. 조회 메서드는 사용처가 정해진 뒤 붙인다.

### 5. Service / Facade / DTO / Controller

전부 이번 범위 밖이다. 후속 이슈에서 다룬다.

### 6. 정책 문서

**`.claude/spec/service-policy/interview.md` 신규 작성**

담을 것 (`README.md`의 작성 규칙에 따라 클래스 구조나 경로는 쓰지 않는다):

- 면접 모드 두 가지와 각 모드에서 요구하는 선택값
- 질문 난이도(질문 하나의 속성)와 세션 레벨(세션 전체 속성)이 별개 축이라는 것. 세션 레벨이 질문을 고르는 규칙은 아직 미정이므로 `- 미정`으로 남긴다 (README 작성 규칙: 정책이 없어도 항목은 남긴다)
- 세션 상태 흐름: `IN_PROGRESS → GRADING → COMPLETED`, 실패 시 `IN_PROGRESS → ABANDONED`
- 문항 수 5개, 배점 (정확도 14점 = 핵심 개념 커버리지 + 보조 가산 + 잘못된 개념 감점, 구조성 3점 = 결론 먼저, 명료성 3점 = 군더더기 차감. 문항당 20점, 세션 총점 100점)
- 무응답 답변 판정: 답변이 비었으면 AI를 거치지 않고 0점, 전체 개념을 누락으로 기록하고 잘못된 개념은 남기지 않는다
- 핵심 개념은 개념명과 필수/보조 구분만 저장하고, 인정 기준과 누락 안내 문구, 모범답안은 저장하지 않는다
- **개념명은 판정 가능한 문장으로 작성한다** - 채점 프롬프트가 개념명만 받아 판정하므로 개념명의 서술 수준이 채점 품질을 결정한다
- 채점 중(`GRADING`)에는 세션 조회에 점수를 내보내지 않는다

**`.claude/spec/service-policy/README.md` 수정** - 표에 한 줄 추가

```
| `interview.md` | AI 면접 모드, 세션 상태, 채점 배점과 무응답 처리 |
```

**`.claude/rules/project-structure.md` 수정** - 트리에 `interview/` 한 줄 추가 (`csnote/` 아래 학습 계열 블록)

## 결정 필요 (Decisions needed)

- [x] **질문 난이도와 세션 레벨을 한 enum으로 합칠지** - **분리한다.** `InterviewDifficulty`(질문)와 `InterviewLevel`(세션)을 각각 둔다. 세션 레벨의 질문 선별 규칙이 아직 정해지지 않았고, 구성 프로파일 방식으로 갈 가능성이 높아 두 값이 같은 척도가 아니게 될 수 있다. 근거는 "배경 - 난이도와 레벨을 왜 나누는가" 참조
- [x] **조리 점수 6점을 structure와 clarity가 어떻게 나눠 갖는지** - **구조성 3점 + 명료성 3점.** 이와 함께 문항 수와 총점이 확정됐다 (5문항, 문항당 20점, 세션 100점). 최초 명세의 6문항 84/36과 충돌하며 배점표를 최신으로 채택했다. 근거는 "배경 - 문항 수는 5개, 세션 총점은 100점" 참조
- [x] **마스터 데이터 시딩을 V40에 함께 넣을지** - **테이블만 생성한다.** 카테고리, 기술 스택, 질문, 개념 시딩은 별도 마이그레이션으로 분리한다. 적용된 마이그레이션은 수정할 수 없어, 확정되지 않은 데이터를 넣으면 바뀔 때마다 새 버전을 쳐야 한다
- [x] **FK 제약을 걸지** - **걸지 않는다.** V31 `user_mission`이 `user_id`, `mission_id` 모두 FK 없이 plain 컬럼으로 간 선례를 따르고, plain ID + 수동 JPQL 조인 방식과 일관된다

## 후속 이슈로 넘기는 미결정 사항

이번 이슈의 구현에는 지장이 없으나 후속 작업 전까지 확정이 필요한 것들이다. 정책 파일에는 `- 미정`으로 남긴다.

- **세션 레벨의 질문 선별 규칙** - 일치 필터(HIGH 세션은 `difficulty = HIGH`인 질문만) 대 구성 프로파일(HIGH 세션은 상 3 + 중 2처럼 난이도 혼합). 세션 생성 서비스 이슈에서 정한다. 이 결정이 `InterviewDifficulty`와 `InterviewLevel`을 나중에 합칠지도 함께 결정한다
- **`gradedAnswerCount` 증분의 동시성 처리** - 원자적 UPDATE 대 비관적 락. 비동기 채점 흐름 이슈에서 정한다
- **`InterviewSession` 상태 전이 검증과 에러코드** - `CustomErrorCode`에 어떤 코드를 어떤 HTTP 상태로 추가할지. 세션 서비스 이슈에서 정한다. 리뷰 반영으로 축 조합과 점수 범위 검증은 이번에 들어갔지만, 상태 전이와 모드별 필수값(`JOB_SPECIFIC`의 `jobRole`, `techStackId`)은 그대로 남아 있다 (위 "Entity 내부 검증" 참조)
- **마스터 데이터 시딩 내용** - 카테고리 목록, 기술 스택 목록, 질문 풀과 개념명. 별도 마이그레이션 이슈에서 정한다

## 검증

이번 이슈의 산출물은 Entity와 스키마뿐이라 서비스 로직 테스트가 성립하지 않는다. 팩토리와 상태 전이, 그리고 리뷰 반영으로 들어간 값 조합 검증까지가 테스트 대상이다. 확인 경로는 셋이다.

**1. `./gradlew build`** - `flyway validate`가 포함되어 V40의 문법과 체크섬 정합을 확인한다.

**2. 매핑 검증 테스트** - `src/test/java/gravit/code/interview/domain/InterviewEntityMappingTest.java` 신규 작성

`application-test.yml`이 `ddl-auto: create` + `flyway.enabled: false`라 **테스트 스키마는 V40이 아니라 엔티티에서 생성된다.** 따라서 이 테스트는 마이그레이션을 검증하지 못하고, 엔티티 매핑 자체만 확인한다.

| 시나리오 | 검증 |
|---|---|
| `공통_CS_카테고리는_축_없이_만들어진다()` | `create(COMMON_CS, "네트워크", null)` → `axis == null` |
| `직무별_카테고리는_축과_함께_만들어진다()` | `create(JOB_SPECIFIC, "Spring", FRAMEWORK)` → `axis = FRAMEWORK` |
| `공통_CS_카테고리에_축을_주면_예외가_발생한다()` | `create(COMMON_CS, "네트워크", COMMON)` → `INTERVIEW_CATEGORY_AXIS_INVALID` |
| `직무별_카테고리에_축이_없으면_예외가_발생한다()` | `create(JOB_SPECIFIC, "Spring", null)` → `INTERVIEW_CATEGORY_AXIS_INVALID` |
| `세션을_생성하면_진행중_상태와_만점이_채워진다()` | `create(..., questionCount = 5)` → `status = IN_PROGRESS`, `accuracyMaxScore = 70`, `coherenceMaxScore = 30`, `gradedAnswerCount = 0`, `startedAt != null` |
| `만점_이하의_점수는_그대로_기록된다()` | `complete(70, 30)` → `status = COMPLETED`, 점수 2종 그대로, `endedAt != null` |
| `만점을_넘는_점수는_예외가_발생한다()` | `complete(71, 30)` → `INTERVIEW_SESSION_SCORE_INVALID` |
| `음수_점수는_예외가_발생한다()` | `complete(70, -1)` → `INTERVIEW_SESSION_SCORE_INVALID` |
| `답변이_비어있으면_무응답으로_기록된다()` | `submit("   ", null)` → `status = NO_RESPONSE` |
| `답변에_내용이_있으면_응답으로_기록된다()` | `submit("본문", null)` → `status = ANSWERED`, `answeredAt != null` |
| `음성_답변의_변환_결과가_비어있으면_음성_파일을_남기고_무응답으로_기록된다()` | `submit(null, audioUrl)` → `status = NO_RESPONSE`, `audioUrl`은 그대로 저장 |
| `음성_답변의_변환_결과가_있으면_응답으로_기록된다()` | `submit("본문", audioUrl)` → `status = ANSWERED`, `audioUrl`은 그대로 저장 |
| `무응답_피드백은_모든_점수가_0이다()` | `createNoResponse(answerId)` → 점수 3종 0, `accuracyMultiplier = 1.0` |
| `개념_판정은_전달과_누락이_서로_다른_필드를_채운다()` | `covered(...)` → `quote != null` 이고 `missingFeedbackText == null`, `missing(...)`은 반대 |
| `엔티티_10종이_저장되고_조회된다()` | 각 Entity를 `TestEntityManager`로 저장 후 재조회. 컬럼 매핑과 enum 매핑 확인 |

작성 시 유의:

- `accuracyMultiplier` 비교에는 `isEqualByComparingTo`를 쓴다. `createNoResponse()`가 넣는 `BigDecimal.ONE`은 scale이 0이고 `NUMERIC(2,1)` 컬럼에서 읽으면 scale이 1이라, `isEqualTo`는 값이 같아도 실패한다.
- 상태 전이 메서드는 진입 상태를 검사하지 않으므로 "잘못된 전이가 막힌다"류 시나리오를 쓰지 않는다. 그 검증은 에러코드가 생기는 후속 이슈의 몫이다. `complete()`의 점수 범위는 검사하므로 예외다.
- 예외 케이스는 `test-convention.md`에 따라 타입만이 아니라 `errorCode`까지 검증하고, `CustomErrorCode`는 static import로 쓴다.
- 음성 답변 2건은 "`audioUrl`만으로는 `ANSWERED`가 되지 않는다"가 의도된 동작임을 코드로 못 박는 목적이다. 리뷰에서 이 지점이 버그로 오인됐다.

**3. V40 자체 검증은 로컬 기동으로 한다** - Docker Compose로 PostgreSQL을 띄우고 `./gradlew bootRun`으로 V40을 실제 적용해, 테이블 10개와 제약, 인덱스가 생성되는지 확인한다. 이슈 체크리스트의 "로컬 기동으로 스키마와 Entity 매핑 검증" 항목이 이것이다.

전체 실행: `./gradlew build` → `./gradlew test`

## Deviation Log

- `src/main/java/gravit/code/interview/domain/{master,session,grading}/`: 계획서가 지정한 `domain/` 평면 배치 대신 성격별 하위 패키지로 나눴다 — 이유: 구현 후 실측하니 `interview/domain/`이 19개 파일로 2위 `admin`(9개)의 두 배가 됐다. `admin`이 domain 9개에서 전체 94개로 늘어난 비율을 보면, Repository와 Service가 붙는 후속 이슈에서 한 패키지에 100개 안팎이 쌓인다. `admin/domain/staging`, `admin/domain/audit` 선례를 따라 나눴고, 아직 참조하는 코드가 없어 파일 이동과 `package` 선언 변경만으로 끝났다. 엔티티를 합쳐 개수를 줄이는 방향은 검토 후 기각했다 (`InterviewFeedback`을 `InterviewAnswer`에 흡수하면 채점 전후가 구분되지 않고, `InterviewAnswerWrongConcept`을 `InterviewAnswerConceptResult`에 흡수하면 `conceptId`가 nullable이 되고 `covered`가 3값이 된다)
- `src/main/resources/db/migration/V40__add_interview_tables.sql`: 계획서가 지정한 `V32`가 아니라 `V40`으로 만들었다 — 이유: 계획 수립 시 최신 마이그레이션 번호를 이전 브랜치(`refactor/467-oauth-env-boundary`)에서 확인해 V31로 오인했다. `origin/dev`에는 V39까지 있고 `V32__add_problem_submission_user_index.sql`이 이미 존재해 `flywayMigrate`가 "Found more than one migration with version 32"로 실패했다. 다음 빈 번호인 V40으로 바꿔 `flywayValidate`를 통과시켰다
- `InterviewCategory`, `InterviewSession`, `CustomErrorCode`: 계획서가 "이번 이슈에서는 에러코드를 추가하지 않고 검증도 넣지 않는다"고 못 박았으나, PR 리뷰를 반영해 검증 2종과 에러코드 2종을 넣었다 — 이유: 계획의 근거는 "검증에 필요한 판단 기준이 서비스 흐름에 달려 있다"였는데, 축 조합(`mode`와 `axis`)과 점수 범위(생성 시점에 계산해 둔 만점)는 판단에 필요한 값이 엔티티 안에 이미 전부 있어 그 근거가 적용되지 않는다. 리뷰는 두 건 모두 DB CHECK로 해결하자고 제안했으나 엔티티 검증으로 대신했다 (근거는 "CHECK 제약" 절). 상태 전이와 모드별 필수값 검증은 계획대로 후속 이슈에 남겼다
- `InterviewAnswer`: 리뷰에서 "`audioUrl`만 있어도 `ANSWERED`로 잡아야 한다"는 수정 요청이 있었으나 로직을 바꾸지 않고 테스트 2건만 추가했다 — 이유: 정책 `interview.md`가 음성 변환 결과가 빈 경우를 무응답과 같이 0점 처리하도록 규정하고, 채점이 전부 텍스트 기반이라 `content` 없이는 채점 대상이 없다. 제안대로 고치면 무음 녹음이 `ANSWERED`로 남아 "무응답은 전체 개념을 누락으로 기록한다"는 채점 경로를 타지 못한다. 대신 이 동작이 의도된 것임을 테스트로 명시했다
- `src/test/java/gravit/code/interview/domain/InterviewEntityMappingIntegrationTest.java`: 계획서가 지정한 파일명 `InterviewEntityMappingTest.java`와 `TestEntityManager` 대신 `InterviewEntityMappingIntegrationTest.java` + `@TCSpringBootTest` + `EntityManager` 직접 주입으로 작성했다 — 이유: `TestEntityManager`를 쓰려면 `@DataJpaTest` 인프라가 필요한데 이 프로젝트의 `TCRepositoryTest`가 파일 전체 주석 처리되어 죽어 있다. 또 `test-convention.md`가 "모든 테스트는 통합 테스트(`@TCSpringBootTest`)"와 파일명 `{Class}IntegrationTest`를 규정한다. 검증 시나리오 6개는 계획서 그대로 유지했고, 트랜잭션이 필요한 저장/조회 구간은 `TransactionTemplate`으로 감쌌다 (테스트 클래스에 `@Transactional`을 붙이지 않는 기존 통합 테스트 방식)
