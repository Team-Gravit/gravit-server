---
description: Controller 레이어 작성 패턴
paths:
  - "src/main/java/**/controller/**/*.java"
---

# Controller Convention

- `@RestController` + `@RequiredArgsConstructor`를 사용하라
- 기본 경로는 `@RequestMapping("/api/v1/{리소스}")`으로 설정하라
- 새 리소스 경로는 kebab-case 복수형으로 작성하라 (`/api/v1/chapters`, `/api/v1/interview-sessions`)
  - 기존 경로는 클라이언트 계약이므로 이 규칙에 맞추려고 바꾸지 마라 (`/api/v1/league`, `/api/v1/notice`)
  - 예외: 단일 리소스(`/me`), 기능 네임스페이스(`/auth`, `/oauth`, `/social`, `/ranking`), 하위 동작 경로(`/submit`, `/abandon`, `/restore`)
  - 관리자 API는 `/api/v1/admin/{리소스 복수형}`, QA API는 `/api/v1/test/...`를 쓴다
- 반드시 `controller/docs/{Controller}Docs` 인터페이스를 implements 하라 (작성 규칙은 `api-docs-convention.md`)
- Controller에 비즈니스 로직을 넣지 마라. Facade 또는 Service에 위임만 하라
- Facade가 있으면 Facade를 주입하라. 없으면 Service를 직접 주입하라. 엔드포인트에 따라 일부는 Facade에, 일부는 Service에 위임하는 경우 둘을 함께 주입해도 된다
- 인증된 사용자는 `@AuthenticationPrincipal LoginUser loginUser`로 주입받아라
- 성공 응답은 `ResponseEntity.status(XXX).body(...)` 형식으로 통일하라 (body가 없으면 `.status(XXX).build()`). `HttpStatus` 상수는 static import로 쓴다 (`import static org.springframework.http.HttpStatus.OK;`). `ok()`, `noContent()` 같은 축약형은 쓰지 말고, `HttpStatus`를 지역 변수에 담지 말고 `status()`에 바로 넘겨라
