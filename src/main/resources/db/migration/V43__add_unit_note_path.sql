-- V43__add_unit_note_path.sql

-- 유닛이 자신의 개념노트 경로를 직접 참조하도록 컬럼을 추가한다.
-- 기존에는 "챕터 내 id 순번"으로 파일명을 유도해, 챕터 중간에 유닛이 추가되거나 삭제되면
-- 그 뒤 유닛 전체가 다른 노트를 응답하는 문제가 있었다.
-- 노트가 준비되지 않은 유닛도 정상이므로 NULL 을 허용한다.
ALTER TABLE unit
    ADD COLUMN IF NOT EXISTS note_path VARCHAR(255);

-- 챕터 제목과 노트 디렉터리의 대응. 백필과 검증에서 함께 쓰고 마이그레이션 끝에 버린다.
-- 제거될 컨트롤러 상수가 쓰던 매핑과 같은 내용이다.
CREATE TEMP TABLE chapter_note_directory
(
    title     VARCHAR(255) PRIMARY KEY,
    directory VARCHAR(64) NOT NULL
);

INSERT INTO chapter_note_directory (title, directory)
VALUES ('자료구조', 'data-structure'),
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
       ('Language · Swift', 'lang-swift');

-- 기존 행 백필. 현재 동작(챕터 디렉터리 + 챕터 내 id 순번)을 그대로 재현한다.
UPDATE unit u
SET note_path = d.directory || '/unit' || LPAD(o.order_in_chapter::text, 2, '0')
FROM (SELECT id,
             chapter_id,
             ROW_NUMBER() OVER (PARTITION BY chapter_id ORDER BY id) AS order_in_chapter
      FROM unit) o
         JOIN chapter c ON c.id = o.chapter_id
         JOIN chapter_note_directory d ON d.title = c.title
WHERE u.id = o.id;

-- 노트 디렉터리가 있는 챕터인데도 백필이 비면 배포를 멈춘다.
-- 조용히 NULL 로 남으면 해당 유닛이 운영에서 404 로만 드러나 원인 추적이 어렵다.
-- 매핑에 없는 챕터(성능 테스트 픽스처 등)의 유닛은 노트가 없는 게 정상이므로 검사 대상이 아니다.
DO
$$
    DECLARE
        missing INT;
    BEGIN
        SELECT count(*)
        INTO missing
        FROM unit u
                 JOIN chapter c ON c.id = u.chapter_id
                 JOIN chapter_note_directory d ON d.title = c.title
        WHERE u.note_path IS NULL;

        IF missing > 0 THEN
            RAISE EXCEPTION '노트 디렉터리가 있는 챕터인데 노트 경로가 지정되지 않은 유닛이 % 건 남아 있습니다.', missing;
        END IF;
    END
$$;

DROP TABLE chapter_note_directory;

-- 한 노트를 두 유닛이 가리키는 실수를 DB 가 막는다.
CREATE UNIQUE INDEX IF NOT EXISTS ix_unit_note_path
    ON unit (note_path)
    WHERE note_path IS NOT NULL;
