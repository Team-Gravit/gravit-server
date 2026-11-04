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
