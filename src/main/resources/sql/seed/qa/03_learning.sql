-- =====================================================================
-- QA 페르소나 데이터셋 03 - 학습 이력 (learner, streak, chapter-almost, mission)
--
-- 레슨은 챕터 안에서 unit.display_order, lesson.id 순으로 고릅니다.
-- 지난 날짜의 제출 시각은 그날 20:00(KST)로 고정합니다.
-- 모든 제출은 첫 제출이므로 XP와 LP는 레슨마다 round(20 * accuracy / 100)이고, 마지막에 합산합니다.
-- =====================================================================

-- learner: 챕터 1 앞 레슨 10개를 D-13, 12, 10, 9, 7, 6, 4, 3, 2, 1일에 하루 1개씩 제출
--          3, 6, 9번째 레슨은 id가 작은 문제 2개를 오답 처리
INSERT INTO lesson_submission (
    learning_time, lesson_id, user_id, accuracy, created_at, updated_at
)
SELECT
    120,
    plan.lesson_id,
    u.id,
    CASE
        WHEN plan.seq IN (3, 6, 9) THEN round(100.0 * (plan.problem_count - 2) / plan.problem_count)
        ELSE 100
    END,
    date_trunc('day', now()) - make_interval(days => (ARRAY[13, 12, 10, 9, 7, 6, 4, 3, 2, 1])[plan.seq]) + INTERVAL '20 hours',
    date_trunc('day', now()) - make_interval(days => (ARRAY[13, 12, 10, 9, 7, 6, 4, 3, 2, 1])[plan.seq]) + INTERVAL '20 hours'
FROM users u
CROSS JOIN (
    SELECT
        l.id AS lesson_id,
        ROW_NUMBER() OVER (ORDER BY un.display_order, l.id) AS seq,
        (SELECT count(*) FROM problem p WHERE p.lesson_id = l.id) AS problem_count
    FROM lesson l
    JOIN unit un ON un.id = l.unit_id
    WHERE un.chapter_id = 1
) AS plan
WHERE u.email = 'qa-persona-{set}-learner@gravit.test'
  AND plan.seq <= 10;

INSERT INTO problem_submission (
    is_correct, problem_id, user_id, created_at, updated_at,
    selected_option_id, submitted_content
)
SELECT
    NOT ps.is_wrong,
    ps.problem_id,
    ps.user_id,
    ps.submitted_at,
    ps.submitted_at,
    CASE
        WHEN ps.problem_type = 'OBJECTIVE' THEN (
            SELECT o.id
            FROM option o
            WHERE o.problem_id = ps.problem_id
              AND o.is_answer = NOT ps.is_wrong
            ORDER BY o.id
            LIMIT 1
        )
    END,
    CASE
        WHEN ps.problem_type = 'SUBJECTIVE' AND ps.is_wrong THEN 'QA 오답'
        WHEN ps.problem_type = 'SUBJECTIVE' THEN (
            SELECT split_part(a.content, ',', 1)
            FROM answer a
            WHERE a.problem_id = ps.problem_id
            ORDER BY a.id
            LIMIT 1
        )
    END
FROM (
    SELECT
        ls.user_id,
        ls.created_at AS submitted_at,
        p.id AS problem_id,
        p.problem_type,
        ls.seq IN (3, 6, 9) AND ROW_NUMBER() OVER (PARTITION BY ls.id ORDER BY p.id) <= 2 AS is_wrong
    FROM (
        SELECT s.*, ROW_NUMBER() OVER (ORDER BY s.created_at) AS seq
        FROM lesson_submission s
        WHERE s.user_id = (SELECT id FROM users WHERE email = 'qa-persona-{set}-learner@gravit.test')
    ) AS ls
    JOIN problem p ON p.lesson_id = ls.lesson_id
) AS ps;

INSERT INTO wrong_answered_note (
    problem_id, user_id, created_at, updated_at, wrong_count, resolved_at
)
SELECT ps.problem_id, ps.user_id, ps.created_at, ps.created_at, 1, NULL
FROM problem_submission ps
WHERE ps.user_id = (SELECT id FROM users WHERE email = 'qa-persona-{set}-learner@gravit.test')
  AND NOT ps.is_correct;

-- learner 북마크: 1, 2, 3번째 레슨의 첫 문제 (3번째 레슨의 첫 문제는 오답 문제)
INSERT INTO bookmark (created_at, problem_id, user_id)
SELECT ls.created_at, first_problem.id, ls.user_id
FROM (
    SELECT s.*, ROW_NUMBER() OVER (ORDER BY s.created_at) AS seq
    FROM lesson_submission s
    WHERE s.user_id = (SELECT id FROM users WHERE email = 'qa-persona-{set}-learner@gravit.test')
) AS ls
CROSS JOIN LATERAL (
    SELECT p.id
    FROM problem p
    WHERE p.lesson_id = ls.lesson_id
    ORDER BY p.id
    LIMIT 1
) AS first_problem
WHERE ls.seq <= 3;

-- streak: 챕터 2 앞 레슨 6개를 D-6 ~ D-1에 하루 1개씩 정확도 100으로 제출
INSERT INTO lesson_submission (
    learning_time, lesson_id, user_id, accuracy, created_at, updated_at
)
SELECT
    120,
    plan.lesson_id,
    u.id,
    100,
    date_trunc('day', now()) - make_interval(days => 7 - plan.seq::int) + INTERVAL '20 hours',
    date_trunc('day', now()) - make_interval(days => 7 - plan.seq::int) + INTERVAL '20 hours'
FROM users u
CROSS JOIN (
    SELECT l.id AS lesson_id, ROW_NUMBER() OVER (ORDER BY un.display_order, l.id) AS seq
    FROM lesson l
    JOIN unit un ON un.id = l.unit_id
    WHERE un.chapter_id = 2
) AS plan
WHERE u.email = 'qa-persona-{set}-streak@gravit.test'
  AND plan.seq <= 6;

-- chapter-almost: 챕터 1에서 마지막 유닛(display_order 최대)의 id 최대 레슨만 빼고 D-2 20:00부터 1초 간격으로 제출
INSERT INTO lesson_submission (
    learning_time, lesson_id, user_id, accuracy, created_at, updated_at
)
SELECT
    60,
    plan.lesson_id,
    u.id,
    100,
    date_trunc('day', now()) - INTERVAL '2 days' + INTERVAL '20 hours' + make_interval(secs => plan.seq),
    date_trunc('day', now()) - INTERVAL '2 days' + INTERVAL '20 hours' + make_interval(secs => plan.seq)
FROM users u
CROSS JOIN (
    SELECT l.id AS lesson_id, ROW_NUMBER() OVER (ORDER BY un.display_order, l.id) AS seq
    FROM lesson l
    JOIN unit un ON un.id = l.unit_id
    WHERE un.chapter_id = 1
      AND l.id <> (
          SELECT last_lesson.id
          FROM lesson last_lesson
          JOIN unit last_unit ON last_unit.id = last_lesson.unit_id
          WHERE last_unit.chapter_id = 1
          ORDER BY last_unit.display_order DESC, last_lesson.id DESC
          LIMIT 1
      )
) AS plan
WHERE u.email = 'qa-persona-{set}-chapter-almost@gravit.test';

-- mission: 챕터 3 첫 레슨을 오늘 정확도 100으로 제출, 미션은 COMPLETE_LESSONS_TWO 진행 1
INSERT INTO lesson_submission (
    learning_time, lesson_id, user_id, accuracy, created_at, updated_at
)
SELECT 120, plan.lesson_id, u.id, 100, now(), now()
FROM users u
CROSS JOIN (
    SELECT l.id AS lesson_id
    FROM lesson l
    JOIN unit un ON un.id = l.unit_id
    WHERE un.chapter_id = 3
    ORDER BY un.display_order, l.id
    LIMIT 1
) AS plan
WHERE u.email = 'qa-persona-{set}-mission@gravit.test';

UPDATE user_mission um
SET mission_id = (SELECT id FROM mission WHERE code = 'COMPLETE_LESSONS_TWO'),
    progress_count = 1,
    updated_at = now()
WHERE um.user_id = (SELECT id FROM users WHERE email = 'qa-persona-{set}-mission@gravit.test')
  AND um.assigned_date = current_date;

-- 일별 기록: 첫 제출이 있었던 날짜마다 그날 제출한 레슨 수
INSERT INTO daily_learning_record (user_id, solved_date, solved_lesson_count)
SELECT ls.user_id, ls.created_at::date, count(*)
FROM lesson_submission ls
JOIN users u ON u.id = ls.user_id
WHERE u.provider_id LIKE 'qa-persona-{set}-%'
GROUP BY ls.user_id, ls.created_at::date;

-- 파생 값: XP와 레벨, LP와 리그, 최근 챕터와 정복률, 연속 학습
UPDATE users u
SET xp = earned.xp,
    level = (
        SELECT max(lv.level)
        FROM (VALUES (1, 0), (2, 100), (3, 200), (4, 400), (5, 700),
                     (6, 1100), (7, 1600), (8, 2200), (9, 2900), (10, 3700)) AS lv(level, start_xp)
        WHERE lv.start_xp <= earned.xp
    )
FROM (
    SELECT ls.user_id, sum(round(20 * ls.accuracy / 100.0))::int AS xp
    FROM lesson_submission ls
    JOIN users qu ON qu.id = ls.user_id
    WHERE qu.provider_id LIKE 'qa-persona-{set}-%'
    GROUP BY ls.user_id
) AS earned
WHERE u.id = earned.user_id;

UPDATE user_league ul
SET league_point = u.xp,
    league_id = (SELECT l.id FROM league l WHERE u.xp BETWEEN l.min_lp AND l.max_lp),
    updated_at = now()
FROM users u
WHERE ul.user_id = u.id
  AND u.provider_id LIKE 'qa-persona-{set}-%'
  AND EXISTS (SELECT 1 FROM lesson_submission ls WHERE ls.user_id = u.id);

UPDATE learning lr
SET recent_solved_chapter_id = (
        SELECT un.chapter_id
        FROM lesson_submission ls
        JOIN lesson l ON l.id = ls.lesson_id
        JOIN unit un ON un.id = l.unit_id
        WHERE ls.user_id = lr.user_id
        ORDER BY ls.created_at DESC, ls.id DESC
        LIMIT 1
    ),
    planet_conquest_rate = (
        SELECT round(count(DISTINCT ls.lesson_id) * 100.0 / (SELECT count(*) FROM lesson))
        FROM lesson_submission ls
        WHERE ls.user_id = lr.user_id
    ),
    consecutive_solved_days = streak.days,
    today_solved = streak.today_solved
FROM users u
JOIN (VALUES
    ('learner',        4, false),
    ('streak',         6, false),
    ('chapter-almost', 0, false),
    ('mission',        1, true)
) AS streak(key, days, today_solved) ON u.email = 'qa-persona-{set}-' || streak.key || '@gravit.test'
WHERE lr.user_id = u.id;
