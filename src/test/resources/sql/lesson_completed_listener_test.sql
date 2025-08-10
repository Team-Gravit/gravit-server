-- 브론즈 1, 2 리그 생성
INSERT INTO league (id, name, min_lp, max_lp, sort_order, league_img_url)
VALUES (1, 'Bronze 1', 0, 100, 1, 'http://localhost:1234/dlfjgrp');
INSERT INTO league (id, name, min_lp, max_lp, sort_order, league_img_url)
VALUES (2, 'Bronze 2', 101, 200, 2, 'http://localhost:1234/dlfjgrp');

-- 시즌 생성
INSERT INTO season (id,season_key, starts_at, ends_at, status, tz)
VALUES (1,'2025-W32', '2025-08-04 00:00:00', '2025-08-11 00:00:00', 'ACTIVE', 'Asia/Seoul');

-- 브론즈 1 유저 데이터
INSERT INTO users (id, email, provider_id, nickname, handle, level, xp, created_at, profile_img_number, is_onboarded)
VALUES (1, 'user1@test.com', 'p1', '유저1', 'handle1', 5, 500, NOW(), 1, true);

-- 브론즈 유저 리그 데이터 (league_point = LP)
INSERT INTO user_league (id, user_id, season_id, league_id, league_point, updated_at)
VALUES (1, 1, 1, 1, 90, NOW());
