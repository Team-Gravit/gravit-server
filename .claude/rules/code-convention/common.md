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

- `throw new RestApiException(CustomErrorCode.XXX)` 패턴을 사용하라
- 새 에러코드는 `CustomErrorCode` enum에 추가하되, 카테고리별 주석 그룹을 유지하라
- 에러코드 형식: `ERROR_NAME(HttpStatus.XXX, "DOMAIN_CODE", "한글 메시지")`

## 객체 생성

- 도메인 객체(Entity)와 Response DTO는 정적 팩토리 메서드(`create()` / `of()`)로만 생성하라
- 생성자는 노출하지 말고 private + `@Builder(access = AccessLevel.PRIVATE)`로 감춰라

## 상수

- 매직넘버·매직스트링을 코드에 직접 쓰지 말고 `private static final` 상수로 클래스 상단에 선언하라

## 포맷팅

- 메서드 파라미터가 2개 이상이면 각 파라미터를 줄바꿈하여 작성하라
```java
public ReturnType methodName(
        String param1,
        String param2,
        String param3
) {
}
```

- 의존성 주입 필드가 여러 개면 도메인·성격별로 빈 줄로 그룹핑하라

## 메서드 본문 구성

메서드 본문에서 논리 단계나 처리 대상 도메인이 바뀌면 빈 줄로 구분해 맥락을 드러내라.
특히 Facade·Service처럼 여러 단계를 조합하는 메서드는 한 단계를 처리하고 한 줄 띄운다.

```java
// 한 도메인/단계 처리
UnitSummaryResponse unit = unitQueryService.getUnitSummaryByUnitId(unitId);

// 다음 도메인/단계 처리
List<ProblemDetailResponse> problems = bookmarkService.getAllBookmarkedProblemInUnit(userId, unitId);

// 응답 조립
return BookmarkedProblemResponse.of(unit, problems);
```

## 네이밍

- 패키지는 도메인 단위로 나눠라 (`chapter`, `user`, `bookmark`, `wrongAnsweredNote`)
- 클래스는 PascalCase로 작성하라 (`ChapterQueryService`, `BookmarkFacade`)
- 메서드는 camelCase + CRUD 동사를 사용하라 (`findById`, `addBookmark`, `deleteBookmark`)
- API 경로는 kebab-case 복수형으로 작성하라 (`/api/v1/chapters`, `/api/v1/bookmarks`)