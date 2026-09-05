---
description: DTO(Request/Response) 클래스 작성 패턴
paths:
  - "src/main/java/**/dto/**/*.java"
---

# DTO Convention

- DTO는 `record` 타입으로 선언하라
- 패키지는 `{domain}/dto/request/`, `{domain}/dto/response/`로 분리하라
- record 컴포넌트(필드) 사이는 빈 줄로 구분하라
- record 안에 record를 중첩 선언하지 마라. 파일 하나에 record 하나를 두고, 목록 요소나 하위 구조는 별도 파일로 분리하라 (예: `InterviewGradingJudgmentDto` 안의 `ConceptJudgment` → `InterviewConceptJudgmentDto`)
- 값을 담아 레이어 사이를 오가는 객체는 이름이 값 객체처럼 보여도 DTO다. `domain/`이 아니라 `dto/internal/`에 `Dto` 접미사로 둬라 (예: `InterviewScoreDto`)

## Request

- `@Schema` + validation 어노테이션(`@NotNull` 등)을 포함하라

## Response

- validation 어노테이션을 붙이지 마라. validation은 Request 전용이다
- 객체 생성(정적 팩토리 + private `@Builder`)은 `common.md`를 따른다

### @Schema 포맷

- `@Schema` 속성이 2개 이상이면 한 줄에 몰아쓰지 말고 속성당 한 줄로 작성하라

```java
@Schema(
        description = "팔로워 목록",
        requiredMode = Schema.RequiredMode.REQUIRED
)
public List<FollowerResponse> contents;
```

- 속성이 1개면 한 줄로 작성해도 된다 (예: `@Schema(requiredMode = Schema.RequiredMode.REQUIRED)`)

## Internal

- 레이어 간 내부 전달용 DTO와 쿼리 프로젝션은 `{domain}/dto/internal/`에 두고, 이름은 `{Name}Dto` 접미사로 끝내라 (예: `SearchUserDto`, `UnitStatRowDto`)
- JPQL 생성자 표현식(`SELECT new ...`)의 대상이면 정적 팩토리 없이 표준 생성자를 그대로 써라. 집계 함수(`SUM`, `AVG`, `COUNT`) 결과는 래퍼 타입(`Long`, `Double`)으로 받아 생성자 매칭 실패를 막아라
- 외부 노출용이 아니므로 `@Schema`를 붙이지 마라
- LLM 구조화 출력(`ChatClient.entity()`)에 바인딩되는 DTO는 출력 계약을 Jackson 스키마 애노테이션으로 적어라. `@JsonPropertyDescription`에 판정 기준, `@JsonProperty(required = true)`에 필수 여부, `@JsonPropertyOrder`로 근거 필드를 판정 필드보다 앞에 둔다. `BeanOutputConverter`가 이 애노테이션으로 JSON 스키마를 만들어 프롬프트에 붙인다
- 기존 파일 중 접미사가 다른 것(`*Projection`, `*Row`, `*Entry` 등)은 따르지 마라. 새로 만들 때는 `Dto`로 통일한다
