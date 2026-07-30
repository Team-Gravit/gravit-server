-- PERF-475 시드 (이슈 공용)
-- 대상: POST /api/v1/lessons/results
--
-- 실행: PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d mydb -f $PERF_DIR/seeds.sql
-- 프로젝트 루트에서 실행한다(\i 경로가 상대 경로다).
--
-- 이 파일은 재실행 가능하다. 매 측정 직전에 다시 돌려 시작 상태를 맞춘다.
-- 맨 앞의 되돌리기 블록이 직전 부하 테스트가 삽입한 행을 지운다.

-- ---------------------------------------------------------------------------
-- 변수
-- ---------------------------------------------------------------------------

-- 유저: id 1001~2000. k6 스크립트의 USER_ID_START / USER_COUNT와 일치시킨다.
\set user_start 1001
\set user_count 1000

-- 콘텐츠(PERF-472와 동일). 챕터 5 / 유닛 65 / 레슨 130 / 문제 3,900.
\set content_id_base 900000
\set chapter_count 5
\set units_per_chapter 13
\set lessons_per_unit 2
\set problems_per_lesson 30

-- 학습 이력(PERF-472와 동일). 쿼리 12(countDistinctLessonByUserId)가 읽는 규모다.
\set lesson_sub_per_user 300
\set distinct_lessons 100
\set recent_days 7
\set recent_count 100
\set window_days 180
\set daily_record_days 180
\set problem_sub_per_user 2000
\set distinct_problems 700
\set wrong_pct 30

-- 리그: 티어 5 / ACTIVE 시즌 1 + CLOSED 3.
\set league_tier_count 5
\set past_season_count 3

-- 첫 풀이 전용 콘텐츠. 아무 유저도 제출 이력이 없으므로
-- (전 유저 × first_try_lesson_count) 조합이 전부 isFirstTry = true 다.
-- id를 900000대와 분리해 되돌리기를 `>= first_try_id_base` 하나로 끝낸다.
-- 조합은 소모품이다. 요청 1건이 (유저, 레슨) 조합 1개를 쓴다.
-- 1,000유저 × 100레슨 = 100,000건이 상한이며, 이를 넘으면 이후 요청은 재풀이가 된다.
\set first_try_id_base 910000
\set first_try_chapter_id 900001
\set first_try_lesson_count 100
\set first_try_problems_per_lesson 30

-- ---------------------------------------------------------------------------
-- 0) 되돌리기: 직전 부하 테스트가 삽입한 행을 지운다
--    첫 풀이 전용 id 대역만 지우므로 472 시드 이력(300,000건)은 건드리지 않는다.
-- ---------------------------------------------------------------------------

\echo '[reset] 첫 풀이 대역 제출 이력 삭제'

BEGIN;

DELETE FROM wrong_answered_note WHERE problem_id >= :first_try_id_base;
DELETE FROM problem_submission  WHERE problem_id >= :first_try_id_base;
DELETE FROM lesson_submission   WHERE lesson_id  >= :first_try_id_base;

-- 부하 테스트가 갱신한 카운터를 시작 상태로 되돌린다.
-- 행 수를 바꾸지 않으므로 쿼리 계획에는 영향이 없지만, isFirstTry 경로의
-- 미션 진행도와 연속 학습일이 회차마다 달라지는 것을 막는다.
UPDATE learning
SET today_solved = false,
    consecutive_solved_days = (user_id % 30),
    planet_conquest_rate = 0
WHERE user_id BETWEEN :user_start AND :user_start + :user_count - 1;

UPDATE user_mission
SET progress_count = 0,
    completed_at = NULL
WHERE user_id BETWEEN :user_start AND :user_start + :user_count - 1;

COMMIT;

-- ---------------------------------------------------------------------------
-- 1) 기존 모듈 (현재 DB에는 PERF-472가 이미 적재해 두어 no-op이다.
--    빈 DB에서도 이 파일 하나로 재현되도록 호출은 남긴다.)
-- ---------------------------------------------------------------------------

\i .claude/skills/optimize-performance/template/seeds/content.sql
\i .claude/skills/optimize-performance/template/seeds/user.sql
\i .claude/skills/optimize-performance/template/seeds/learning.sql
\i .claude/skills/optimize-performance/template/seeds/league.sql

-- ---------------------------------------------------------------------------
-- 2) learning (모듈 없음)
--    LessonFacade:103 → LearningRepository.findByUserId 가 없으면
--    LEARNING_NOT_FOUND 로 전 요청이 실패한다.
-- ---------------------------------------------------------------------------

\echo '[475] learning 적재'

INSERT INTO learning (user_id, recent_solved_chapter_id, today_solved, consecutive_solved_days, planet_conquest_rate, version)
SELECT u.id,
       :content_id_base + 1,
       false,
       (u.id % 30),
       0,
       0
FROM users u
WHERE u.id BETWEEN :user_start AND :user_start + :user_count - 1
  AND NOT EXISTS (SELECT 1 FROM learning l WHERE l.user_id = u.id);

SELECT setval(pg_get_serial_sequence('learning', 'id'), (SELECT COALESCE(max(id), 1) FROM learning));

-- ---------------------------------------------------------------------------
-- 3) user_mission (모듈 없음)
--    MissionEventListener 가 findAssignedMission 으로 오늘자 배정을 찾는다.
--    없으면 try-catch 에 걸려 매 요청 재시도 큐로 빠지므로 측정이 왜곡된다.
--    assigned_date 는 애플리케이션의 Clock(KST, TimeConfig:14)에 맞춘다.
--    자정을 넘겨 측정하는 경우를 대비해 어제/오늘/내일 3일치를 넣는다.
-- ---------------------------------------------------------------------------

\echo '[475] user_mission 적재 (KST 기준 어제/오늘/내일)'

WITH lesson_mission AS (
    SELECT id, row_number() OVER (ORDER BY id) - 1 AS rn, count(*) OVER () AS total
    FROM mission
    WHERE status = 'ACTIVE' AND target_type <> 'FOLLOW_FRIEND'
),
target_date AS (
    SELECT ((now() AT TIME ZONE 'Asia/Seoul')::date + d) AS assigned_date
    FROM generate_series(-1, 1) AS d
)
INSERT INTO user_mission (user_id, mission_id, assigned_date, progress_count, created_at, updated_at)
SELECT u.id,
       lm.id,
       td.assigned_date,
       0,
       now(),
       now()
FROM users u
CROSS JOIN target_date td
JOIN lesson_mission lm ON lm.rn = (u.id % lm.total)
WHERE u.id BETWEEN :user_start AND :user_start + :user_count - 1
ON CONFLICT (user_id, assigned_date) DO NOTHING;

SELECT setval(pg_get_serial_sequence('user_mission', 'id'), (SELECT COALESCE(max(id), 1) FROM user_mission));

-- ---------------------------------------------------------------------------
-- 4) 첫 풀이 전용 콘텐츠 (모듈 없음)
--    기존 챕터에 유닛 1개를 붙이고 레슨 :first_try_lesson_count 개,
--    레슨당 문제 :first_try_problems_per_lesson 개를 만든다.
--    lesson_submission 300,000건을 건드리지 않으므로 쿼리 12의 스캔 규모가 보존된다.
-- ---------------------------------------------------------------------------

\echo '[475] 첫 풀이 전용 unit / lesson / problem 적재'

INSERT INTO unit (id, chapter_id, title, description)
SELECT :first_try_id_base + 1,
       :first_try_chapter_id,
       'perf-first-try-unit',
       'perf first-try unit'
ON CONFLICT (id) DO NOTHING;

INSERT INTO lesson (id, unit_id, title)
SELECT :first_try_id_base + l,
       :first_try_id_base + 1,
       'perf-first-try-lesson-' || l
FROM generate_series(1, :first_try_lesson_count) AS l
ON CONFLICT (id) DO NOTHING;

-- 홀수는 OBJECTIVE, 짝수는 SUBJECTIVE. k6가 problemId 홀짝으로 페이로드를 나눈다.
INSERT INTO problem (id, lesson_id, content, instruction, problem_type)
SELECT :first_try_id_base + p,
       :first_try_id_base + ((p - 1) / :first_try_problems_per_lesson + 1),
       'perf first-try problem ' || p,
       'perf instruction',
       CASE WHEN p % 2 = 0 THEN 'SUBJECTIVE' ELSE 'OBJECTIVE' END
FROM generate_series(1, :first_try_lesson_count * :first_try_problems_per_lesson) AS p
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('unit', 'id'), (SELECT COALESCE(max(id), 1) FROM unit));
SELECT setval(pg_get_serial_sequence('lesson', 'id'), (SELECT COALESCE(max(id), 1) FROM lesson));
SELECT setval(pg_get_serial_sequence('problem', 'id'), (SELECT COALESCE(max(id), 1) FROM problem));

ANALYZE learning;
ANALYZE user_mission;
ANALYZE unit;
ANALYZE lesson;
ANALYZE problem;
ANALYZE lesson_submission;
ANALYZE problem_submission;
ANALYZE wrong_answered_note;

-- ---------------------------------------------------------------------------
-- 5) 검증
-- ---------------------------------------------------------------------------

\echo '[475] 검증: 행 수와 카디널리티'

SELECT 'learning'            AS table_name, count(*) AS rows, count(DISTINCT user_id)    AS user_cardinality FROM learning
UNION ALL
SELECT 'user_league',        count(*), count(DISTINCT user_id) FROM user_league
UNION ALL
SELECT 'user_mission',       count(*), count(DISTINCT user_id) FROM user_mission
UNION ALL
SELECT 'league',             count(*), count(DISTINCT id)      FROM league
UNION ALL
SELECT 'season',             count(*), count(DISTINCT status)  FROM season
UNION ALL
SELECT 'lesson_submission',  count(*), count(DISTINCT user_id) FROM lesson_submission
UNION ALL
SELECT 'problem_submission', count(*), count(DISTINCT user_id) FROM problem_submission
UNION ALL
SELECT 'wrong_answered_note', count(*), count(DISTINCT user_id) FROM wrong_answered_note;

\echo '[475] 검증: 첫 풀이 전용 대역'

SELECT 'first_try_lesson'  AS scope, count(*) AS rows FROM lesson  WHERE id >= :first_try_id_base
UNION ALL
SELECT 'first_try_problem', count(*) FROM problem WHERE id >= :first_try_id_base
UNION ALL
SELECT 'first_try_submission_leftover', count(*) FROM lesson_submission WHERE lesson_id >= :first_try_id_base;

\echo '[475] 검증: 오늘자(KST) 미션 배정'

SELECT count(*) AS today_assigned
FROM user_mission
WHERE assigned_date = (now() AT TIME ZONE 'Asia/Seoul')::date;
