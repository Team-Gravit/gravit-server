-- PERF-492 시드
-- 대상: GET /api/v1/bookmarks/{unitId}, GET /api/v1/wrong-answered-notes/{unitId}
--
-- chapter/unit/lesson/problem/users는 이미 목표 규모에 도달해 있어 content.sql, user.sql은 부르지 않는다.
-- (unit 66, lesson 230, problem 6900, users 1002)
-- 비어 있는 answer/option/bookmark를 review.sql로 채운다.
--
-- wrong_answered_note는 기존 155,700행이 전부 유닛 910001에 몰려 있어 대상 유닛 900002에는 0행이었다.
-- 두 번째 대상(GET /api/v1/wrong-answered-notes/{unitId})을 위해 900002에 유저당 40건을 추가하고
-- 그중 10건을 극복 처리한다. 반환 행 30건은 첫 대상(bookmark)과 같은 크기다.
-- answer/option/bookmark 블록은 NOT EXISTS 가드가 있어 재실행해도 중복이 쌓이지 않는다.

\set user_start 1001
\set user_count 1000

\set target_unit_id 900002
\set bookmarks_per_user 156
\set target_unit_bookmarks_per_user 30
\set options_per_problem 4

\set target_unit_wrong_notes_per_user 40
\set target_unit_resolved_per_user 10

\i .claude/skills/optimize-performance/template/seeds/review.sql
