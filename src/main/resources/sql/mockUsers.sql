-- Active Season이 없으면 생성, 있으면 재사용
INSERT INTO season (season_key, starts_at, ends_at, status, tz)
SELECT '2025-W41', '2025-10-06 00:00:00', '2025-10-13 00:00:00', 'ACTIVE', 'Asia/Seoul'
WHERE NOT EXISTS (SELECT 1 FROM season WHERE status = 'ACTIVE');

-- INSERT INTO season (season_key, starts_at, ends_at, status, tz)
-- SELECT '2025-W49', '2025-12-01 00:00:00', '2025-12-08 00:00:00', 'ACTIVE', 'Asia/Seoul'
--     WHERE NOT EXISTS (SELECT 1 FROM season WHERE status = 'ACTIVE');

-- 750명의 Mock Users 생성
INSERT INTO users (email, provider_id, nickname, handle, profile_img_number, level, xp, is_onboarded, role, status, created_at, updated_at)
SELECT
    'user' || s.n || '@test.com',
    'prov_' || LPAD(s.n::text, 6, '0'),
    SUBSTRING(MD5(RANDOM()::text) FROM 1 FOR (2 + (RANDOM() * 6)::int)),
    'hd_' || LPAD(s.n::text, 6, '0'),
    (RANDOM() * 3 + 1)::int,
        1,
    0,
    true,
    'USER',
    'ACTIVE',
    NOW(),
    NOW()
FROM generate_series(1, 750) AS s(n);

-- User League 데이터 생성 (ACTIVE 시즌 사용)
INSERT INTO user_league (user_id, league_id, season_id, league_point, created_at, updated_at)
SELECT
    u.id,
    ((u.id - 1) / 50 + 1)::int AS league_id,
        (SELECT id FROM season WHERE status = 'ACTIVE' LIMIT 1),
    CASE
        WHEN ((u.id - 1) / 50 + 1) = 1 THEN (RANDOM() * 100)::int
        WHEN ((u.id - 1) / 50 + 1) = 2 THEN (101 + RANDOM() * 99)::int
        WHEN ((u.id - 1) / 50 + 1) = 3 THEN (201 + RANDOM() * 119)::int
        WHEN ((u.id - 1) / 50 + 1) = 4 THEN (321 + RANDOM() * 139)::int
        WHEN ((u.id - 1) / 50 + 1) = 5 THEN (461 + RANDOM() * 159)::int
        WHEN ((u.id - 1) / 50 + 1) = 6 THEN (621 + RANDOM() * 179)::int
        WHEN ((u.id - 1) / 50 + 1) = 7 THEN (801 + RANDOM() * 199)::int
        WHEN ((u.id - 1) / 50 + 1) = 8 THEN (1001 + RANDOM() * 219)::int
        WHEN ((u.id - 1) / 50 + 1) = 9 THEN (1221 + RANDOM() * 239)::int
        WHEN ((u.id - 1) / 50 + 1) = 10 THEN (1461 + RANDOM() * 259)::int
        WHEN ((u.id - 1) / 50 + 1) = 11 THEN (1721 + RANDOM() * 279)::int
        WHEN ((u.id - 1) / 50 + 1) = 12 THEN (2001 + RANDOM() * 299)::int
        WHEN ((u.id - 1) / 50 + 1) = 13 THEN (2301 + RANDOM() * 319)::int
        WHEN ((u.id - 1) / 50 + 1) = 14 THEN (2621 + RANDOM() * 339)::int
        WHEN ((u.id - 1) / 50 + 1) = 15 THEN (2961 + RANDOM() * 1000)::int
END AS league_point,
    NOW(),
    NOW()
FROM users u
WHERE u.id BETWEEN 1 AND 750;