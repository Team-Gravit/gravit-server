---
description: DTO(Request/Response) 클래스 작성 패턴
paths:
  - "src/main/java/**/dto/**/*.java"
---

# DTO Convention

- DTO는 `record` 타입으로 선언하라
- 패키지는 `{domain}/dto/request/`, `{domain}/dto/response/`로 분리하라
- record 컴포넌트(필드) 사이는 빈 줄로 구분하라

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
- 기존 파일 중 접미사가 다른 것(`*Projection`, `*Row`, `*Entry` 등)은 따르지 마라. 새로 만들 때는 `Dto`로 통일한다
