# [PLAN-480] 레슨 조회 응답에 챕터 정보 추가

> 이슈: #480
> 브랜치: hotfix/480-lesson-chapter-info

## 목표

레슨 페이지 디자인이 변경되어 화면에 유닛이 속한 챕터명을 함께 보여줘야 한다.
`GET /api/v1/lessons/{unitId}` 응답에 챕터의 id, title만 담은 중첩 객체 `chapterSummary`를 추가한다.

## 영향 범위

### 신규 파일

- `src/main/java/gravit/code/chapter/dto/response/ChapterBriefResponse.java` — 챕터 id, title만 담는 응답 DTO

### 수정 파일

- `src/main/java/gravit/code/chapter/repository/ChapterRepository.java` — 유닛 아이디로 챕터 요약을 조회하는 쿼리 추가
- `src/main/java/gravit/code/chapter/service/ChapterQueryService.java` — 위 쿼리를 호출하는 조회 메서드 추가
- `src/main/java/gravit/code/lesson/dto/response/LessonDetailResponse.java` — `chapterSummary` 필드를 맨 앞에 추가
- `src/main/java/gravit/code/lesson/facade/LessonFacade.java` — `ChapterQueryService` 주입, 챕터 조회 결과를 응답에 조합
- `src/main/java/gravit/code/lesson/controller/LessonControllerDocs.java` — 레슨 목록 조회에 챕터 조회 실패 404 예시 추가
- `src/test/java/gravit/code/lesson/facade/LessonFacadeUnitTest.java` — `ChapterQueryService` mock 추가, 챕터 필드 검증
- `src/test/java/gravit/code/lesson/facade/LessonFacadeIntegrationTest.java` — 챕터 id, title 반환 검증
- `src/test/java/gravit/code/chapter/service/ChapterQueryServiceIntegrationTest.java` — 유닛 기준 챕터 조회 성공, 실패 케이스 추가

서비스 정책(`.claude/spec/service-policy/content.md`) 변경 없음. 응답 필드 추가일 뿐 판정 기준이나 구조 규칙은 그대로다.

## 구현 계획

1. **Entity / Flyway**: DB 변경 없음. `Unit.chapterId`가 이미 존재해 조인만으로 해결된다.

2. **Repository**: `ChapterRepository.findChapterBriefByUnitId(long unitId)` → `Optional<ChapterBriefResponse>`

   ```java
   @Query("""
       SELECT new gravit.code.chapter.dto.response.ChapterBriefResponse(c.id, c.title)
       FROM Chapter c
       JOIN Unit u ON u.chapterId = c.id
       WHERE u.id = :unitId
   """)
   Optional<ChapterBriefResponse> findChapterBriefByUnitId(@Param("unitId") long unitId);
   ```

   반환 타입이 챕터 데이터이므로 `ChapterRepository`에 둔다. `UnitRepository.findRecommendedUnitsByIds`가 이미
   `JOIN Chapter c ON c.id = u.chapterId` 형태를 쓰고 있어 조인 방식은 기존 패턴과 같다.

3. **Service**: `ChapterQueryService.getChapterBriefByUnitId(long unitId)` → `ChapterBriefResponse`

   ```java
   @Transactional(readOnly = true)
   public ChapterBriefResponse getChapterBriefByUnitId(long unitId) {
       return chapterRepository.findChapterBriefByUnitId(unitId)
               .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
   }
   ```

4. **Facade**: 필요함 — `LessonFacade`가 이미 여러 도메인 Service를 조합한다.
   `ChapterQueryService`를 필드로 추가하고(`unitQueryService`와 같은 콘텐츠 도메인 그룹에 배치),
   `getAllLessonInUnit`에서 유닛 조회 직후 챕터를 조회해 `LessonDetailResponse.create`에 넘긴다.

   ```java
   UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByUnitId(unitId);

   ChapterBriefResponse chapterSummary = chapterQueryService.getChapterBriefByUnitId(unitId);
   ```

   유닛 조회가 먼저이므로 없는 유닛은 `UNIT_NOT_FOUND`로 먼저 걸러진다.
   요청당 쿼리는 4개에서 5개로 늘어난다. 챕터 PK 조인 단건 조회라 비용은 무시할 수준이다.

5. **DTO**

   - 신규 `ChapterBriefResponse(long chapterId, String title)` — `@Schema`는 `ChapterSummaryResponse`와 같은 표기를 쓴다.
     이름은 기존 `ChapterSummaryResponse`(id, title, description)와 구분하기 위한 것이다.
   - `LessonDetailResponse`에 `ChapterBriefResponse chapterSummary`를 **첫 번째 컴포넌트**로 추가한다.
     JSON 필드 순서가 확정된 응답 형태와 같아진다.
     `create(...)`의 파라미터도 같은 순서로 `chapterSummary`를 맨 앞에 추가한다.

   ```json
   {
     "chapterSummary": { "chapterId": 3, "title": "자료구조" },
     "unitSummaryResponse": { ... },
     "bookmarkAccessible": true,
     "wrongAnsweredNoteAccessible": true,
     "unitId": 1,
     "lessonSummaries": [ ... ]
   }
   ```

6. **Controller**: `GET /api/v1/lessons/{unitId} → LessonController.getAllLessonInUnit` — 시그니처 변경 없음.
   `LessonControllerDocs.getAllLessonInUnit`의 404 응답에 `CHAPTER_4041` 예시만 추가한다.

## 결정 필요 (Decisions needed)

- [x] 응답 형태 — 중첩 객체 `chapterSummary`(chapterId, title). 기존 `ChapterSummaryResponse` 재사용은
      요청에 없는 `description`이 함께 나가므로 제외했다.
- [x] 신규 DTO 이름 — `ChapterBriefResponse`. `ChapterSummaryResponse`가 이미 description을 포함해 이름을 나눴다.
- [x] 챕터 조회 위치 — 별도 쿼리(`ChapterRepository`). 유닛 조회 쿼리에 챕터를 조인해 붙이면 쿼리 1개를 아끼지만
      `UnitSummaryResponse` 반환 경로에 챕터 정보가 섞여 도메인 경계가 흐려진다. 핫픽스 범위에선 별도 조회를 택한다.

## 검증

- `LessonFacadeIntegrationTest.GetAllLessonInUnit` — 응답의 `chapterSummary().chapterId()`, `title()`이
  저장한 챕터와 일치하는지 검증 추가
- `LessonFacadeUnitTest.GetAllLessonInUnit` — `ChapterQueryService` mock 추가 후 챕터 필드 검증
  (mock 미추가 시 `@InjectMocks`가 null을 주입해 NPE로 깨진다)
- `ChapterQueryServiceIntegrationTest` — `@Nested GetChapterBriefByUnitId` 추가
  - 유닛이 속한 챕터의 id, title을 반환한다
  - 존재하지 않는 유닛이면 `CHAPTER_NOT_FOUND`를 던진다
- 전체 확인: `./gradlew test`

## Deviation Log
