---
description: 테스트 코드 작성 규칙 (통합 테스트 중심)
paths:
  - "src/test/java/**"
---

# Test Convention

테스트는 통합 테스트(`@TCSpringBootTest`)로 작성한다. `@ExtendWith(MockitoExtension.class)` 기반 단위 테스트는 새로 만들지 않는다.

## 네이밍 & 설정

- 파일명: `{Class}IntegrationTest.java`
- 클래스 어노테이션: `@TCSpringBootTest`. 아래 구성이 함께 들어온다
  - PostgreSQL, Redis Testcontainers
  - 고정 시계 `2025-08-05T12:00+09:00`(Asia/Seoul) `Clock` 빈 (`FixedClockConfig`)
  - FCM 스텁(`FcmTestConfig`), 면접 채점 LLM 클라이언트 스텁(`InterviewGradingTestConfig`, `StubInterviewGradingClient`)
  - `DatabaseClearExtension`
- 의존성 주입: `@Autowired`
- DB 초기화: DB와 Redis는 `DatabaseClearExtension`이 매 테스트 전에 비운다 (public 스키마 전체 TRUNCATE, Flyway 시딩 데이터 포함, Redis `flushDb`). IDENTITY 시퀀스는 되돌리지 않는다
  - 초기화용 `@Sql`을 붙이지 마라
  - IDENTITY를 1부터 맞춰야 하는 테스트만 `@Sql(scripts = "classpath:sql/reset_main_page_ids.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)` 같은 스크립트를 쓴다
- Controller 테스트: `@AutoConfigureMockMvc` + `MockMvc`. 인증이 필요하면 `SecurityMockMvcRequestPostProcessors.authentication(...)`에 `LoginUser`를 담은 `UsernamePasswordAuthenticationToken`을 넘겨라 (`AdminDashboardControllerIntegrationTest`의 `관리자_인증()` 참고)
- 검증 라이브러리는 AssertJ (`assertThat`, `assertSoftly`, `assertThatThrownBy`)
- 테스트 패키지는 `src/main/java`의 도메인 구조를 미러링하라

## 목(mock) 사용

통합 테스트 안에서는 아래 용도에 한해 `@MockitoBean`, `@MockitoSpyBean`을 쓴다.

- 외부 연동 대체: `S3Client`, `OAuthHttpClientAdapter`, `FcmService`, `MailSender` 등
- 실패 주입: 리스너, 재시도 경로를 검증하려고 서비스나 퍼블리셔가 예외를 던지게 할 때
- 호출 검증: 재시도 큐 적재나 후속 호출이 일어났는지 확인할 때

## 순수 JUnit 테스트

Spring 의존 없이 입력만으로 결과가 정해지는 domain, util, support 로직(VO 계산, 포맷터, 캘린더 계산)은 Spring 컨텍스트 없이 순수 JUnit으로 작성해도 된다. 파일명은 `{Class}Test.java`로 한다 (`UserLevelTest`).

## 메서드 작성

- 메서드명은 한글 서술형 (`최근_학습_챕터와_유닛_진행_요약을_정상적으로_반환한다()`)
- `@Nested` + `@DisplayName`으로 그룹화 (`@DisplayName("북마크를 추가할 때")`)
- 본문은 `// given` / `// when` / `// then` 주석으로 구간을 구분하라
  - 준비 단계가 없으면 `// given`을 생략한다
  - 실행과 검증이 한 문장이면 `// when & then`으로 합친다 (`assertThatThrownBy`)

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
| 메서드명 | 한글로 시나리오 표현 (`LearningFixture.기본_학습(userId)`, `LearningFixture.오늘_학습한_학습(...)`) |
| static 팩토리 fixture | 저장하지 않은 Entity나 DTO를 반환하는 `{Domain}Fixture` 클래스 |
| 저장형 fixture | `@TestComponent` + `@RequiredArgsConstructor`로 Repository나 다른 fixture를 주입받아 저장까지 하는 fixture. 테스트에서는 `@Autowired`로 받는다 |
| 복잡한 Entity | `{Domain}FixtureBuilder` 클래스 (기본값 + 필드 오버라이드) |
| Entity id 설정 | `ReflectionTestUtils.setField(entity, "id", 1L)` |
| VO 타입 명시 | `ReflectionTestUtils.setField(user, "level", level, UserLevel.class)` |
