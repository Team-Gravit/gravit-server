# [PLAN-587] 약점 분야 항목이 구분되지 않는 문제 수정

> 이슈: #587
> 브랜치: fix/587-weak-topic-unit-title

## 목표
세션 리포트의 약점 분야는 유닛 단위로 중복을 제거하지만 응답에 유닛 이름이 없어, 같은 주제의 서로 다른 유닛이 약점이면 클라이언트에는 같은 주제명만 반복된다(알고리즘 5문항 모두 약점 → "알고리즘" 5개).
유닛 단위 판정과 중복 제거 기준(unitId)은 그대로 두고, 약점 분야 항목에 유닛 제목(`Unit.title`)을 추가해 항목을 구분할 수 있게 한다. 미결 과제 P9(유닛 표시명)를 "유닛 제목을 가공하지 않고 그대로 쓴다"로 확정한다.

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/java/gravit/code/interviewFeedback/repository/InterviewFeedbackRepository.java` - `findAnswerScoresBySessionId`에 `Unit` LEFT JOIN, `u.title` 프로젝션 추가
- `src/main/java/gravit/code/interviewFeedback/dto/internal/InterviewAnswerScoreDto.java` - `String unitTitle` 컴포넌트 추가
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewWeakTopicResponse.java` - `String unitTitle` 필드와 `@Schema` 추가, `of` 시그니처 변경
- `src/main/java/gravit/code/interviewFeedback/dto/response/InterviewSessionSummaryResponse.java` - `weakTopics` `@Schema` description에 유닛 제목 포함
- `src/main/java/gravit/code/interviewFeedback/service/InterviewFeedbackQueryService.java` - `toWeakTopics`가 유닛 제목을 함께 담도록 수집 대상 변경
- `src/main/java/gravit/code/interviewFeedback/controller/docs/InterviewFeedbackControllerDocs.java` - 세션 종합 조회 description과 성공 예시의 `weakTopics` 갱신
- `src/test/java/gravit/code/interviewFeedback/service/InterviewFeedbackQueryServiceIntegrationTest.java` - 유닛 실데이터 저장, 유닛 제목 검증, 같은 주제 다른 유닛 시나리오 추가
- `.claude/spec/service-policy/interview.md` - 정책 변경: 약점 분야에 유닛 제목 노출, P9 확정

## 구현 계획

### 1. Entity / Flyway
- 변경 없음. `interview_question.unit_id`(NOT NULL)와 `unit.title`(NOT NULL)을 그대로 읽는다

### 2. Repository - `InterviewFeedbackRepository`

`findAnswerScoresBySessionId(long sessionId)` 시그니처는 그대로 두고 쿼리만 바꾼다.

```java
    @Query("""
            SELECT new gravit.code.interviewFeedback.dto.internal.InterviewAnswerScoreDto(
                a.displayOrder, q.topic, q.unitId, u.title, f.accuracyScore, f.structureScore, f.clarityScore
            )
            FROM InterviewFeedback f
            JOIN InterviewAnswer a ON a.id = f.answerId
            JOIN InterviewQuestion q ON q.id = a.questionId
            LEFT JOIN Unit u ON u.id = q.unitId
            WHERE a.sessionId = :sessionId
            ORDER BY a.displayOrder ASC
    """)
    List<InterviewAnswerScoreDto> findAnswerScoresBySessionId(@Param("sessionId") long sessionId);
```

- 별도 쿼리(`UnitRepository.findAllById`)를 두지 않고 기존 점수 쿼리에 붙인다. 세션 종합 조회의 쿼리 수가 늘지 않고, 엔티티 조인 방식은 `LessonRepository`의 `JOIN Unit u ON ...`과 같다
- INNER가 아니라 LEFT JOIN인 이유: `interview_question.unit_id`에는 FK가 없다. INNER JOIN이면 유닛 행이 없을 때 `answers`(문항별 점수)에서 그 문항이 통째로 빠진다. LEFT JOIN이면 문항별 점수는 항상 5개를 유지하고 유닛 제목만 비어 나온다
- `findAnswerDetailsBySessionId`, `findTopicAccuracyByUserIdAndStatus`는 바꾸지 않는다

### 3. Service - `InterviewFeedbackQueryService`

`getSessionSummary`는 바꾸지 않는다. `toWeakTopics`만 바꾼다.

```java
    private List<InterviewWeakTopicResponse> toWeakTopics(
            List<InterviewAnswerScoreDto> scores,
            InterviewSession session
    ) {
        Map<Long, InterviewAnswerScoreDto> unitIdToWeakScore = scores.stream()
                .filter(score -> session.isWeakAnswer(score.earnedScore()))
                .collect(Collectors.toMap(
                        InterviewAnswerScoreDto::unitId,
                        Function.identity(),
                        (first, second) -> first,
                        LinkedHashMap::new
                ));

        return unitIdToWeakScore.values().stream()
                .map(InterviewWeakTopicResponse::from)
                .toList();
    }
```

- 중복 제거 키(unitId), 먼저 나온 문항 우선, 문항 순서 유지(`LinkedHashMap`)는 현행 그대로다
- Map 값이 주제 하나에서 유닛 제목까지로 늘어나 `unitIdToTopic` 대신 행 DTO 전체를 담는다. 변수명은 `{키}To{값}` 규칙에 따라 `unitIdToWeakScore`
- import: `java.util.function.Function` 추가, 쓰지 않게 되는 `InterviewTopic` import는 `toHistoryResponses`에서 계속 쓰므로 유지

### 4. Facade
- 불필요 - 단일 Service. 유닛 제목은 Repository 조인으로 가져오며 unit 도메인 Service를 호출하지 않는다

### 5. DTO

**`InterviewAnswerScoreDto`** (JPQL 생성자 표현식 대상, 표준 생성자 유지)

```java
public record InterviewAnswerScoreDto(
        int displayOrder,

        InterviewTopic topic,

        long unitId,

        String unitTitle,

        int accuracyScore,

        int structureScore,

        int clarityScore
) {
    public int earnedScore() { ... }
}
```

- 생성자 인자 순서가 JPQL `SELECT new` 순서와 맞아야 한다(`q.unitId, u.title` 순)
- `InterviewAnswerScoreResponse.from`은 `unitTitle`을 쓰지 않으므로 변경 없음

**`InterviewWeakTopicResponse`**

```java
@Builder(access = AccessLevel.PRIVATE)
public record InterviewWeakTopicResponse(

        @Schema(
                description = "학습 이동 대상 유닛 ID",
                example = "7",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long unitId,

        @Schema(
                description = "학습 이동 대상 유닛 제목",
                example = "정렬",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String unitTitle,

        @Schema(
                description = "약점 문항의 주제",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewTopicResponse topic
) {
    public static InterviewWeakTopicResponse from(InterviewAnswerScoreDto score) {
        return InterviewWeakTopicResponse.builder()
                .unitId(score.unitId())
                .unitTitle(score.unitTitle())
                .topic(InterviewTopicResponse.from(score.topic()))
                .build();
    }
}
```

- 팩토리를 `of(long unitId, InterviewTopic topic)`에서 `from(InterviewAnswerScoreDto score)`로 바꾼다. 같은 패키지의 `InterviewAnswerScoreResponse.from(InterviewAnswerScoreDto)`와 같은 형태다. `of` 호출처는 `toWeakTopics` 하나뿐이다
- 필드 순서: `unitId`, `unitTitle`, `topic` (학습 이동 대상 정보를 앞에)

**`InterviewSessionSummaryResponse`**
- `weakTopics`의 `@Schema` description만 바꾼다
  - 현행: `약점 분야 (문항 획득 점수가 문항 만점의 절반 이하인 문항의 유닛, 중복 제거)`
  - 변경: `약점 분야 (문항 획득 점수가 문항 만점의 절반 이하인 문항의 유닛, 유닛 기준 중복 제거, 문항 순서)`

### 6. Controller / Docs
- Controller 변경 없음: `GET /api/v1/interview-sessions/{sessionId}/summary → getSessionSummary`
- `InterviewFeedbackControllerDocs.getSessionSummary`
  - description의 `약점 분야는 문항 획득 점수가 문항 만점의 절반 이하인 문항의 유닛이며 중복을 제거합니다.<br>` 뒤에 `같은 주제의 유닛이 여럿이면 주제가 반복되므로 유닛 제목으로 구분합니다.<br>`를 추가한다
  - 성공 예시의 `weakTopics`를 같은 주제 두 유닛 + 다른 주제 한 유닛으로 바꾼다 (아래 "예상 응답 스키마"의 예시와 동일)

### 7. 서비스 정책 - `interview.md`
- 약점 판정(현 260행): `유닛과 함께 문항의 주제 태그를 보여준다` → `유닛 ID, 유닛 제목과 함께 문항의 주제 태그를 보여준다. 같은 주제의 서로 다른 유닛은 각각 나가며 유닛 제목으로 구분한다`
- 학습 콘텐츠 연결(현 301행): `결과 화면에 보여줄 유닛 표시명 규칙은 미결 과제(P9)다` → `결과 화면의 유닛 표시명은 유닛 제목을 가공하지 않고 그대로 쓴다`
- 미결 과제 표 P9: `미확정` → `확정 - 유닛 제목(unit.title)을 그대로 쓴다`

## 결정 필요 (Decisions needed)
- 없음 (P9 표시명 = `Unit.title` 그대로, 이슈 발의 단계에서 확정)

## 나중에 고려할 문제
- 유닛 행이 없는 문항: `interview_question.unit_id`에 FK가 없어 이론상 가능하다. 현재 기본값은 LEFT JOIN으로 문항별 점수는 유지하고 약점 분야의 `unitTitle`은 null로 나간다. 유닛 삭제 경로가 코드에 없고 정책상 유닛 없는 문제는 등록할 수 없어 지금은 다루지 않는다. 생기면 약점 분야에서 제외할지, FK를 걸지 정한다
- 같은 주제 묶음 표시(주제 헤더 아래 유닛 나열)는 클라이언트 표현 몫으로 두고 서버 응답은 평평한 목록을 유지한다

## 검증
- 대상 테스트: `InterviewFeedbackQueryServiceIntegrationTest` (`@Nested` 세션 종합 조회)
  - 픽스처 변경: `saveQuestionPool`에서 `UnitRepository`로 유닛 4개(같은 챕터, display_order 1~4)를 먼저 저장하고 생성된 id로 문제를 만든다. 고정 상수 `*_UNIT_ID`(11~14)는 실재하지 않는 유닛이라 제목 검증이 안 되므로, 저장한 유닛 id와 제목 상수로 바꾼다
  - `점수와_만점_문항별_점수_약점_분야를_조회한다`: 기존 unitId, 주제 검증에 `unitTitle` 순서 검증(알고리즘, 네트워크, 데이터베이스 유닛 제목) 추가. 네트워크 같은 유닛 2문항이 1개로 합쳐지는 현행 검증 유지
  - 신규 `같은_주제의_서로_다른_유닛이_약점이면_유닛_제목으로_구분된다`: 알고리즘 주제 5문항이 서로 다른 유닛 5개를 가리키고 모두 약점일 때 `weakTopics`가 5개, 주제는 모두 ALGORITHM, `unitTitle`은 5개가 서로 다르고 문항 순서대로 나온다
  - 회귀: `answers`가 유닛 조인 후에도 5개, 문항 순서대로 나오는지 기존 검증으로 확인
- 빌드: `./gradlew compileJava`로 JPQL 생성자 표현식 인자 순서 확인(Hibernate HQL 파싱은 컨텍스트 기동 시 검증)

## 예상 응답 스키마

`GET /api/v1/interview-sessions/{sessionId}/summary` 응답 중 `weakTopics`만 바뀐다. 나머지 필드는 현행과 같다.

**`weakTopics[]` 요소 (`InterviewWeakTopicResponse`)**

| 필드 | 타입 | 필수 | 설명 | 변경 |
|---|---|---|---|---|
| `unitId` | long | O | 학습 이동 대상 유닛 ID | 유지 |
| `unitTitle` | string | O | 학습 이동 대상 유닛 제목 (`unit.title` 그대로) | 추가 |
| `topic.topic` | string (enum `InterviewTopic`) | O | 약점 문항의 주제 태그 | 유지 |
| `topic.displayName` | string | O | 주제 표시명 | 유지 |

- 정렬: 문항 순서(`displayOrder`). 같은 유닛이 여러 문항이면 처음 나온 문항 자리에 1개만 나간다
- 빈 배열: 약점 문항이 없으면 `[]`

**예시** (1, 2번 알고리즘의 서로 다른 유닛, 4번 네트워크가 약점)

```json
{
  "sessionId": 12,
  "sequence": 3,
  "startedAt": "2026-09-04T10:15:30",
  "score": 52,
  "maxScore": 100,
  "accuracyScore": 34,
  "accuracyMaxScore": 70,
  "deliveryScore": 18,
  "deliveryMaxScore": 30,
  "averageAccuracyScore": 49,
  "averageDeliveryScore": 21,
  "recentSessions": [
    {"sessionId": 5, "sequence": 1, "accuracyScore": 40, "deliveryScore": 18},
    {"sessionId": 9, "sequence": 2, "accuracyScore": 47, "deliveryScore": 18},
    {"sessionId": 12, "sequence": 3, "accuracyScore": 34, "deliveryScore": 18}
  ],
  "answers": [
    {"displayOrder": 1, "topic": {"topic": "ALGORITHM", "displayName": "알고리즘"}, "accuracyScore": 4, "deliveryScore": 2},
    {"displayOrder": 2, "topic": {"topic": "ALGORITHM", "displayName": "알고리즘"}, "accuracyScore": 5, "deliveryScore": 3},
    {"displayOrder": 3, "topic": {"topic": "DATA_STRUCTURE", "displayName": "자료구조"}, "accuracyScore": 12, "deliveryScore": 5},
    {"displayOrder": 4, "topic": {"topic": "NETWORK", "displayName": "네트워크"}, "accuracyScore": 3, "deliveryScore": 2},
    {"displayOrder": 5, "topic": {"topic": "DATABASE", "displayName": "데이터베이스"}, "accuracyScore": 10, "deliveryScore": 6}
  ],
  "weakTopics": [
    {"unitId": 21, "unitTitle": "정렬", "topic": {"topic": "ALGORITHM", "displayName": "알고리즘"}},
    {"unitId": 24, "unitTitle": "그래프 탐색", "topic": {"topic": "ALGORITHM", "displayName": "알고리즘"}},
    {"unitId": 7, "unitTitle": "TCP와 UDP", "topic": {"topic": "NETWORK", "displayName": "네트워크"}}
  ]
}
```

현행 대비 차이 (`weakTopics` 요소 하나)

```diff
- {"unitId": 21, "topic": {"topic": "ALGORITHM", "displayName": "알고리즘"}}
+ {"unitId": 21, "unitTitle": "정렬", "topic": {"topic": "ALGORITHM", "displayName": "알고리즘"}}
```

- 필드 추가만 있어 기존 클라이언트는 깨지지 않는다(하위 호환)

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
