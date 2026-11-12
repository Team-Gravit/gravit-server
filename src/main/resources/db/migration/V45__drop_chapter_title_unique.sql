-- V45__drop_chapter_title_unique.sql

-- 챕터 이름에서 분류 접두어를 지우면 서로 다른 챕터의 제목이 같아진다(Common 분류와 Mobile 분류의 iOS 챕터).
-- 챕터는 id로 식별하고 제목으로 조회하거나 중복을 검사하는 코드가 없으므로 제목 유일성 제약을 제거한다.
-- 제약 이름은 V1의 인라인 UNIQUE에 PostgreSQL이 붙인 기본 이름이다.
ALTER TABLE chapter
    DROP CONSTRAINT IF EXISTS chapter_title_key;
