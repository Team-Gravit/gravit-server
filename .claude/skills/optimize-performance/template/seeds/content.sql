-- 학습 콘텐츠 시드: chapter → unit → lesson → problem
--
-- 필요한 변수: content_id_base, chapter_count, units_per_chapter, lessons_per_unit, problems_per_lesson
--
-- 값은 실제 학습 데이터처럼 보일 필요가 없다. FK 관계와 개수만 맞춘다.
-- id는 content_id_base 위에 쌓아 앱 시드(src/main/resources/sql/)와 겹치지 않게 한다.
-- content_id_base를 바꿔 재실행하면 같은 데이터가 다른 id로 한 벌 더 쌓인다. 바꾸려면 기존 것을 지우고 하라.

\echo '[content.sql] chapter/unit/lesson/problem 적재'

BEGIN;

-- chapter: :chapter_count 건
INSERT INTO chapter (id, title, description)
SELECT :content_id_base + c,
       'perf-chapter-' || c,
       'perf chapter ' || c
FROM generate_series(1, :chapter_count) AS c
ON CONFLICT DO NOTHING;

-- unit: 챕터당 :units_per_chapter 건
INSERT INTO unit (id, chapter_id, title, description)
SELECT :content_id_base + u,
       :content_id_base + ((u - 1) / :units_per_chapter + 1),
       'perf-unit-' || u,
       'perf unit ' || u
FROM generate_series(1, :chapter_count * :units_per_chapter) AS u
ON CONFLICT DO NOTHING;

-- lesson: 유닛당 :lessons_per_unit 건
INSERT INTO lesson (id, unit_id, title)
SELECT :content_id_base + l,
       :content_id_base + ((l - 1) / :lessons_per_unit + 1),
       'perf-lesson-' || l
FROM generate_series(1, :chapter_count * :units_per_chapter * :lessons_per_unit) AS l
ON CONFLICT DO NOTHING;

-- problem: 레슨당 :problems_per_lesson 건 (짝수 번째는 주관식)
INSERT INTO problem (id, lesson_id, content, instruction, problem_type)
SELECT :content_id_base + p,
       :content_id_base + ((p - 1) / :problems_per_lesson + 1),
       'perf problem content ' || p,
       'perf instruction ' || p,
       CASE WHEN p % 2 = 0 THEN 'SUBJECTIVE' ELSE 'OBJECTIVE' END
FROM generate_series(1, :chapter_count * :units_per_chapter * :lessons_per_unit * :problems_per_lesson) AS p
ON CONFLICT DO NOTHING;

-- 시퀀스 보정 (id를 명시 삽입했으므로 필수)
SELECT setval(pg_get_serial_sequence('chapter', 'id'), (SELECT COALESCE(max(id), 1) FROM chapter));
SELECT setval(pg_get_serial_sequence('unit', 'id'), (SELECT COALESCE(max(id), 1) FROM unit));
SELECT setval(pg_get_serial_sequence('lesson', 'id'), (SELECT COALESCE(max(id), 1) FROM lesson));
SELECT setval(pg_get_serial_sequence('problem', 'id'), (SELECT COALESCE(max(id), 1) FROM problem));

COMMIT;

ANALYZE chapter;
ANALYZE unit;
ANALYZE lesson;
ANALYZE problem;

-- 검증
SELECT 'chapter' AS table_name, count(*) AS rows, NULL::bigint AS distinct_parent FROM chapter
UNION ALL
SELECT 'unit', count(*), count(DISTINCT chapter_id) FROM unit
UNION ALL
SELECT 'lesson', count(*), count(DISTINCT unit_id) FROM lesson
UNION ALL
SELECT 'problem', count(*), count(DISTINCT lesson_id) FROM problem;
