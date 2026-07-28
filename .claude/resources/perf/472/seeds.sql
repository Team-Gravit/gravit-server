-- PERF-472 시드 (이슈 공용)
-- 대상: GET /api/v1/my-pages/learning/weak-concepts
--       GET /api/v1/my-pages/learning/weekly-report
--       GET /api/v1/my-pages/learning/top-chapters
--
-- 실행: psql -h localhost -p 5433 -U postgres -d mydb -f $PERF_DIR/seeds.sql
-- 프로젝트 루트에서 실행한다(\i 경로가 상대 경로다).

-- 유저: id 1001~2000. k6 스크립트의 USER_ID_START / USER_COUNT와 일치시킨다.
\set user_start 1001
\set user_count 1000

-- 콘텐츠: 앱 시드(src/main/resources/sql/, chapter 5 / unit 64 / lesson 97 / problem 약 3,820) 규모에 맞춘다.
-- 챕터 5 / 유닛 65 / 레슨 130 / 문제 3,900. 유닛 65개가 weak-concepts의 GROUP BY 그룹 수 상한이다.
\set content_id_base 900000
\set chapter_count 5
\set units_per_chapter 13
\set lessons_per_unit 2
\set problems_per_lesson 30

-- lesson_submission / daily_learning_record: weekly-report, top-chapters 대상용.
-- weak-concepts 쿼리는 이 테이블을 읽지 않는다.
\set lesson_sub_per_user 300
\set distinct_lessons 100
\set recent_days 7
\set recent_count 100
\set window_days 180
\set daily_record_days 180

-- problem_submission: weak-concepts 대상. 유저당 2,000건 / 서로 다른 문제 700개 / 오답 30%.
-- 서로 다른 문제 700개는 전체 3,900개의 18%이고, 유닛당 문제 60개이므로 약 12개 유닛에 걸친다.
\set problem_sub_per_user 2000
\set distinct_problems 700
\set wrong_pct 30

\i .claude/skills/optimize-performance/template/seeds/content.sql
\i .claude/skills/optimize-performance/template/seeds/user.sql
\i .claude/skills/optimize-performance/template/seeds/learning.sql
