---
description: Swagger API 문서(ControllerDocs 인터페이스) 작성 규칙
paths:
  - "src/main/java/**/controller/docs/**"
  - "src/main/java/gravit/code/test/**/docs/**"
---

# API Docs Convention

## 파일 구조

- 각 Controller마다 `controller/docs/{Controller}Docs.java` 인터페이스를 생성하라
- Controller는 이 인터페이스를 `implements` 하라
- Swagger 어노테이션은 Docs 인터페이스에만 선언하라. Controller에는 붙이지 마라

## 적용 범위

- 관리자 API(`/api/v1/admin/**`)는 `springdoc.paths-to-exclude`로 Swagger에서 빠져 있다. admin Docs에는 아래 응답 규칙(✅/🚨 표기, 에러 예시, `GLOBAL_5001`)을 적용하지 않는다
- QA API(`test/`) Docs는 `@Tag` name을 `"Test "`로 시작하는 것만 필수다 (`SwaggerConfig`의 `TEST_TAG_PREFIX`). 응답 규칙은 선택이다

## 어노테이션 규칙

### 인터페이스 레벨

| 어노테이션 | 규칙 | 예시 |
|---|---|---|
| `@Tag` | name: `"{Domain} API"` | `"Friend API"`, `"User API"` |

### 메서드 레벨

| 어노테이션 | 규칙 | 예시 |
|---|---|---|
| `@Operation` summary | 기능을 한 줄로 요약 | `"팔로잉"`, `"유저 정보 조회"` |
| `@Operation` description | JWT 필요 시 `"🔐 <strong>Jwt 필요</strong><br>"` 포함 | - |
| `@Parameter` | PathVariable, RequestParam에 `description` 명시 | `@Parameter(description = "챕터 ID")` |

### 응답 (`@ApiResponses`)

| 구분 | description 형식 | 비고 |
|---|---|---|
| 성공 | `"✅ {성공 메시지}"` | - |
| 실패 | `"🚨 {에러 설명}"` | `schema = @Schema(implementation = ErrorResponse.class)` |
| 500 | `"🚨 예기치 못한 예외 발생"` | 모든 API에 `GLOBAL_5001` 포함 필수 |

- `@ExampleObject`의 value는 `CustomErrorCode` enum의 실제 code/message를 그대로 사용하라
- `ErrorResponse`는 `gravit.code.global.exception.domain.ErrorResponse`를 사용하라

### 파라미터

- `@AuthenticationPrincipal LoginUser loginUser`는 Docs 인터페이스에도 동일하게 선언하라

## DTO @Schema

- Request/Response record의 각 필드에 `@Schema`를 붙여라
- 속성이 2개 이상이면 줄바꿈:
```java
@Schema(
        description = "문제 아이디",
        example = "1"
)
```
