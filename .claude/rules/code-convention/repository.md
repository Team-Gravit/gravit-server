---
description: Repository 레이어 작성 패턴
paths:
  - "src/main/java/**/repository/**/*.java"
---

# Repository Convention

- JPA Repository 인터페이스는 `{domain}/repository/` 패키지에 위치시켜라
- `@Query`로 표현하기 어려운 쿼리(동적 조건, `NamedParameterJdbcTemplate` 조회)는 `repository/custom/`에 인터페이스와 `Impl`을 두고, SQL 문자열은 `repository/sql/`의 `@UtilityClass` 상수로 분리하라
- 조회 조건에 따라 쿼리를 골라 쓰는 전략은 `repository/strategy/`에 둔다
- JPQL 생성자 표현식(`SELECT new ...`) 프로젝션은 `dto/internal/{Name}Dto`로 받아라. 조회 결과가 API 응답 record와 모양이 같아 그대로 반환할 때만 `dto/response/`의 Response record를 대상으로 해도 된다

## @Query 포맷

- 한 줄짜리라도 항상 텍스트 블록(`"""`)으로 작성하라. `@Query("SELECT ...")` 한 줄 형태는 쓰지 마라
- 여는 `"""`는 `@Query(` 바로 뒤에 붙인다. 네이티브 쿼리는 `@Query(value = """`로 연다
- 본문은 `@Query`보다 8칸 더 들여쓴다. 닫는 줄은 `@Query`와 같은 들여쓰기에 둔다 (JPQL은 `""")`, 네이티브는 `""", nativeQuery = true)`)
- `countQuery`가 있으면 `""", countQuery = """`를 `@Query`와 같은 들여쓰기의 단독 줄로 두고, 마지막 줄을 `""", nativeQuery = true)`로 닫는다
- 최상위 절(`SELECT`, `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`)마다 줄을 바꾼다. 괄호 안 서브쿼리는 이 규칙의 예외다

```java
    @Query("""
            SELECT s
            FROM InterviewSession s
            WHERE s.userId = :userId AND s.status = :status
            ORDER BY s.startedAt DESC, s.id DESC
    """)
    List<InterviewSession> findRecentByUserIdAndStatus(
            @Param("userId") long userId,
            @Param("status") InterviewSessionStatus status,
            Pageable pageable
    );

    @Query(value = """
            SELECT *
            FROM users
            WHERE provider_id = :providerId
            LIMIT 1
    """, nativeQuery = true)
    Optional<User> findByProviderId(@Param("providerId") String providerId);
```

`countQuery`가 있는 네이티브 쿼리:

```java
    @Query(value = """
            SELECT u.id AS userId, u.email AS email
            FROM users u
            WHERE (:status IS NULL OR u.status = :status)
            ORDER BY u.id DESC
    """, countQuery = """
            SELECT COUNT(*)
            FROM users u
            WHERE (:status IS NULL OR u.status = :status)
    """, nativeQuery = true)
    Page<AdminUser> searchUsers(
            @Param("status") String status,
            Pageable pageable
    );
```
