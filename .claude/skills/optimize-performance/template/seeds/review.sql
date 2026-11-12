-- 복습 도메인 시드: answer → option → bookmark → wrong_answered_note
--
-- 필요한 변수: user_start, user_count, target_unit_id,
--              bookmarks_per_user, target_unit_bookmarks_per_user, options_per_problem,
--              target_unit_wrong_notes_per_user, target_unit_resolved_per_user
--
-- answer/option은 problem 전체를 커버한다. ProblemFactory가 문제 타입별로 하나라도 없으면
-- ANSWER_NOT_FOUND / OPTION_NOT_FOUND 예외를 던져 측정이 500으로 끝난다.
--
-- bookmark는 유저마다 :target_unit_bookmarks_per_user 건을 :target_unit_id 에 몰고,
-- 나머지를 다른 유닛의 문제에 퍼뜨린다. 대상 유닛 필터가 실제로 행을 걸러내게 하려는 것이다.
-- created_at은 유저 안에서 행마다 다른 값을 갖는다. ORDER BY b.createdAt 이 실제 정렬을 수행해야 한다.
--
-- wrong_answered_note는 유저마다 :target_unit_wrong_notes_per_user 건을 :target_unit_id 에 몰고,
-- 그중 뒤쪽 :target_unit_resolved_per_user 건을 극복 처리한다.
-- resolvedAt IS NULL 필터가 대상 유닛 안에서 실제로 행을 걸러내게 하려는 것이다.
-- 반환 행 수 = :target_unit_wrong_notes_per_user - :target_unit_resolved_per_user 가 된다.
--
-- bookmark/answer/option에는 유니크 제약이 없으므로 ON CONFLICT를 쓸 수 없다.
-- 재실행 시 중복이 쌓이지 않도록 NOT EXISTS 가드를 둔다. 가드를 지우지 마라.
-- wrong_answered_note만 (user_id, problem_id) 유니크 인덱스가 있어 ON CONFLICT DO NOTHING을 쓴다.
-- 이 테이블은 대상 유닛 밖에 이미 행이 있을 수 있어 "유저에 행이 없으면" 가드가 통하지 않는다.

\echo '[review.sql] answer/option/bookmark/wrong_answered_note 적재'

BEGIN;

-- answer: SUBJECTIVE 문제마다 1건
INSERT INTO answer (problem_id, content, explanation)
SELECT p.id,
       'perf answer ' || p.id,
       'perf answer explanation ' || p.id
FROM problem p
WHERE p.problem_type = 'SUBJECTIVE'
  AND NOT EXISTS (SELECT 1 FROM answer a WHERE a.problem_id = p.id);

-- option: OBJECTIVE 문제마다 :options_per_problem 건 (첫 번째가 정답)
INSERT INTO "option" (problem_id, content, explanation, is_answer)
SELECT p.id,
       'perf option ' || p.id || '-' || o,
       'perf option explanation ' || p.id || '-' || o,
       (o = 1)
FROM problem p
CROSS JOIN generate_series(1, :options_per_problem) AS o
WHERE p.problem_type = 'OBJECTIVE'
  AND NOT EXISTS (SELECT 1 FROM "option" op WHERE op.problem_id = p.id);

-- bookmark: 유저당 :bookmarks_per_user 건
INSERT INTO bookmark (user_id, problem_id, created_at)
SELECT src.user_id,
       src.problem_id,
       TIMESTAMP '2025-01-01 00:00:00'
           + (row_number() OVER (PARTITION BY src.user_id ORDER BY src.problem_id) * INTERVAL '1 second')
FROM (
    WITH unseeded_users AS (
        SELECT u.id,
               row_number() OVER (ORDER BY u.id) - 1 AS u_idx
        FROM users u
        WHERE u.id BETWEEN :user_start AND :user_start + :user_count - 1
          AND NOT EXISTS (SELECT 1 FROM bookmark b WHERE b.user_id = u.id)
    ),
    target_problems AS (
        SELECT p.id,
               row_number() OVER (PARTITION BY p.problem_type ORDER BY p.id) - 1 AS rn
        FROM problem p
        JOIN lesson l ON l.id = p.lesson_id
        WHERE l.unit_id = :target_unit_id
    ),
    other_problems AS (
        SELECT p.id,
               row_number() OVER (ORDER BY p.id) - 1 AS p_idx
        FROM problem p
        JOIN lesson l ON l.id = p.lesson_id
        WHERE l.unit_id <> :target_unit_id
    ),
    other_count AS (
        SELECT count(*)::bigint AS n FROM other_problems
    )
    -- 대상 유닛: rn이 problem_type별로 매겨지므로 k 하나가 OBJECTIVE/SUBJECTIVE 각 1건을 집는다
    SELECT u.id AS user_id, tp.id AS problem_id
    FROM unseeded_users u
    CROSS JOIN generate_series(0, :target_unit_bookmarks_per_user / 2 - 1) AS k
    JOIN target_problems tp ON tp.rn = k

    UNION ALL

    -- 그 외 유닛: 유저마다 서로 다른 문제 집합을 집는다 (step 11은 유저 안에서 충돌하지 않는다)
    SELECT u.id, op.id
    FROM unseeded_users u
    CROSS JOIN generate_series(0, :bookmarks_per_user - :target_unit_bookmarks_per_user - 1) AS k
    CROSS JOIN other_count oc
    JOIN other_problems op ON op.p_idx = ((u.u_idx * 37 + k * 11) % oc.n)
) AS src;

-- wrong_answered_note: 대상 유닛에 유저당 :target_unit_wrong_notes_per_user 건
-- k 하나가 OBJECTIVE/SUBJECTIVE 각 1건을 집으므로 타입이 균형을 이룬다.
-- k가 뒤쪽 구간이면 극복 처리해 resolved_at을 채운다.
INSERT INTO wrong_answered_note (user_id, problem_id, wrong_count, created_at, updated_at, resolved_at)
SELECT su.id,
       tp.id,
       1 + (k % 3),
       TIMESTAMP '2025-01-01 00:00:00' + (k * INTERVAL '1 second'),
       TIMESTAMP '2025-01-01 00:00:00' + (k * INTERVAL '1 second'),
       CASE
           WHEN k >= (:target_unit_wrong_notes_per_user - :target_unit_resolved_per_user) / 2
               THEN TIMESTAMP '2025-06-01 00:00:00' + (k * INTERVAL '1 second')
           ELSE NULL
       END
FROM (
    SELECT u.id
    FROM users u
    WHERE u.id BETWEEN :user_start AND :user_start + :user_count - 1
) AS su
CROSS JOIN generate_series(0, :target_unit_wrong_notes_per_user / 2 - 1) AS k
JOIN (
    SELECT p.id,
           row_number() OVER (PARTITION BY p.problem_type ORDER BY p.id) - 1 AS rn
    FROM problem p
    JOIN lesson l ON l.id = p.lesson_id
    WHERE l.unit_id = :target_unit_id
) AS tp ON tp.rn = k
ON CONFLICT (user_id, problem_id) DO NOTHING;

COMMIT;

ANALYZE answer;
ANALYZE "option";
ANALYZE bookmark;
ANALYZE wrong_answered_note;

-- 검증: 행 수와 카디널리티
SELECT 'answer' AS table_name, count(*) AS rows, count(DISTINCT problem_id) AS distinct_problem
FROM answer
UNION ALL
SELECT 'option', count(*), count(DISTINCT problem_id) FROM "option"
UNION ALL
SELECT 'bookmark', count(*), count(DISTINCT problem_id) FROM bookmark
UNION ALL
SELECT 'wrong_answered_note', count(*), count(DISTINCT problem_id) FROM wrong_answered_note;

SELECT count(DISTINCT user_id) AS distinct_user,
       count(*) / NULLIF(count(DISTINCT user_id), 0) AS per_user,
       min(created_at) AS min_created,
       max(created_at) AS max_created
FROM bookmark;

-- 검증: 대상 유닛의 유저당 결과 크기와 문제 타입 분포
SELECT b.user_id,
       count(*) AS rows_in_target_unit,
       count(*) FILTER (WHERE p.problem_type = 'OBJECTIVE') AS objective,
       count(*) FILTER (WHERE p.problem_type = 'SUBJECTIVE') AS subjective
FROM bookmark b
JOIN problem p ON p.id = b.problem_id
JOIN lesson l ON l.id = p.lesson_id
WHERE l.unit_id = :target_unit_id
GROUP BY b.user_id
ORDER BY b.user_id
LIMIT 3;

-- 검증: 대상 유닛의 유저당 오답노트 반환 크기(미극복)와 극복 건수
SELECT wan.user_id,
       count(*)                                                                          AS total_in_target_unit,
       count(*) FILTER (WHERE wan.resolved_at IS NULL)                                   AS unresolved,
       count(*) FILTER (WHERE wan.resolved_at IS NULL AND p.problem_type = 'OBJECTIVE')  AS objective,
       count(*) FILTER (WHERE wan.resolved_at IS NULL AND p.problem_type = 'SUBJECTIVE') AS subjective,
       count(*) FILTER (WHERE wan.resolved_at IS NOT NULL)                               AS resolved
FROM wrong_answered_note wan
JOIN problem p ON p.id = wan.problem_id
JOIN lesson l ON l.id = p.lesson_id
WHERE l.unit_id = :target_unit_id
GROUP BY wan.user_id
ORDER BY wan.user_id
LIMIT 3;
