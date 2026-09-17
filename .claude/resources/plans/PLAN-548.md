# [PLAN-548] 유닛 조회 응답에 챕터 내 순서 제공

> 이슈: #548
> 브랜치: feat/548-unit-display-order

## 목표
유닛에 챕터 내 순서(`displayOrder`, 1부터 시작)를 저장한다. `GET /api/v1/units/{chapterId}`, `GET /api/v1/lessons/{unitId}`가 반환하는 `UnitSummaryResponse`에 이 값을 담는다. 지금은 유닛에 순서 값이 없어 클라이언트가 유닛 순번을 표시할 근거가 없고, 챕터 내 유닛 목록 조회 쿼리(`findAllUnitSummaryByChapterId`)에는 `ORDER BY`가 없어 목록 순서도 보장되지 않는다.

응답 예 (`GET /api/v1/units/1`의 요소 하나)

```json
{
  "unitSummaryResponse": {
    "unitId": 2,
    "displayOrder": 2,
    "title": "연결리스트",
    "description": "노드가 포인터로 연결된 선형 자료구조"
  },
  "progressRate": 50.0
}
```

## 배치 기준
- **기존 유닛의 순서는 챕터 안에서 id 순으로 채운다.** V43이 `note_path`를 채운 기준(`ROW_NUMBER() OVER (PARTITION BY chapter_id ORDER BY id)`)과 같다. 시드 SQL(`unit.sql` 69건, `unit_track.sql` 158건, 22개 챕터)을 대조해 보니 227건 모두 `note_path`의 `unitNN` 번호와 챕터 내 id 순번이 같았다
- **DB 제약은 NOT NULL, `CHECK (display_order > 0)`, `UNIQUE (chapter_id, display_order)`로 건다.** UNIQUE 제약이 만드는 인덱스가 `WHERE chapter_id = ? ORDER BY display_order` 조회에도 쓰인다. 지금 `unit(chapter_id)` 인덱스는 없다
- **엔티티에 UNIQUE 제약을 `@Table(uniqueConstraints)`로 함께 선언한다.** 테스트는 Flyway 없이 `ddl-auto: create`로 스키마를 만들기 때문이다. `InterviewAnswer`의 `uq_interview_answer_session_order`도 같은 방식이다. CHECK 제약은 엔티티에 선언한 선례가 없어 DB에만 둔다
- **`Unit.create`가 `displayOrder`를 필수 인자로 받는다.** 앱 코드에는 유닛을 만드는 곳이 없고(유닛은 시드 SQL로만 들어간다) 테스트만 이 팩토리를 쓴다. 같은 챕터에서 순서가 겹치면 안 되므로 기본값을 둘 수 없다. 순서를 받지 않는 기존 오버로드는 없앤다
- **`UnitSummaryResponse`의 `displayOrder`는 `unitId` 바로 뒤에 둔다.** JSON에서도 식별자 다음에 순서가 오도록 한다. 타입은 NOT NULL 컬럼이라 `int`다 (`InterviewAnswer.displayOrder`와 같다)
- **`UnitSummaryResponse`를 만드는 JPQL 3개를 모두 고친다.** 같은 생성자를 쓰므로 한 곳만 바꿀 수 없다. 그래서 요청한 두 API 외에 레슨 결과(`GET /api/v1/lessons/results/{id}`), 북마크, 오답노트, 문제 조회 응답에도 `displayOrder`가 함께 나간다. 필드만 추가하는 변경이라 기존 클라이언트는 영향을 받지 않는다
- **Service, Facade, Controller 코드는 바꾸지 않는다.** 모두 `UnitSummaryResponse`를 그대로 넘기기만 한다
- **시드 SQL에도 `display_order`를 넣는다.** 컬럼이 NOT NULL이라 넣지 않으면 새 환경에 시드를 적재할 때 실패한다. 값은 각 행의 `note_path` 번호와 같다
- **배포 순서에 따른 문제는 없다.** 앱은 유닛을 INSERT하지 않고, 이전 버전 코드는 새 컬럼을 읽지 않는다. 마이그레이션이 먼저 적용된 상태에서 이전 버전으로 롤백해도 동작한다

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V44__add_unit_display_order.sql` - 컬럼 추가, 기존 행 백필, 제약 추가

### 수정 파일
- `src/main/java/gravit/code/unit/domain/Unit.java` - `displayOrder` 필드와 UNIQUE 제약 선언, 팩토리 시그니처 변경
- `src/main/java/gravit/code/unit/dto/response/UnitSummaryResponse.java` - `displayOrder` 컴포넌트 추가, `title` 예시값 수정
- `src/main/java/gravit/code/unit/repository/UnitRepository.java` - 유닛 요약 JPQL 3개에 `u.displayOrder` 추가, 챕터 내 목록 쿼리에 정렬 추가
- `src/main/java/gravit/code/unit/controller/docs/UnitControllerDocs.java` - 목록 정렬 기준을 description에 명시
- `src/main/resources/sql/unit.sql` - INSERT에 `display_order` 추가 (69건)
- `src/main/resources/sql/unit_track.sql` - INSERT에 `display_order` 추가 (158건)
- `.claude/skills/optimize-performance/template/seeds/content.sql` - 성능 측정용 유닛 시드에 `display_order` 추가
- `.claude/spec/service-policy/content.md` - 유닛 순서 정책 추가 (정책 추가)
- 테스트 30개 파일 - `Unit.create` 호출 약 100곳과 `new UnitSummaryResponse(...)` 14곳 갱신 (목록은 "검증" 섹션)

## 구현 계획

### 1. Flyway - `V44__add_unit_display_order.sql` (신규)

```sql
-- V44__add_unit_display_order.sql

-- 유닛이 챕터 안에서 몇 번째인지 저장할 컬럼을 추가한다. 기존 행을 채우기 전이라 NULL 을 허용한다.
ALTER TABLE unit
    ADD COLUMN IF NOT EXISTS display_order INTEGER;

-- 기존 유닛은 챕터 안에서 id 순으로 순서를 매긴다.
-- V43 이 note_path 를 채운 기준과 같아, 순서와 노트 파일 번호(unitNN)가 일치한다.
UPDATE unit u
SET display_order = o.order_in_chapter
FROM (SELECT id,
             ROW_NUMBER() OVER (PARTITION BY chapter_id ORDER BY id) AS order_in_chapter
      FROM unit) o
WHERE u.id = o.id;

-- 모든 행이 채워졌으므로 NULL 을 막는다.
ALTER TABLE unit
    ALTER COLUMN display_order SET NOT NULL;

-- 순서는 1부터 시작한다.
ALTER TABLE unit
    ADD CONSTRAINT ck_unit_display_order CHECK (display_order > 0);

-- 같은 챕터 안에서 순서가 겹치지 않게 막는다. 챕터 내 유닛 목록을 순서대로 조회할 때 인덱스로도 쓰인다.
ALTER TABLE unit
    ADD CONSTRAINT uq_unit_chapter_display_order UNIQUE (chapter_id, display_order);
```

- 제약 이름은 기존 규칙(`ck_notification_type`, `uq_congratulation_user_feed`)을 따른다
- 모든 행에 `ROW_NUMBER()` 값이 들어가므로 백필 뒤 NULL이 남지 않는다. 남으면 `SET NOT NULL`이 실패해 배포가 멈춘다
- 빌드의 `flywayValidate`는 H2에서 파일명 규칙만 검사한다(`ignoreMigrationPatterns = ['*:pending']`). PostgreSQL 전용 문법을 써도 된다

### 2. Entity - `Unit`

클래스 어노테이션 (`@Getter`와 `@NoArgsConstructor` 사이에 `@Table` 추가)

```java
@Entity
@Getter
@Table(
        name = "unit",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_unit_chapter_display_order",
                columnNames = {"chapter_id", "display_order"}
        )
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Unit {
```

필드 (`chapterId` 다음, `notePath` 앞)

```java
@Column(name = "display_order", nullable = false)
private int displayOrder;
```

private 생성자와 팩토리

```java
@Builder(access = AccessLevel.PRIVATE)
private Unit(
        String title,
        String description,
        long chapterId,
        int displayOrder,
        String notePath
) {
    this.title = title;
    this.description = description;
    this.chapterId = chapterId;
    this.displayOrder = displayOrder;
    this.notePath = notePath;
}

public static Unit create(
        String title,
        String description,
        long chapterId,
        int displayOrder
) {
    return create(title, description, chapterId, displayOrder, null);
}

public static Unit create(
        String title,
        String description,
        long chapterId,
        int displayOrder,
        String notePath
) {
    return Unit.builder()
            .title(title)
            .description(description)
            .chapterId(chapterId)
            .displayOrder(displayOrder)
            .notePath(notePath)
            .build();
}
```

- 기존 `create(String, String, long)`, `create(String, String, long, String)`은 위 두 메서드로 대체한다
- import 추가: `jakarta.persistence.Table`, `jakarta.persistence.UniqueConstraint`
- `update(String title, String description)`는 바꾸지 않는다. 관리자 화면에서 순서를 바꾸는 기능은 범위 밖이다

### 3. Repository - `UnitRepository`

`findAllUnitSummaryByChapterId(long chapterId)` (27~32행) - 순서 조회와 정렬 추가

```java
@Query("""
        SELECT new gravit.code.unit.dto.response.UnitSummaryResponse(u.id, u.displayOrder, u.title, u.description)
        FROM Unit u
        WHERE u.chapterId = :chapterId
        ORDER BY u.displayOrder ASC
""")
List<UnitSummaryResponse> findAllUnitSummaryByChapterId(@Param("chapterId") long chapterId);
```

`findUnitSummaryByLessonId(long lessonId)` (34~40행), `findUnitSummaryById(long unitId)` (42~47행) - 생성자 인자에만 `u.displayOrder` 추가

```java
SELECT new gravit.code.unit.dto.response.UnitSummaryResponse(u.id, u.displayOrder, u.title, u.description)
```

- 메서드 시그니처와 나머지 쿼리는 바꾸지 않는다

### 4. Service

변경 없음. `UnitQueryService.getAllUnitSummaryByChapterId`, `getUnitSummaryByUnitId`, `getUnitSummaryByLessonId`는 리포지토리 결과를 그대로 반환한다.

### 5. Facade

변경 없음 (신규 Facade 불필요). `UnitFacade.getAllUnitInChapter`는 `unitSummaries` 순서를 유지한 채 `UnitDetailResponse`로 감싸므로(`stream().map(...).toList()`) 쿼리 정렬이 그대로 응답 순서가 된다. `LessonFacade.getAllLessonInUnit`은 `UnitSummaryResponse`를 그대로 담는다.

### 6. DTO - `UnitSummaryResponse`

```java
public record UnitSummaryResponse(

        @Schema(
                description = "유닛 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long unitId,

        @Schema(
                description = "챕터 안에서의 유닛 순서 (1부터 시작)",
                example = "2",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "유닛명",
                example = "연결리스트",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String title,

        @Schema(
                description = "유닛 설명",
                example = "배열과 연결리스트에 대해 학습합니다.",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String description
) {
}
```

- JPQL 생성자 표현식의 대상이라 팩토리 없이 표준 생성자를 그대로 쓴다 (`dto.md`)
- `title` 예시를 `"Unit01 - 연결리스트"`에서 `"연결리스트"`로 바꾼다. 실제 제목에는 순번이 없고(시드: `'연결리스트'`), 이제 순번은 `displayOrder`로 내려간다

### 7. Controller

`GET /api/v1/units/{chapterId} → UnitController.getAllUnitInChapter`, `GET /api/v1/lessons/{unitId} → LessonController.getAllLessonInUnit` - 컨트롤러 코드는 변경 없음.

`UnitControllerDocs.getAllUnitInChapter`의 `@Operation` description

```java
@Operation(summary = "유닛 조회", description = "유저의 유닛 진행도를 포함한 유닛 목록을 조회합니다.<br>" +
        "유닛 목록은 챕터 내 순서(<strong>displayOrder</strong>) 오름차순입니다.<br>" +
        "🔐 <strong>Jwt 필요</strong><br>")
```

- `@ApiResponses`는 바꾸지 않는다
- `LessonControllerDocs`는 응답 필드 설명을 `UnitSummaryResponse`의 `@Schema`에 맡기므로 바꾸지 않는다

### 8. 시드 SQL

`src/main/resources/sql/unit.sql`, `unit_track.sql`

- 컬럼 목록 `(id, chapter_id, title, description, note_path)`를 `(id, chapter_id, title, description, note_path, display_order)`로 바꾼다 (`unit.sql` 5곳, `unit_track.sql` 17곳)
- 각 VALUES 행 끝에 `note_path`의 `unitNN` 번호를 정수로 붙인다

```sql
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (1, 1, '배열', '연속된 메모리 공간에 데이터를 저장하는 선형 자료구조', 'data-structure/unit01', 1),
       (2, 1, '연결리스트', '노드가 포인터로 연결된 선형 자료구조', 'data-structure/unit02', 2),
```

- 227행을 손으로 고치지 않고 스크립트로 변환한다. 변환 뒤 챕터마다 순서가 1부터 빈틈 없이 이어지는지 다시 대조한다
- 순서를 `note_path` 옆 마지막 열에 두어 두 값이 맞는지 눈으로 바로 확인할 수 있게 한다

`.claude/skills/optimize-performance/template/seeds/content.sql` (21~28행)

```sql
-- unit: 챕터당 :units_per_chapter 건
INSERT INTO unit (id, chapter_id, title, description, display_order)
SELECT :content_id_base + u,
       :content_id_base + ((u - 1) / :units_per_chapter + 1),
       'perf-unit-' || u,
       'perf unit ' || u,
       (u - 1) % :units_per_chapter + 1
FROM generate_series(1, :chapter_count * :units_per_chapter) AS u
ON CONFLICT DO NOTHING;
```

- `.claude/resources/perf/475/seeds.sql`은 과거 측정 기록이라 고치지 않는다

### 9. 서비스 정책 - `.claude/spec/service-policy/content.md`

9행(학습 단위 중첩) 바로 아래에 추가

- `유닛은 챕터 안에서 1부터 시작하는 순서를 가진다. 같은 챕터 안에서 순서는 겹치지 않는다`
- `챕터의 유닛 목록은 이 순서대로 보여준다`

## 결정 필요 (Decisions needed)
- [x] 챕터 내 유닛 목록 정렬 - 포함 / 제외 → **포함** (`ORDER BY u.displayOrder ASC`)
- [x] DB 제약 - NOT NULL, CHECK, UNIQUE / NOT NULL, CHECK만 → **NOT NULL + `CHECK (display_order > 0)` + `UNIQUE (chapter_id, display_order)`**
- [x] 기존 데이터 순서 기준 → **챕터 안에서 id 순** (V43과 같은 기준, 시드 227건이 `note_path` 번호와 모두 일치)

## 검증

### 마이그레이션 (테스트는 Flyway를 쓰지 않으므로 따로 확인한다)

배포 전 운영 DB에서 id 순서와 노트 번호가 어긋난 유닛이 없는지 확인한다. 기대값은 0행이다.

```sql
SELECT id, chapter_id, note_path, order_in_chapter
FROM (SELECT id, chapter_id, note_path, ROW_NUMBER() OVER (PARTITION BY chapter_id ORDER BY id) AS order_in_chapter FROM unit) t
WHERE note_path IS NOT NULL AND substring(note_path FROM 'unit(\d+)$')::int <> order_in_chapter;
```

로컬 PostgreSQL에 `./gradlew bootRun`으로 V44를 적용한 뒤 확인한다.

- `SELECT count(*) FROM unit WHERE display_order IS NULL;` → 0
- `SELECT chapter_id, count(*), min(display_order), max(display_order) FROM unit GROUP BY chapter_id;` → 챕터마다 `min` 1, `max` = `count`
- `SELECT conname FROM pg_constraint WHERE conrelid = 'unit'::regclass;` → `ck_unit_display_order`, `uq_unit_chapter_display_order` 포함
- `./gradlew flywayValidate` 통과

### 대상 테스트 (`@TCSpringBootTest`)

`UnitQueryServiceIntegrationTest` > `GetAllUnitSummaryResponseByChapterId`

| 시나리오 | 기대 |
|---|---|
| 순서 1 `프로세스`, 순서 2 `스레드` 저장 (기존 `성공한다`) | 2건, 순서대로 `displayOrder` 1, 2까지 단언 |
| 순서 2 `스레드`를 먼저 저장하고 순서 1 `프로세스`를 나중에 저장 (신규) | id 순서와 반대로 `프로세스`(1), `스레드`(2) 순서로 반환 |
| 유닛 없음 (기존) | 빈 리스트 |

`UnitQueryServiceIntegrationTest` > `GetUnitSummaryByUnitIdResponse`, `GetUnitSummaryResponseByLessonId`

- 성공 시나리오에 `displayOrder`가 저장한 값과 같은지 단언을 추가한다

`UnitFacadeIntegrationTest` > `GetAllUnitInChapter`

- 순서를 id 역순으로 저장했을 때 `unitDetailResponses`가 `displayOrder` 오름차순이고, 각 요소의 `progressRate`가 자기 유닛 것인지 단언한다

`LessonFacadeIntegrationTest` > `GetAllLessonInUnit`

- `unitSummaryResponse().displayOrder()`가 저장한 값과 같은지 단언을 추가한다

### 컴파일을 위한 기존 테스트 갱신

팩토리 시그니처와 레코드 생성자가 바뀌어 아래 파일은 갱신 전까지 컴파일되지 않는다.

- `Unit.create(...)`에 순서 인자를 넣는다. 한 테스트 안에서 같은 챕터에 저장하는 유닛은 저장 순서대로 1, 2, 3을 준다. 반복문은 1부터 도는 루프 변수를 쓴다. 챕터가 다르면 각각 1부터 준다
- `UnitFixture.새_유닛(String title, long chapterId)` → `새_유닛(String title, long chapterId, int displayOrder)`. 호출하는 곳이 없는 `기본_유닛`, `저장된_유닛`은 순서 1로 만든다
- `new UnitSummaryResponse(id, title, description)` → `new UnitSummaryResponse(id, displayOrder, title, description)`

| 파일 (`src/test/java/gravit/code/` 기준) | `Unit.create`, `새_유닛` | `new UnitSummaryResponse` |
|---|---|---|
| `unit/fixture/UnitFixture.java` | 4 | - |
| `unit/service/UnitQueryServiceIntegrationTest.java` | 10 | - |
| `unit/facade/UnitFacadeIntegrationTest.java` | 2 | - |
| `unit/service/UnitQueryServiceUnitTest.java` | - | 4 |
| `unit/facade/UnitFacadeUnitTest.java` | - | 2 |
| `admin/service/AdminChapterServiceIntegrationTest.java` | 6 | - |
| `admin/service/AdminUnitServiceIntegrationTest.java` | 3 | - |
| `bookmark/facade/BookmarkFacadeIntegrationTest.java` | 2 | - |
| `bookmark/facade/BookmarkFacadeUnitTest.java` | - | 2 |
| `bookmark/service/BookmarkServiceIntegrationTest.java` | 1 | - |
| `chapter/facade/ChapterFacadeIntegrationTest.java` | 1 | - |
| `chapter/service/ChapterQueryServiceIntegrationTest.java` | 1 | - |
| `csnote/service/CSNoteServiceIntegrationTest.java` | 3 | - |
| `learning/facade/LearningFacadeIntegrationTest.java` | 4 | - |
| `learning/service/LearningProgressRateServiceIntegrationTest.java` | 7 | - |
| `lesson/facade/LessonFacadeIntegrationTest.java` | 4 | - |
| `lesson/facade/LessonFacadeUnitTest.java` | - | 2 |
| `lesson/service/LessonQueryServiceIntegrationTest.java` | 5 | - |
| `lesson/service/LessonSubmissionCommandServiceIntegrationTest.java` | 2 | - |
| `lesson/service/LessonSubmissionQueryServiceIntegrationTest.java` | 21 | - |
| `problem/facade/ProblemFacadeIntegrationTest.java` | 5 | - |
| `problem/facade/ProblemFacadeUnitTest.java` | - | 2 |
| `problem/service/ProblemQueryServiceIntegrationTest.java` | 4 | - |
| `problem/service/ProblemSubmissionCommandServiceIntegrationTest.java` | 1 | - |
| `problem/service/ProblemSubmissionQueryServiceIntegrationTest.java` | 10 | - |
| `report/service/ReportServiceIntegrationTest.java` | 2 | - |
| `user/facade/UserFacadeIntegrationTest.java` | 6 | - |
| `wrongAnsweredNote/facade/WrongAnsweredNoteFacadeIntegrationTest.java` | 2 | - |
| `wrongAnsweredNote/facade/WrongAnsweredNoteFacadeUnitTest.java` | - | 2 |
| `wrongAnsweredNote/service/WrongAnsweredNoteServiceIntegrationTest.java` | 1 | - |

- 개수는 grep 기준이라 줄바꿈된 호출은 빠졌을 수 있다. 실제 대상은 `compileTestJava` 오류로 확정한다
- 테스트 코드 갱신은 `implement` 범위 밖이므로 `write-test`에서 이 섹션대로 진행한다
- `./gradlew test`로 전체 통과를 확인한다

## 나중에 고려할 문제
- 메인페이지 학습 현황(`LearningFacade:45`)과 폐기 예정 메인페이지(`UserFacade:115`)의 유닛 목록은 `findUnitProgressByChapterIdAndUserId`의 `ORDER BY u.id`를 따른다. 지금은 순서가 id 순과 같아 결과가 같지만, 챕터 중간에 유닛이 끼어들면 유닛 페이지와 순서가 달라진다
- 관리자 유닛 목록(`AdminChapterService:97`, `Pageable` 정렬)과 관리자 통계(`AdminStatsRepository`의 `ORDER BY u.id`)는 순서를 쓰지 않는다. 관리자 응답에 순서를 노출하거나 순서를 바꾸는 기능도 없다
- 순서를 바꾸는 기능이 생기면 두 유닛의 순서를 맞바꿀 때 `uq_unit_chapter_display_order`에 걸린다. 그때 제약을 `DEFERRABLE`로 바꾸거나 임시 값을 거쳐 옮기는 방식을 정한다
- 새 유닛을 시드 SQL로 추가할 때 `display_order`와 `note_path` 번호를 맞추는 것은 사람이 챙겨야 한다. DB는 두 값의 일치를 검사하지 않는다

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
- 테스트 30개 파일 ("검증 - 컴파일을 위한 기존 테스트 갱신" 표): 구현 단계에서 수정하지 않음 — 이유: 테스트 코드 작성은 implement 범위 밖이라 `write-test`에서 검증 섹션대로 갱신. 그 전까지 `compileTestJava`가 실패함. 오류는 `Unit.create(String, String, long)`, `Unit.create(String, String, long, String)` 호출과 3인자 `new UnitSummaryResponse(...)` 두 종류뿐이며, javac가 오류 100개에서 출력을 멈춰 실제 개수는 그보다 많을 수 있음. `ProblemSubmissionQueryServiceIntegrationTest`는 `UnitFixture.새_유닛` 시그니처를 바꾼 뒤에 오류가 드러남
