# [PLAN-528] 개념노트 조회를 명시적 경로 기반으로 전환

> 이슈: #528
> 브랜치: refactor/528-cs-note-explicit-path

## 목표
유닛이 자신의 개념노트 경로를 컬럼으로 직접 들고 있게 바꿔, "챕터 내 id 순번으로 파일명을 유도"하던 위치 결합과 컨트롤러에 박힌 챕터 매핑 상수를 함께 제거한다. 조회 로직을 컨트롤러에서 서비스로 내려 Controller - Service - Repository 흐름을 맞추고, 기존 엔드포인트는 deprecated 처리한 뒤 새 경로를 연다.

## 배치 기준
- **새 JPA Repository는 만들지 않는다.** `cs_note` 테이블을 신설하지 않으므로 조회할 엔티티가 없다. 유닛 조회는 기존 `UnitRepository`가 하고, 노트 본문은 classpath 리소스라 DB 계층이 아니다. 3계층은 `CSNoteController` - `CSNoteService` - `UnitRepository`로 성립한다
- `CSNoteService`가 `unit` 도메인의 리포지토리를 주입받는 배치는 기존 관행과 같다. `AdminUnitService`가 `UnitRepository`와 `LessonRepository`를 직접 주입받는 방식을 따른다 (`service.md`: 다른 도메인 **Service** 직접 호출 금지, 리포지토리는 해당 없음)
- 노트 파일 로딩용 별도 컴포넌트(`support/`, `infrastructure/`)는 두지 않는다. `test-convention.md`가 모든 테스트를 통합 테스트로 규정하므로 목킹 대상이 필요 없고, `ClassPathResource` 두 줄을 감싸는 클래스는 층만 늘린다
- 서비스가 컨트롤러로 넘기는 값은 파일명과 본문 둘이므로 `csnote/dto/internal/CSNoteDto`로 전달한다 (`dto.md` Internal 규칙, record 중첩 없이 파일 하나에 하나)
- 응답 형식은 기존과 같은 `text/markdown` 원문을 유지한다. JSON 래핑은 채택하지 않는다

## 영향 범위

### 신규 파일
- `src/main/resources/db/migration/V43__add_unit_note_path.sql` - `unit.note_path` 컬럼 추가, 기존 행 백필, 유니크 인덱스
- `src/main/java/gravit/code/csnote/service/CSNoteService.java` - 유닛 조회와 노트 리소스 로딩
- `src/main/java/gravit/code/csnote/dto/internal/CSNoteDto.java` - 파일명과 본문 전달용
- `src/test/java/gravit/code/csnote/service/CSNoteServiceIntegrationTest.java` - 조회 성공, 실패 시나리오
- `src/test/resources/static/notes/test-chapter/unit01.md` - 테스트 전용 노트 픽스처

### 수정 파일
- `src/main/java/gravit/code/unit/domain/Unit.java` - `notePath` 필드와 4인자 `create` 오버로드 추가
- `src/main/java/gravit/code/unit/repository/UnitRepository.java` - 사용처가 사라지는 `findIdsByChapterIdOrderById` 제거
- `src/main/java/gravit/code/csnote/controller/CSNoteController.java` - 조회 로직 전부 서비스로 이전, 신규 엔드포인트 추가, 기존 엔드포인트 deprecated 위임
- `src/main/java/gravit/code/csnote/controller/docs/CSNoteControllerDocs.java` - 신규 오퍼레이션 문서 추가, 기존 오퍼레이션에 deprecated 표기
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `CS_NOTE_NOT_FOUND` 추가, 미사용 `CHAPTER_NAME_NOT_MATCHING` 제거
- `src/main/resources/sql/unit.sql` - INSERT에 `note_path` 컬럼 포함
- `src/main/resources/sql/unit_track.sql` - INSERT에 `note_path` 컬럼 포함 (현재 untracked 상태)
- `.claude/spec/service-policy/cs-note.md` - 노트를 찾는 기준과 제공 범위 갱신 (정책 변경)

## 구현 계획

### 1. Entity / Flyway

`V43__add_unit_note_path.sql`

```sql
-- V43__add_unit_note_path.sql

-- 유닛이 자신의 개념노트 경로를 직접 참조하도록 컬럼을 추가한다.
-- 기존에는 "챕터 내 id 순번"으로 파일명을 유도해, 챕터 중간에 유닛이 추가되거나 삭제되면
-- 그 뒤 유닛 전체가 다른 노트를 응답하는 문제가 있었다.
ALTER TABLE unit
    ADD COLUMN IF NOT EXISTS note_path VARCHAR(255);

-- 기존 행 백필. 현재 동작(챕터 디렉터리 + 챕터 내 id 순번)을 그대로 재현한다.
-- 챕터 제목으로 조인해, 컨트롤러 상수가 쓰던 매핑과 동일한 결과를 보장한다.
UPDATE unit u
SET note_path = d.directory || '/unit' || LPAD(o.order_in_chapter::text, 2, '0')
FROM (SELECT id,
             chapter_id,
             ROW_NUMBER() OVER (PARTITION BY chapter_id ORDER BY id) AS order_in_chapter
      FROM unit) o,
     (VALUES ('자료구조', 'data-structure'),
             ('알고리즘', 'algorithm'),
             ('네트워크', 'network'),
             ('데이터베이스', 'database'),
             ('운영체제', 'operating-system'),
             ('Common · Server', 'common-server'),
             ('Common · Web', 'common-web'),
             ('Common · AOS', 'common-aos'),
             ('Common · iOS', 'common-ios'),
             ('BE · Spring', 'be-spring'),
             ('BE · Node.js', 'be-nodejs'),
             ('BE · Django', 'be-django'),
             ('FE · React', 'fe-react'),
             ('FE · Vue.js', 'fe-vue'),
             ('FE · Next.js', 'fe-nextjs'),
             ('Mobile · Android', 'mobile-android'),
             ('Mobile · iOS', 'mobile-ios'),
             ('Language · Java', 'lang-java'),
             ('Language · Kotlin', 'lang-kotlin'),
             ('Language · TypeScript', 'lang-typescript'),
             ('Language · Python', 'lang-python'),
             ('Language · Swift', 'lang-swift')) AS d(title, directory),
     chapter c
WHERE u.id = o.id
  AND c.id = o.chapter_id
  AND c.title = d.title;

-- 백필이 한 행이라도 비면 배포를 멈춘다.
-- 조용히 NULL로 남으면 해당 유닛이 운영에서 404로만 드러나 원인 추적이 어렵다.
DO
$$
    DECLARE
        missing INT;
    BEGIN
        SELECT count(*) INTO missing FROM unit WHERE note_path IS NULL;
        IF missing > 0 THEN
            RAISE EXCEPTION '노트 경로가 지정되지 않은 유닛이 % 건 남아 있습니다.', missing;
        END IF;
    END
$$;

-- 한 노트를 두 유닛이 가리키는 실수를 DB가 막는다.
CREATE UNIQUE INDEX IF NOT EXISTS ix_unit_note_path
    ON unit (note_path)
    WHERE note_path IS NOT NULL;
```

`Unit.java`

```java
@Column(name = "note_path")
private String notePath;
```

- `@Builder` 생성자에 `notePath` 파라미터를 추가한다
- 기존 `create(String title, String description, long chapterId)`는 시그니처를 바꾸지 않는다. 테스트 60여 곳이 호출하고 있고, 노트가 없는 유닛도 정상이므로 `notePath`는 null로 위임한다
- 4인자 오버로드를 추가한다: `public static Unit create(String title, String description, long chapterId, String notePath)`

### 2. Repository

`UnitRepository` - 조회는 기존 `findById(long unitId)`를 그대로 쓰고, 메서드 하나를 제거한다.

- `notePath`만 뽑는 프로젝션(`findNotePathById`)은 만들지 않는다. `Optional.empty()`가 "유닛 없음"과 "노트 경로 없음" 둘 다를 뜻하게 되어 `UNIT_NOT_FOUND`와 `CS_NOTE_NOT_FOUND`를 구분할 수 없다
- `findIdsByChapterIdOrderById`를 제거한다. 코드베이스 전체에서 호출부가 `CSNoteController:76` 하나뿐이고, 그 호출이 이 작업으로 사라진다

### 3. Service

`CSNoteService.java` (신규)

```java
@Service
@RequiredArgsConstructor
public class CSNoteService {

    private final UnitRepository unitRepository;

    private static final String BASE_PATH = "static/notes";
    private static final String EXTENSION = ".md";

    @Transactional(readOnly = true)
    public CSNoteDto getNoteByUnitId(long unitId) { ... }
}
```

로직 순서:
1. `unitRepository.findById(unitId)`로 유닛을 찾고, 없으면 `RestApiException(UNIT_NOT_FOUND)`
2. `unit.getNotePath()`가 null이면 `RestApiException(CS_NOTE_NOT_FOUND)`
3. `new ClassPathResource(BASE_PATH + "/" + notePath + EXTENSION)`을 만들고 `exists()`가 false면 `RestApiException(CS_NOTE_NOT_FOUND)`
4. `CSNoteDto.of(unit.getTitle() + EXTENSION, resource)` 반환

기존 컨트롤러의 `try { ... } catch (Exception e) { 500 }` 블록은 옮기지 않는다. 예외 변환은 `GlobalExceptionHandler`가 담당하고, 감싸면 원인이 로그에서 사라진다.

### 4. Facade

불필요 - 단일 Service. `ChapterRepository` 의존이 사라지면서 결합 대상 도메인이 `unit` 하나로 줄어든다.

### 5. DTO

`csnote/dto/internal/CSNoteDto.java`

```java
public record CSNoteDto(
        String fileName,
        Resource content
) {
    public static CSNoteDto of(
            String fileName,
            Resource content
    ) {
        return new CSNoteDto(fileName, content);
    }
}
```

Request, Response DTO는 추가하지 않는다. 응답 본문이 마크다운 원문이라 `ResponseEntity<Resource>`를 유지한다.

### 6. Controller

`CSNoteController.java`

- 주입을 `CSNoteService` 하나로 바꾼다. `UnitRepository`, `ChapterRepository` 주입을 제거한다
- `chapterMap` 상수, `calculateOrderInChapter`, `makeUnitKey`, `BASE_PATH`, `UNIT_PREFIX`를 모두 제거한다

| 메서드 | 엔드포인트 | 비고 |
|---|---|---|
| `getNoteByUnitId` | `GET /api/v1/cs-notes/units/{unitId}` | 신규 |
| `getNote` | `GET /api/v1/cs-notes/{unitId}` | `@Deprecated(forRemoval = true)`, 신규 메서드에 위임 |

두 엔드포인트는 동일하게 동작한다. deprecated는 "동작이 다르다"가 아니라 "이 경로는 제거 예정"을 뜻한다. 기존 경로도 같은 서비스를 타므로 순번 계산 결함이 함께 해소된다.

응답 헤더는 `Content-Type: text/markdown`, `Content-Disposition: inline; filename={유닛 제목}.md`로 만든다. 현재는 `filename(unit + ".md")`로 엔티티 `toString()`이 그대로 내려가고 있어 함께 바로잡는다.

`CSNoteControllerDocs.java`

- 신규 오퍼레이션 문서를 추가한다. 응답 예시는 기존과 같은 `text/markdown`
- 기존 오퍼레이션에 `@Operation(deprecated = true)`를 붙이고 description에 대체 경로를 명시한다
- 404 예시에서 `CHAPTER_NOT_FOUND`를 빼고 `CS_NOTE_NOT_FOUND`를 넣는다. 챕터 매핑이 사라져 이 경로로는 챕터 예외가 발생하지 않는다

`CustomErrorCode.java` - `// CS-NOTE` 그룹

```java
CS_NOTE_NOT_FOUND(HttpStatus.NOT_FOUND, "CS_NOTE_4041", "개념 노트를 찾을 수 없습니다."),
```

`CHAPTER_NAME_NOT_MATCHING`은 코드베이스 전체에서 참조가 없다(정의부만 존재). 이 작업으로 되살아날 일도 없으므로 제거한다.

### 7. 시드 SQL

`unit.sql`, `unit_track.sql`의 INSERT에 `note_path`를 포함한다.

V43이 이미 적용된 환경에 유닛을 새로 시드하면 마이그레이션이 다시 돌지 않아 `note_path`가 NULL로 들어간다. 시드 파일 자체가 값을 갖고 있어야 신규 환경과 기존 환경의 결과가 같아진다.

## 결정 필요 (Decisions needed)
- [x] 노트 경로 저장 위치 - `unit.note_path` 컬럼 / 별도 `cs_note` 매핑 테이블 → **컬럼**
- [x] 새 API 응답 형식 - raw markdown 유지 / JSON 래핑 → **raw markdown 유지, 새 엔드포인트는 별도로 신설**
- [x] 새 엔드포인트 경로 - `/api/v1/cs-notes/units/{unitId}` / `/api/v2/cs-notes/{unitId}` → **v1 하위 경로**

## 검증

**대상 테스트**: `CSNoteServiceIntegrationTest` (`@TCSpringBootTest`)

| 시나리오 | 기대 |
|---|---|
| `note_path`가 지정된 유닛 조회 | 해당 리소스 반환, 파일명이 유닛 제목 |
| 존재하지 않는 unitId | `RestApiException` / `UNIT_NOT_FOUND` |
| `note_path`가 null인 유닛 | `RestApiException` / `CS_NOTE_NOT_FOUND` |
| `note_path`는 있으나 파일이 없음 | `RestApiException` / `CS_NOTE_NOT_FOUND` |

테스트는 `src/test/resources/static/notes/test-chapter/unit01.md` 픽스처를 가리키는 유닛으로 검증한다. 서브모듈 실제 노트에 의존하면 노트 저장소의 파일이 바뀔 때 테스트가 깨지고, `ci-common.yml`이 서브모듈을 체크아웃하지 않아 CI에서 파일 자체가 없다.

**마이그레이션 검증**: 로컬 PostgreSQL에 V43 적용 후 `SELECT count(*) FROM unit WHERE note_path IS NULL`이 0인지, `note_path`가 기존 조회 결과와 같은 파일을 가리키는지 챕터별로 대조한다.

## 범위 밖 (후속 작업)
- 유닛 행이 없어 접근 불가한 노트 23개 (자료구조 2, 알고리즘 6, 네트워크 8, 데이터베이스 7) - unit 행 추가가 필요한 별건
- 챕터 행 자체가 없는 `web-security` 디렉터리 노트 13개
- 옛 챕터 4개의 DB 유닛명과 노트 제목 표기 불일치 20여 건
- `ci-common.yml`에 서브모듈 체크아웃 추가 - 이 작업의 테스트는 서브모듈에 의존하지 않으므로 필수가 아니다

## Deviation Log
- `src/main/java/gravit/code/csnote/controller/CSNoteController.java`: 응답 헤더 조립을 private `createHeaders(String fileName)`로 분리 - 이유: 엔드포인트 메서드에 서비스 위임과 응답 반환만 남겨 흐름이 드러나게 하기 위함
- `src/main/resources/db/migration/V43__add_unit_note_path.sql`: 챕터 매핑을 인라인 `VALUES` 에서 임시 테이블 `chapter_note_directory` 로 바꾸고, 백필 검증 가드가 "NULL 인 유닛 전체"가 아니라 "노트 디렉터리가 있는 챕터에 속한 유닛"만 세도록 좁혔다 - 이유: 계획서의 가드는 매핑에 없는 챕터의 유닛까지 실패로 잡아, 성능 테스트 픽스처(`perf-chapter-*`, 66행)가 있는 로컬에서 마이그레이션이 터지고 애플리케이션 기동이 막혔다. 매핑에 없는 챕터의 유닛은 노트가 없는 게 정상이므로 검사 대상이 아니다
- `src/main/java/gravit/code/csnote/controller/docs/CSNoteControllerDocs.java`: 계획에 적은 deprecated 표기와 에러코드 교체 외에, 기존 오퍼레이션 문서도 `api-docs-convention.md` 규격(✅/🚨 description, `@Parameter`, `GLOBAL_5001` 500 응답)에 맞췄다 - 이유: 기존 문서의 에러 예시가 `ErrorResponse`의 실제 필드명(`error`)이 아닌 `errorCode`로 적혀 있었고, 같은 파일 안에서 신규와 기존 오퍼레이션의 표기가 갈리면 문서가 더 혼란스러워진다
- `src/test/java/gravit/code/csnote/service/CSNoteServiceIntegrationTest.java`: `@Sql(truncate_all.sql)`을 붙였으나 이 스크립트는 `unit` 테이블을 지우지 않는다 - 이유: `test-convention.md`가 요구하는 초기화 규칙은 따르되, 테스트별로 서로 다른 `note_path`를 쓰고 저장 결과의 id로만 조회해 누적 데이터의 영향을 받지 않게 작성함
