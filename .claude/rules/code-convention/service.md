---
description: Service 레이어 작성 패턴
paths:
  - "src/main/java/**/service/**/*.java"
---

# Service Convention

- `@Service` + `@RequiredArgsConstructor`를 사용하라
- Service는 단일 도메인 로직만 담당하라. 다른 도메인 Service를 직접 호출하지 마라
- Query/Command를 분리할 때는 `{Domain}QueryService`, `{Domain}CommandService`로 네이밍하라
- 조회 메서드에는 `@Transactional(readOnly = true)`를, 변경 메서드에는 `@Transactional`을 붙여라
