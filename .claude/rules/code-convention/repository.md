---
description: Repository 레이어 작성 패턴
paths:
  - "src/main/java/**/repository/**/*.java"
---

# Repository Convention

- JPA Repository 인터페이스는 `{domain}/repository/` 패키지에 위치시켜라
- 복잡한 쿼리는 `repository/custom/` 또는 `repository/sql/`로 분리하라
- Projection은 `dto/response/`의 record로 직접 반환하라
