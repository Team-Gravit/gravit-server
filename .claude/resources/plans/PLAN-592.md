# [PLAN-592] 웹용 CS, 직군별 챕터 조회 분리

> 이슈: #592
> 브랜치: feat/592-chapter-track

## 목표
웹은 CS 챕터와 직군 챕터를 나눠 보여줘야 하는데, 챕터에 분류 정보가 없어 구분할 수 없다.
챕터에 분류(`category`)를 추가하고, 웹용으로 CS 챕터 조회, 직군 옵션 조회, 직군별 챕터 조회 API를 새로 만든다. 안드로이드가 쓰는 `GET /api/v1/chapters`는 응답 계약을 바꾸지 않는다.

## 확정 매핑

| 분류 | 챕터 id | 제목 |
|---|---|---|
| CS | 1~5 | 자료구조, 알고리즘, 네트워크, 데이터베이스, 운영체제 |
| COMMON | 6~9 | Server, Web, AOS, iOS (직군 공통 기반) |
| SERVER | 10~12 | Spring, Node.js, Django |
| WEB | 13~15 | React, Vue.js, Next.js |
| AOS | 16 | Android |
| IOS | 17 | iOS (SwiftUI) |
| LANGUAGE | 18~22 | Java, Kotlin, TypeScript, Python, Swift |

- dev DB(`gravit_dev`) 22개 행의 id, 제목이 시드 SQL과 일치함을 사용자가 확인했다

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V50__add_chapter_category.sql` - `chapter.category` 추가, 기존 22개 백필, NOT NULL, CHECK
- `src/main/java/gravit/code/chapter/domain/ChapterCategory.java` - 챕터 분류 enum (직군 여부, 직군 목록)

### 수정 파일
- `src/main/java/gravit/code/chapter/domain/Chapter.java` - `category` 필드 추가, `create` 시그니처 변경
- `src/main/java/gravit/code/chapter/repository/ChapterRepository.java` - 분류별 요약, 분류별 진행도 쿼리 추가
- `src/main/java/gravit/code/chapter/service/ChapterQueryService.java` - 분류별 조회 2개, 직군 옵션 조회 1개 추가
- `src/main/java/gravit/code/chapter/facade/ChapterFacade.java` - CS 챕터 조회, 직군별 챕터 조회 추가, 진행도 결합 로직을 private 메서드로 추출
- `src/main/java/gravit/code/chapter/controller/ChapterController.java` - 엔드포인트 3개 추가, `ChapterQueryService` 추가 주입
- `src/main/java/gravit/code/chapter/controller/docs/ChapterControllerDocs.java` - 신규 3개 문서화 (`write-api-docs` 규칙)
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `CHAPTER_TRACK_INVALID` 추가
- `src/main/resources/sql/chapter/chapter.sql` - INSERT에 `category` 컬럼 추가 (`CS`)
- `src/main/resources/sql/chapter/chapter_track.sql` - INSERT에 `category` 컬럼 추가 (매핑표대로)
- `src/test/java/gravit/code/chapter/fixture/ChapterFixture.java` 외 `Chapter.create`를 직접 호출하는 테스트 20개 파일 - 시그니처 변경에 맞춰 분류 인자 추가 (결정 1)
- `.claude/spec/service-policy/content.md` - 정책 추가: 챕터 분류, 직군 옵션, 조회 순서

## 구현 계획

### 1. Entity / Flyway

#### `V50__add_chapter_category.sql`

upstream dev 최신이 `V49__add_client_to_apple_credential.sql`이라 V50을 쓴다. 머지 전에 dev에 V50이 먼저 들어오면 번호를 올린다.

```sql
-- V50__add_chapter_category.sql

-- 챕터 분류 컬럼을 추가한다. 기존 행을 채우기 전이라 NULL 을 허용한다.
ALTER TABLE chapter
    ADD COLUMN IF NOT EXISTS category VARCHAR(255);

-- 기존 챕터 22개에 분류를 채운다.
-- 제목이 겹치는 챕터(9 iOS 공통, 17 iOS SwiftUI)가 있어 제목만으로는 못 맞추고, id 와 제목을 함께 맞춘다.
UPDATE chapter c
SET category = m.category
FROM (VALUES (1, '자료구조', 'CS'),
             (2, '알고리즘', 'CS'),
             (3, '네트워크', 'CS'),
             (4, '데이터베이스', 'CS'),
             (5, '운영체제', 'CS'),
             (6, 'Server', 'COMMON'),
             (7, 'Web', 'COMMON'),
             (8, 'AOS', 'COMMON'),
             (9, 'iOS', 'COMMON'),
             (10, 'Spring', 'SERVER'),
             (11, 'Node.js', 'SERVER'),
             (12, 'Django', 'SERVER'),
             (13, 'React', 'WEB'),
             (14, 'Vue.js', 'WEB'),
             (15, 'Next.js', 'WEB'),
             (16, 'Android', 'AOS'),
             (17, 'iOS', 'IOS'),
             (18, 'Java', 'LANGUAGE'),
             (19, 'Kotlin', 'LANGUAGE'),
             (20, 'TypeScript', 'LANGUAGE'),
             (21, 'Python', 'LANGUAGE'),
             (22, 'Swift', 'LANGUAGE')) AS m(id, title, category)
WHERE c.id = m.id
  AND c.title = m.title;

-- 매핑에 없는 챕터가 남아 있으면 여기서 실패한다. 분류가 틀린 채로 배포되는 것보다 마이그레이션 실패가 낫다.
ALTER TABLE chapter
    ALTER COLUMN category SET NOT NULL;

-- 분류 값을 enum 상수로 제한한다.
ALTER TABLE chapter
    ADD CONSTRAINT ck_chapter_category
        CHECK (category IN ('CS', 'COMMON', 'SERVER', 'WEB', 'AOS', 'IOS', 'LANGUAGE'));
```

- 패턴은 `V44__add_unit_display_order.sql`(NULL 허용 추가 → 백필 → NOT NULL → CHECK)을 따른다
- DEFAULT `'CS'`로 채우지 않는 이유: 매핑 밖 챕터가 조용히 CS로 들어가면 웹 CS 목록에 직군 챕터가 섞여도 알아채지 못한다
- 빌드의 `flywayValidate`는 빈 H2에서 pending을 무시하므로 SQL 문법은 PostgreSQL 기준만 맞으면 된다
- 시퀀스는 건드리지 않는다

#### `ChapterCategory` (신규, `chapter/domain`)

```java
public enum ChapterCategory {

    CS,
    COMMON,
    SERVER,
    WEB,
    AOS,
    IOS,
    LANGUAGE;

    public boolean isTrack() {
        return this != CS;
    }

    public void validateTrack() {
        if (!isTrack()) {
            throw new RestApiException(CHAPTER_TRACK_INVALID);
        }
    }

    public static List<ChapterCategory> tracks() {
        return Arrays.stream(values())
                .filter(ChapterCategory::isTrack)
                .toList();
    }
}
```

- 직군 옵션은 enum 상수명(`COMMON`, `SERVER`)으로만 내려주고 표시명은 두지 않는다 (결정 2). 화면 문구는 클라이언트가 가진다
- 직군 옵션 순서는 선언 순서(COMMON, SERVER, WEB, AOS, IOS, LANGUAGE)를 따른다
- `InterviewStackGroup`은 별도 `displayOrder`를 두지만, 여기는 노출 대상이 enum 전부가 아니라(CS 제외) CS에 의미 없는 순서값을 줘야 해서 선언 순서로 대신한다

#### `Chapter`

- 필드 추가

```java
    @Enumerated(EnumType.STRING)
    @Column(name = "category", nullable = false)
    private ChapterCategory category;
```

- private 생성자, `create`에 `ChapterCategory category` 파라미터 추가 (결정 1)

```java
    public static Chapter create(
            String title,
            String description,
            ChapterCategory category
    ) {
```

- `update(title, description)`는 그대로 둔다. 어드민 챕터 수정에서 분류는 바꾸지 않는다

### 2. Repository - `ChapterRepository`

기존 `findAllChapterSummary`, `findChapterProgressByUserId`는 그대로 둔다 (안드로이드 경로).

```java
    @Query("""
            SELECT new gravit.code.chapter.dto.response.ChapterSummaryResponse(c.id, c.title, c.description)
            FROM Chapter c
            WHERE c.category = :category
            ORDER BY c.id
    """)
    List<ChapterSummaryResponse> findAllChapterSummaryByCategory(@Param("category") ChapterCategory category);

    @Query("""
            SELECT new gravit.code.chapter.dto.internal.ChapterProgressRowDto(
                c.id, COUNT(DISTINCT l.id), COUNT(DISTINCT ls.lessonId)
            )
            FROM Chapter c
            LEFT JOIN Unit u ON u.chapterId = c.id
            LEFT JOIN Lesson l ON l.unitId = u.id
            LEFT JOIN LessonSubmission ls ON ls.lessonId = l.id AND ls.userId = :userId
            WHERE c.category = :category
            GROUP BY c.id
    """)
    List<ChapterProgressRowDto> findChapterProgressByUserIdAndCategory(
            @Param("userId") long userId,
            @Param("category") ChapterCategory category
    );
```

- 기존 전체 조회는 `ORDER BY`가 없어 순서가 보장되지 않는다. 신규 조회는 `ORDER BY c.id`로 고정한다. 기존 쿼리는 응답 계약 보존을 위해 손대지 않는다
- 진행도 쿼리는 기존과 같은 조인에 `WHERE`만 추가한다. 분류로 걸러 집계 행이 줄어든다

### 3. Service - `ChapterQueryService`

```java
    @Transactional(readOnly = true)
    public List<ChapterSummaryResponse> getChaptersByCategory(ChapterCategory category) {
        return chapterRepository.findAllChapterSummaryByCategory(category);
    }

    @Transactional(readOnly = true)
    public List<ChapterProgressRowDto> getChapterProgressByCategory(
            long userId,
            ChapterCategory category
    ) {
        return chapterRepository.findChapterProgressByUserIdAndCategory(userId, category);
    }

    public List<ChapterCategory> getTracks() {
        return ChapterCategory.tracks();
    }
```

- `getTracks`는 DB를 읽지 않으므로 `@Transactional`을 붙이지 않는다 (`InterviewStackQueryService.getStackGroups`와 같다)

### 4. Facade - `ChapterFacade`

필요하다. 진행률 계산이 `learning` 도메인의 `LearningProgressRateService`라 챕터 Service와 결합해야 한다 (기존 `getAllChapter`와 같은 이유).

```java
    public List<ChapterDetailResponse> getCsChapters(long userId) {
        return getChaptersWithProgress(userId, CS);
    }

    public List<ChapterDetailResponse> getTrackChapters(
            long userId,
            ChapterCategory track
    ) {
        track.validateTrack();

        return getChaptersWithProgress(userId, track);
    }

    private List<ChapterDetailResponse> getChaptersWithProgress(
            long userId,
            ChapterCategory category
    ) {
        List<ChapterSummaryResponse> chapters = chapterQueryService.getChaptersByCategory(category);

        List<ChapterProgressRowDto> progressRows = chapterQueryService.getChapterProgressByCategory(userId, category);

        return toChapterDetailResponses(chapters, progressRows);
    }

    private List<ChapterDetailResponse> toChapterDetailResponses(
            List<ChapterSummaryResponse> chapters,
            List<ChapterProgressRowDto> progressRows
    ) {
        Map<Long, Double> chapterIdToProgressRate = progressRows.stream()
                .collect(Collectors.toMap(
                        ChapterProgressRowDto::chapterId,
                        row -> learningProgressRateService.calculateProgressRate(row.solvedLessons(), row.totalLessons())
                ));

        return chapters.stream()
                .map(chapter -> ChapterDetailResponse.create(
                        chapter,
                        chapterIdToProgressRate.getOrDefault(chapter.chapterId(), NOT_STARTED_PROGRESS_RATE)
                )).toList();
    }
```

- `getAllChapter`도 본문의 Map 조립, 응답 매핑을 `toChapterDetailResponses` 호출로 바꾼다. 쿼리와 결과는 그대로라 응답 계약은 변하지 않는다
- 메서드 배치: `getAllChapter` → `toChapterDetailResponses` → `getCsChapters` → `getTrackChapters` → `getChaptersWithProgress` (`common.md` 메서드 배치 순서)
- 신규 메서드에는 `@Transactional`을 붙이지 않는다. 엔티티를 경계 밖으로 넘기지 않고(프로젝션만 받음), 격리 수준 지정도 없어 `facade.md`의 경계 유지 근거에 해당하지 않는다. 기존 `getAllChapter`의 `@Transactional(readOnly = true)`는 이번 범위에서 손대지 않는다
- 직군 검증은 쿼리 전에 한다. CS 요청이면 조회 없이 `CHAPTER_TRACK_INVALID`

### 5. DTO

- 직군 옵션은 별도 Response record 없이 `List<ChapterCategory>`를 그대로 내려준다. JSON은 `["COMMON", "SERVER", "WEB", "AOS", "IOS", "LANGUAGE"]`
- CS, 직군별 챕터 목록은 기존 `ChapterDetailResponse`(`chapterSummaryResponse`, `chapterProgressRate`)를 그대로 쓴다. 안드로이드 응답과 모양이 같아 웹이 같은 파서를 쓸 수 있다

#### `CustomErrorCode`

`// Chapter` 그룹에 추가한다.

```java
    CHAPTER_TRACK_INVALID(BAD_REQUEST, "CHAPTER_4001", "직군 분류만 조회할 수 있습니다."),
```

### 6. Controller - `ChapterController`

`ChapterQueryService`를 추가 주입한다 (직군 옵션 조회는 단일 Service 위임). 주입 순서는 Facade → Service.

| HTTP | 경로 | 메서드 | 위임 |
|---|---|---|---|
| GET | `/api/v1/chapters` | `getAllChapter` (기존, 변경 없음) | `chapterFacade.getAllChapter` |
| GET | `/api/v1/chapters/cs` | `getCsChapters(@AuthenticationPrincipal LoginUser loginUser)` | `chapterFacade.getCsChapters` |
| GET | `/api/v1/chapters/tracks` | `getTracks(@AuthenticationPrincipal LoginUser loginUser)` → `ResponseEntity<List<ChapterCategory>>` | `chapterQueryService.getTracks` |
| GET | `/api/v1/chapters/tracks/{track}` | `getTrackChapters(@AuthenticationPrincipal LoginUser loginUser, @PathVariable ChapterCategory track)` | `chapterFacade.getTrackChapters` |

- 응답은 모두 `ResponseEntity.status(OK).body(...)`
- `getTracks`의 `loginUser`는 쓰지 않지만 `InterviewStackGroupController.getStackGroups`와 같이 인증 필요 API임을 시그니처로 드러낸다
- 경로 변수는 enum 상수명 그대로(`SERVER`, `IOS`) 받는다. 대소문자 변환은 하지 않는다

#### `ChapterControllerDocs`

`write-api-docs` 규칙으로 3개를 추가한다.
- CS 챕터 조회: 200, 500
- 직군 옵션 조회: 200 (예시: `["COMMON", "SERVER", "WEB", "AOS", "IOS", "LANGUAGE"]`), 500
- 직군별 챕터 조회: 200, 400 `CHAPTER_4001`(CS 요청), 500. `@Parameter(description = "직군 분류", example = "SERVER")`

### 7. 시드 SQL

- `sql/chapter/chapter.sql`: `INSERT INTO chapter (id, title, description, category)`, 5개 모두 `'CS'`
- `sql/chapter/chapter_track.sql`: 같은 컬럼 추가, 매핑표대로. 상단 주석의 실행 전제는 그대로 둔다

### 8. 테스트 호출부 (결정 1)

`Chapter.create`를 직접 부르는 테스트 93곳(20개 파일)과 `ChapterFixture` 4개 메서드에 분류 인자를 넣는다.
- `ChapterFixture`는 기존 메서드에 `CS`를 넣고, 분류를 지정하는 `새_챕터(String title, ChapterCategory category)`를 추가한다
- 직접 호출부는 `Chapter.create("운영체제", "운영체제 기초 개념", CS)` 형태로 바꾼다. 검증 로직은 손대지 않는다

### 9. 서비스 정책 - `content.md`

추가할 규칙:
- 챕터는 분류를 하나 가진다. 분류는 CS, COMMON(직군 공통 기반), SERVER, WEB, AOS, IOS, LANGUAGE다
- 직군 옵션은 CS를 뺀 6개이고 COMMON, SERVER, WEB, AOS, IOS, LANGUAGE 순서로 분류 값 그대로 내려준다
- CS 챕터 목록과 직군별 챕터 목록은 챕터 id 순으로 보여주고, 진행률은 전체 챕터 목록과 같은 기준을 따른다
- 직군별 조회에 CS를 요청하면 거절한다
- 전체 챕터 목록(안드로이드)은 분류와 상관없이 모든 챕터를 보여준다

## 결정 필요 (Decisions needed)
- [x] 1. `Chapter.create` 시그니처 - **A 확정**: 분류를 필수 파라미터로 추가하고 테스트 97곳(Fixture 4 + 직접 호출 93) 일괄 수정
- [x] 2. 직군 옵션 형식 - **확정**: 표시명 없이 enum 상수명(`COMMON`, `SERVER` ...)만 내려준다. 순서는 COMMON, SERVER, WEB, AOS, IOS, LANGUAGE
- [x] 3. 직군별 조회에 CS를 요청했을 때 - **A 확정**: 400 `CHAPTER_4001`로 거절

## 나중에 고려할 문제
- 잘못된 경로 변수(`/tracks/FOO`, 소문자 `/tracks/server`)는 `MethodArgumentTypeMismatchException`이 `GlobalExceptionHandler`의 `Exception` 핸들러로 떨어져 500이 된다. `/interview-stack-groups/{stackGroup}`도 같다. 400 매핑은 전역 핸들러 변경이라 이번 범위 밖이다
- 어드민 챕터 목록, 수정에 분류를 노출하거나 수정할지 여부. 어드민은 담당 범위 밖이라 인계 사항이다
- 분류 컬럼 인덱스. 챕터가 22행이라 지금은 필요 없다
- 직군 옵션을 문자열 배열로 내려서, 나중에 옵션별 필드(표시명, 아이콘 등)를 붙이려면 객체 배열로 바꿔야 하고 이는 응답 계약 변경이다
- 기존 `GET /api/v1/chapters`의 순서 미보장(`ORDER BY` 없음)과 `getAllChapter`의 불필요한 `@Transactional`. 안드로이드 계약이라 이번에 건드리지 않는다

## 검증
- 배포 전 prod에서 `SELECT id, title FROM chapter ORDER BY id;`로 매핑표와 같은지 확인한다. 다르면 V50이 NOT NULL 단계에서 실패해 기동이 막힌다
- dev DB에 V50 적용 후 `SELECT category, COUNT(*) FROM chapter GROUP BY category;` → CS 5, COMMON 4, SERVER 3, WEB 3, AOS 1, IOS 1, LANGUAGE 5
- `./gradlew build` (flywayValidate 포함)
- 대상 테스트 (`write-test`로 작성)
  - `ChapterFacadeIntegrationTest`
    - CS 챕터 조회: CS 챕터만 id 순으로 진행도와 함께 반환한다, 학습 기록이 없으면 진행도 0, CS 챕터가 없으면 빈 리스트
    - 직군별 챕터 조회: 요청한 직군 챕터만 반환한다, CS 요청 시 `CHAPTER_TRACK_INVALID`
    - 전체 챕터 조회: 분류가 섞여 있어도 모든 챕터를 반환한다 (기존 시나리오 회귀)
  - `ChapterQueryServiceIntegrationTest`
    - 직군 옵션 조회: CS를 뺀 6개를 COMMON, SERVER, WEB, AOS, IOS, LANGUAGE 순서로 반환한다
    - 분류별 진행도: 다른 분류 챕터의 학습 기록은 집계에 들어가지 않는다
  - 기존 테스트 전체 통과 (시그니처 변경 회귀)

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)

- `ChapterFacade`: 메서드 배치를 `getAllChapter` → `toChapterDetailResponses` → `getCsChapters` → `getChaptersWithProgress` → `getTrackChapters`로 바꿈 - 이유: 계획서 순서는 `getChaptersWithProgress`를 처음 쓰는 `getCsChapters`와 떨어뜨려 `common.md` 메서드 배치 규칙("private 메서드는 처음 사용하는 메서드 아래, 다음 public 메서드는 앞 메서드의 private 메서드가 끝난 뒤")에 어긋난다
