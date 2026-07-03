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
