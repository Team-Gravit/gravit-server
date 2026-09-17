---
description: Java 소스 코드를 작성하거나 수정할 때 공통으로 적용되는 컨벤션
paths:
  - "src/main/java/**/*.java"
---

# Common Code Convention

## 레이어 구조

Controller → Facade → Service → Repository 순서를 따른다.
역방향 의존을 만들지 마라: Service가 Facade를, Repository가 Service를 참조하면 안 된다.

## 예외 처리

- `throw new RestApiException(XXX)` 패턴을 사용하라. `CustomErrorCode` 상수는 static import로 쓴다 (`import static gravit.code.global.exception.domain.CustomErrorCode.XXX;`). `CustomErrorCode.XXX` 표기는 쓰지 마라
- 새 에러코드는 `CustomErrorCode` enum에 추가하되, 카테고리별 주석 그룹을 유지하라
- 에러코드 형식: `ERROR_NAME(NOT_FOUND, "DOMAIN_CODE", "한글 메시지")`. `HttpStatus` 상수도 static import로 쓴다
  - 예외: `CustomErrorCode` 안에서는 에러코드 이름과 같은 `HttpStatus` 상수(`INTERNAL_SERVER_ERROR`)를 static import로 쓸 수 없다. 이름만 쓰면 enum의 에러코드를 가리키므로 그 상수를 쓰는 에러코드는 모두 `HttpStatus.INTERNAL_SERVER_ERROR`로 쓴다

## 객체 생성

- 도메인 객체(Entity)와 Response DTO는 정적 팩토리 메서드로만 생성하라
- 팩토리 이름은 `create()`, `of()`, `from()`을 기본으로 한다. 생성 의미가 다르면 그 의미를 드러내는 이름을 써도 된다 (`UserMission.assign()`, `Season.prep()`)
- 생성자는 노출하지 말고 private + `@Builder(access = AccessLevel.PRIVATE)`로 감춰라. record는 정규 생성자를 감출 수 없으므로 외부에서는 팩토리만 호출하라
- 예외: JPQL 생성자 표현식(`SELECT new ...`)의 대상 record는 표준 생성자를 그대로 쓴다 (`dto.md`의 Internal 참고)

## 상수

- 매직넘버, 매직스트링을 코드에 직접 쓰지 말고 `private static final` 상수로 선언하라. 다른 클래스와 공유해야 하면 `public static final`로 둔다
- 상수는 클래스 상단, 인스턴스 필드보다 위에 둔다
- 대상: 비즈니스 의미가 있는 값 (한도, 기간, 개수 정책, 헤더명, 접두어, 경로, 정규식, 큐 키, payload 키)
- 비대상: 어노테이션 속성값, 설정 클래스 수치, 단위 환산 계수(`100`, `60`, `24`, `1000`), `0`, `1`, 빈 문자열, 로그와 사용자 노출 문구
- 재시도 큐 키와 필드 키는 해당 `*RetryTarget`의 `public static final` 상수로 두고, 큐에 적재하는 쪽이 그 상수를 참조하라

## 포맷팅

- 메서드와 생성자 선언의 파라미터가 2개 이상이면 파라미터마다 줄바꿈하고, 닫는 괄호는 단독 줄에 둔다 (클래스는 `) {`, 인터페이스는 `);`)
- 람다 파라미터와 메서드 호출부는 이 규칙의 대상이 아니다

```java
public ReturnType methodName(
        String param1,
        String param2,
        String param3
) {
}
```

- 주입 필드는 종류별로 묶는다. 종류가 바뀌는 곳에만 빈 줄을 넣고, 같은 종류 안에서는 빈 줄을 넣지 않는다
- 종류와 순서
  1. Facade
  2. Service (`*QueryService`, `*CommandService` 포함)
  3. Repository
  4. 그 밖의 프로젝트 컴포넌트 (support, factory, policy, provider, `Store`, `Cache` 포트, `RetryEventPublisher` 등)
  5. 프레임워크, 라이브러리 객체와 설정 (`Clock`, `ApplicationEventPublisher`, `TransactionTemplate`, `RedisTemplate`, `ObjectMapper`, `S3Client`, `*Props`)
- 같은 종류 안의 순서는 정하지 않는다

```java
private final LessonFacade lessonFacade;

private final LessonSubmissionService lessonSubmissionService;
private final LearningCommandService learningCommandService;

private final LessonRepository lessonRepository;
private final UnitRepository unitRepository;

private final ProblemFactory problemFactory;

private final Clock clock;
private final TransactionTemplate transactionTemplate;
```

## 메서드 본문 구성

메서드 본문에서 논리 단계나 처리 대상 도메인이 바뀌면 빈 줄로 구분해 맥락을 드러내라.
특히 Facade, Service처럼 여러 단계를 조합하는 메서드는 한 단계를 처리하고 한 줄 띄운다.

```java
UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByUnitId(unitId);

List<ProblemDetailResponse> problemDetailResponses = bookmarkService.getAllBookmarkedProblemInUnit(userId, unitId);

List<ProblemResponse> problemResponses = problemFactory.create(problemDetailResponses);

return BookmarkedProblemResponse.of(
        unitSummaryResponse,
        problemResponses
);
```

## 네이밍

- 패키지는 도메인 단위로 나눠라 (`chapter`, `user`, `bookmark`, `wrongAnsweredNote`). 여러 단어 도메인은 camelCase로 쓴다 (`dailyLearningRecord`). `csnote`는 기존 예외다
- 클래스는 PascalCase로 작성하라 (`ChapterQueryService`, `BookmarkFacade`)
- 메서드는 camelCase + CRUD 동사를 사용하라 (`findById`, `addBookmark`, `deleteBookmark`)
- API 경로 규칙은 `controller.md`를 따른다
- 조회용 Map 변수는 `{키}To{값}` 형태로 지어라 (`questionIdToConcepts`, `sessionIdToTopics`, `unitIdToTopic`). `{값}By{키}`(`conceptsByQuestionId`)는 리포지토리 메서드처럼 읽혀 쓰지 않는다
  - 제외: 스프링 빈으로 주입받는 Map, 외부 규격 payload Map (OAuth `attributes`, JWT `claims`, 재시도 큐 `fields`, FCM `data` 등)

## 주석

- 메인 코드에 설명 주석을 달지 마라. 설명이 필요하다고 느끼면 주석 대신 이름과 구조로 드러내라
- 유지하는 예외
  - 나열을 구획하는 라벨 주석 (`CustomErrorCode`의 `// User`, `// Auth`, 보안 설정의 경로 그룹 라벨)
  - enum 상수에 붙은 명세 번호 주석
  - `@Deprecated`와 짝을 이루는 `@deprecated` Javadoc
- 배경과 정책 설명이 필요하면 주석이 아니라 `.claude/spec/service-policy/`의 해당 도메인 파일에 남겨라
