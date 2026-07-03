---
description: Facade 레이어 작성 패턴
paths:
  - "src/main/java/**/facade/**/*.java"
---

# Facade Convention

- 커스텀 어노테이션 `@Facade` + `@RequiredArgsConstructor`를 사용하라 (`gravit.code.global.annotation.Facade`)
- Facade는 여러 Service를 조합하는 비즈니스 로직을 담당한다
- 단일 Service 호출만 필요한 경우 Facade를 만들지 마라. Controller에서 Service를 직접 주입하라
