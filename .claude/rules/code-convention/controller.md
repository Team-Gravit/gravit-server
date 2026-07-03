---
description: Controller 레이어 작성 패턴
paths:
  - "src/main/java/**/controller/**/*.java"
---

# Controller Convention

- `@RestController` + `@RequiredArgsConstructor`를 사용하라
- 기본 경로는 `@RequestMapping("/api/v1/{도메인복수형}")`으로 설정하라
- 반드시 `{Controller}Docs` 인터페이스를 implements 하라
- Controller에 비즈니스 로직을 넣지 마라. Facade 또는 Service에 위임만 하라
- Facade가 있으면 Facade를 주입하라. 없으면 Service를 직접 주입하라. 엔드포인트에 따라 일부는 Facade에, 일부는 Service에 위임하는 경우 둘을 함께 주입해도 된다
- 인증된 사용자는 `@AuthenticationPrincipal LoginUser loginUser`로 주입받아라
- 성공 응답은 `ResponseEntity.status(HttpStatus.XXX).body(...)` 형식으로 통일하라 (body가 없으면 `.status(HttpStatus.XXX).build()`). `ok()`·`noContent()` 같은 축약형은 쓰지 마라
