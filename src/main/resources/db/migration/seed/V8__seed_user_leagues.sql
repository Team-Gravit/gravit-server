INSERT INTO season (id, season_key, starts_at, ends_at, status, tz)
VALUES (1, '2025-W32', '2025-08-04 00:00:00', '2025-08-11 00:00:00', 'ACTIVE', 'Asia/Seoul');

DELETE
FROM user_league
WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'seed_%@test.com');

DELETE
FROM users
WHERE email LIKE 'seed_%@test.com';

-- 1) users: 리그별 30명 생성
WITH RECURSIVE seq(n) AS (SELECT 1
                          UNION ALL
                          SELECT n + 1
                          FROM seq
                          WHERE n < 30)
INSERT
INTO users (
  email, provider_id, nickname, handle,
  level, xp, created_at, profile_img_number, is_onboarded
)
SELECT CONCAT('seed_t', l.id, '_u', s.n, '@test.com') AS email,
       CONCAT('seed_p_t', l.id, '_', s.n)             AS provider_id,
       CONCAT('유저', l.id, '-', s.n)                   AS nickname,
       CONCAT('seed_t', l.id, '_u', s.n)              AS handle,
       CASE
           WHEN l.id BETWEEN 1 AND 3 THEN 3 + (s.n % 3)
           WHEN l.id BETWEEN 4 AND 6 THEN 6 + (s.n % 3)
           WHEN l.id BETWEEN 7 AND 9 THEN 9 + (s.n % 3)
           WHEN l.id BETWEEN 10 AND 12 THEN 12 + (s.n % 3)
           ELSE 15 + (s.n % 3)
           END                                        AS level,
       1000 + (l.id * 100) + s.n                      AS xp,
       NOW()                                          AS created_at,
       ((s.n - 1) % 10) + 1 AS profile_img_number, TRUE AS is_onboarded -- TRUE 대체
FROM league l
    JOIN seq s
ON 1=1
WHERE l.id BETWEEN 1 AND 15;

-- 2) user_league: provider_id로 users를 다시 찾아 연결
WITH RECURSIVE seq(n) AS (SELECT 1
                          UNION ALL
                          SELECT n + 1
                          FROM seq
                          WHERE n < 30)
INSERT
INTO user_league (user_id, season_id, league_id, league_point, updated_at)
SELECT u.id,
       1    AS season_id,
       l.id AS league_id,
       (l.min_lp + floor((l.max_lp - l.min_lp) * ((s.n - 1):: numeric / 29)))::int AS league_point,
        NOW() AS updated_at
FROM league l
         JOIN seq s ON TRUE
         JOIN users u
              ON u.provider_id = concat('seed_p_t', l.id, '_', s.n)
WHERE l.id BETWEEN 1 AND 15;