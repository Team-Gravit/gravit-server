-- PERF-492 시드
-- 대상: GET /api/v1/bookmarks/{unitId}, GET /api/v1/wrong-answered-notes/{unitId}
--
-- chapter/unit/lesson/problem/users는 이미 목표 규모에 도달해 있어 content.sql, user.sql은 부르지 않는다.
-- (unit 66, lesson 230, problem 6900, users 1002)
-- 비어 있는 answer/option/bookmark만 review.sql로 채운다.

\set user_start 1001
\set user_count 1000

\set target_unit_id 900002
\set bookmarks_per_user 156
\set target_unit_bookmarks_per_user 30
\set options_per_problem 4

\i .claude/skills/optimize-performance/template/seeds/review.sql
