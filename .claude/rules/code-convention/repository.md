---
description: Repository 레이어 작성 패턴
paths:
  - "src/main/java/**/repository/**/*.java"
---

# Repository Convention

- JPA Repository 인터페이스는 `{domain}/repository/` 패키지에 위치시켜라
- 복잡한 쿼리는 `repository/custom/` 또는 `repository/sql/`로 분리하라
- Projection은 `dto/response/`의 record로 직접 반환하라

## @Query 포맷

- JPQL은 한 줄짜리라도 항상 텍스트 블록(`"""`)으로 작성하라. `@Query("SELECT ...")` 한 줄 형태는 쓰지 마라
- 여는 `"""`는 `@Query(` 바로 뒤에 붙이고, 본문은 `@Query`보다 8칸 더 들여쓴다. 닫는 `""")`는 `@Query`와 같은 들여쓰기에 둔다
- 절(`SELECT`, `FROM`, `WHERE`, `ORDER BY`, `GROUP BY`)마다 줄을 바꾼다

```java
    @Query("""
            SELECT s FROM InterviewSession s
            WHERE s.userId = :userId AND s.status = :status
            ORDER BY s.startedAt DESC, s.id DESC
    """)
    List<InterviewSession> findRecentByUserIdAndStatus(
            @Param("userId") long userId,
            @Param("status") InterviewSessionStatus status,
            Pageable pageable
    );
```
