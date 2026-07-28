-- 학습 이력 시드: lesson_submission, problem_submission, daily_learning_record
--
-- 선행 모듈: content.sql (lesson, problem), user.sql (users)
-- 필요한 변수: user_start, user_count,
--              lesson_sub_per_user, distinct_lessons, recent_days, recent_count, window_days,
--              problem_sub_per_user, distinct_problems, wrong_pct,
--              daily_record_days
--
-- 제약: window_days > recent_days, lesson_sub_per_user >= recent_count
--       lesson/problem 테이블이 비어 있으면 아무것도 들어가지 않는다. content.sql을 먼저 부른다.
--
-- 시간 분포
--   lesson_submission: 앞의 :recent_count 건은 최근 :recent_days 일에 몰아넣고,
--                      나머지는 :recent_days ~ :window_days 일 전에 퍼뜨린다.
--                      주간 집계 쿼리를 재는데 오늘이 주 초반이면 이 구간이 비어버리므로 의도적으로 몰아준다.
--   problem_submission: :window_days 일에 균등하게 퍼뜨린다.
--
-- 재실행 가드: 해당 유저 범위에 이미 행이 있으면 통째로 건너뛴다.
--              규모를 바꾸려면 그 범위를 지우고 다시 실행한다.

\echo '[learning.sql] lesson_submission / problem_submission / daily_learning_record 적재'

BEGIN;

-- 1) lesson_submission: 유저당 :lesson_sub_per_user 건, 서로 다른 레슨 :distinct_lessons 개
WITH lesson_no AS (
    SELECT id,
           row_number() OVER (ORDER BY id) - 1 AS rn,
           count(*) OVER ()                    AS total
    FROM lesson
),
target_users AS (
    SELECT id, id - :user_start AS idx
    FROM users
    WHERE id BETWEEN :user_start AND :user_start + :user_count - 1
)
INSERT INTO lesson_submission (user_id, lesson_id, learning_time, accuracy, created_at, updated_at)
SELECT tu.id,
       ln.id,
       180 + ((tu.idx + j) % 600),
       40 + ((tu.idx * 3 + j) % 61),
       stamp.at,
       stamp.at
FROM target_users tu
CROSS JOIN generate_series(1, :lesson_sub_per_user) AS j
CROSS JOIN LATERAL (
    SELECT date_trunc('day', now() AT TIME ZONE 'Asia/Seoul')
               - (CASE
                      WHEN j <= :recent_count THEN (j - 1) % :recent_days
                      ELSE ((j - :recent_count - 1) % (:window_days - :recent_days)) + :recent_days
                  END) * INTERVAL '1 day'
               + ((j * 7) % 20) * INTERVAL '1 hour' AS at
) stamp
JOIN lesson_no ln ON ln.rn = ((tu.idx * 7) + (j % :distinct_lessons)) % NULLIF(ln.total, 0)
WHERE NOT EXISTS (
    SELECT 1 FROM lesson_submission
    WHERE user_id BETWEEN :user_start AND :user_start + :user_count - 1
);

-- 2) problem_submission: 유저당 :problem_sub_per_user 건, 서로 다른 문제 :distinct_problems 개, 오답 :wrong_pct %
WITH problem_no AS (
    SELECT id,
           row_number() OVER (ORDER BY id) - 1 AS rn,
           count(*) OVER ()                    AS total
    FROM problem
),
target_users AS (
    SELECT id, id - :user_start AS idx
    FROM users
    WHERE id BETWEEN :user_start AND :user_start + :user_count - 1
)
INSERT INTO problem_submission (user_id, problem_id, is_correct, created_at, updated_at)
SELECT tu.id,
       pn.id,
       ((tu.idx + j) % 100) >= :wrong_pct,
       date_trunc('day', now() AT TIME ZONE 'Asia/Seoul') - ((j % :window_days) * INTERVAL '1 day'),
       date_trunc('day', now() AT TIME ZONE 'Asia/Seoul') - ((j % :window_days) * INTERVAL '1 day')
FROM target_users tu
CROSS JOIN generate_series(1, :problem_sub_per_user) AS j
JOIN problem_no pn ON pn.rn = ((tu.idx * 13) + (j % :distinct_problems)) % NULLIF(pn.total, 0)
WHERE NOT EXISTS (
    SELECT 1 FROM problem_submission
    WHERE user_id BETWEEN :user_start AND :user_start + :user_count - 1
);

-- 3) daily_learning_record: 유저당 :daily_record_days 일 (오늘부터 역순, 유니크 제약으로 중복 차단)
INSERT INTO daily_learning_record (user_id, solved_date, solved_lesson_count)
SELECT u.id,
       (now() AT TIME ZONE 'Asia/Seoul')::date - (j - 1),
       1 + ((u.id + j) % 8)
FROM users u
CROSS JOIN generate_series(1, :daily_record_days) AS j
WHERE u.id BETWEEN :user_start AND :user_start + :user_count - 1
ON CONFLICT DO NOTHING;

COMMIT;

ANALYZE lesson_submission;
ANALYZE problem_submission;
ANALYZE daily_learning_record;

-- 검증: 전체 규모와 카디널리티
SELECT 'lesson_submission'              AS table_name,
       count(*)                         AS rows,
       count(DISTINCT user_id)          AS user_cardinality,
       count(DISTINCT lesson_id)        AS content_cardinality,
       count(DISTINCT created_at::date) AS day_cardinality
FROM lesson_submission
UNION ALL
SELECT 'problem_submission',
       count(*),
       count(DISTINCT user_id),
       count(DISTINCT problem_id),
       count(DISTINCT created_at::date)
FROM problem_submission
UNION ALL
SELECT 'daily_learning_record',
       count(*),
       count(DISTINCT user_id),
       count(DISTINCT solved_lesson_count),
       count(DISTINCT solved_date)
FROM daily_learning_record;

-- 검증: 유저 1명(:user_start) 기준 per-user 규모
SELECT 'lesson_submission'       AS scope,
       count(*)                  AS rows,
       count(DISTINCT lesson_id) AS distinct_content,
       count(*) FILTER (
           WHERE created_at >= date_trunc('day', now() AT TIME ZONE 'Asia/Seoul')
                               - (:recent_days - 1) * INTERVAL '1 day'
       )                         AS rows_in_recent_window
FROM lesson_submission
WHERE user_id = :user_start
UNION ALL
SELECT 'problem_submission',
       count(*),
       count(DISTINCT problem_id),
       count(*) FILTER (WHERE is_correct = false)
FROM problem_submission
WHERE user_id = :user_start;
