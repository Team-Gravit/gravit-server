---
description: 테스트 코드 작성 규칙 (모든 테스트는 통합 테스트)
---

# Test Convention

모든 테스트는 통합 테스트(`@TCSpringBootTest`)로 작성한다. 단위 테스트(Mockito)는 쓰지 않는다.

## 네이밍 & 설정

- 파일명: `{Class}IntegrationTest.java`
- 클래스 어노테이션: `@TCSpringBootTest` (Testcontainers + PostgreSQL)
- 의존성 주입: `@Autowired`
- DB 초기화: `@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = BEFORE_TEST_METHOD)`
- Controller 테스트: `@AutoConfigureMockMvc` + `@WithMockLoginUser`
- 검증 라이브러리는 AssertJ (`assertThat`, `assertSoftly`, `assertThatThrownBy`)
- 테스트 패키지는 `src/main/java`의 도메인 구조를 미러링하라

## 메서드 작성

- 메서드명은 한글 서술형 (`연속학습일수_업데이트에_성공한다()`)
- `@Nested` + `@DisplayName`으로 그룹화 (`@DisplayName("북마크를 추가할 때")`)
- 본문은 `// given` / `// when` / `// then` 주석으로 구간을 구분하라

## 예외 검증

`RestApiException`을 던지는 예외 케이스는 반드시 `errorCode`까지 검증하라. 타입만 검증하면 다른 errorCode로 회귀해도 통과해 회귀를 못 잡는다.

- 타입: `.isInstanceOf(RestApiException.class)`
- errorCode: `.extracting(e -> ((RestApiException) e).getErrorCode()).isEqualTo({CODE})`
- `CustomErrorCode`는 static import로만 사용하라 (`CustomErrorCode.X` 표기 금지)

```java
import static gravit.code.global.exception.domain.CustomErrorCode.CHAPTER_NOT_FOUND;

assertThatThrownBy(() -> chapterQueryService.getChapterSummary(chapterId))
        .isInstanceOf(RestApiException.class)
        .extracting(e -> ((RestApiException) e).getErrorCode())
        .isEqualTo(CHAPTER_NOT_FOUND);
```

## Fixture

| 항목 | 규칙 |
|---|---|
| 위치 | `src/test/java/gravit/code/{domain}/fixture/` |
| 메서드명 | 한글로 시나리오 표현 (`LearningFixture.당일_학습_완료(userId)`) |
| 복잡한 Entity | `{Domain}FixtureBuilder` 클래스 (기본값 + 필드 오버라이드) |
| Entity id 설정 | `ReflectionTestUtils.setField(entity, "id", 1L)` |
| VO 타입 명시 | `setField(user, "level", level, UserLevel.class)` |
