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
