-- 리그 데이터 (최소 1개)
-- 브론즈 1 리그
INSERT INTO league (id, name, min_lp, max_lp, sort_order, league_img_url)
VALUES (1, 'Bronze 1', 0, 100, 1, 'http://localhost:1234/dlfjgrp');
-- 실버 1 리그
INSERT INTO league (id, name, min_lp, max_lp, sort_order, league_img_url)
VALUES (4, 'Silver 1', 321, 460, 4, 'http://localhost:1234/silver1');

-- 시즌 생성
INSERT INTO season (id,season_key, starts_at, ends_at, status, tz)
VALUES (1, '2025-W32', '2025-08-04 00:00:00', '2025-08-11 00:00:00', 'ACTIVE', 'Asia/Seoul');

-- 브론즈 1 유저 데이터 (12명, 프로필 이미지 번호는 1~10 범위)
INSERT INTO users (id, email, provider_id, nickname, handle, level, xp, created_at, profile_img_number, is_onboarded)
VALUES (1, 'user1@test.com', 'p1', '유저1', 'handle1', 5, 500, NOW(), 1, true),
       (2, 'user2@test.com', 'p2', '유저2', 'handle2', 5, 500, NOW(), 2, true),
       (3, 'user3@test.com', 'p3', '유저3', 'handle3', 4, 480, NOW(), 3, true),
       (4, 'user4@test.com', 'p4', '유저4', 'handle4', 4, 470, NOW(), 4, true),
       (5, 'user5@test.com', 'p5', '유저5', 'handle5', 4, 470, NOW(), 5, true),
       (6, 'user6@test.com', 'p6', '유저6', 'handle6', 3, 460, NOW(), 6, true),
       (7, 'user7@test.com', 'p7', '유저7', 'handle7', 3, 450, NOW(), 7, true),
       (8, 'user8@test.com', 'p8', '유저8', 'handle8', 3, 450, NOW(), 8, true),
       (9, 'user9@test.com', 'p9', '유저9', 'handle9', 2, 440, NOW(), 9, true),
       (10, 'user10@test.com', 'p10', '유저10', 'handle10', 2, 430, NOW(), 10, true),
       (11, 'user11@test.com', 'p11', '유저11', 'handle11', 2, 420, NOW(), 1, true),
       (12, 'user12@test.com', 'p12', '유저12', 'handle12', 1, 400, NOW(), 2, true);

-- 실버 1 유저 12명 (id 13~24)
INSERT INTO users (id, email, provider_id, nickname, handle, level, xp, created_at, profile_img_number, is_onboarded)
VALUES (13, 'user13@test.com', 'p13', '유저13', 'handle13', 6, 1300, NOW(), 3, true),
       (14, 'user14@test.com', 'p14', '유저14', 'handle14', 6, 1400, NOW(), 4, true),
       (15, 'user15@test.com', 'p15', '유저15', 'handle15', 6, 1500, NOW(), 5, true),
       (16, 'user16@test.com', 'p16', '유저16', 'handle16', 6, 1600, NOW(), 6, true),
       (17, 'user17@test.com', 'p17', '유저17', 'handle17', 6, 1700, NOW(), 7, true),
       (18, 'user18@test.com', 'p18', '유저18', 'handle18', 6, 1800, NOW(), 8, true),
       (19, 'user19@test.com', 'p19', '유저19', 'handle19', 6, 1900, NOW(), 9, true),
       (20, 'user20@test.com', 'p20', '유저20', 'handle20', 6, 2000, NOW(), 10, true),
       (21, 'user21@test.com', 'p21', '유저21', 'handle21', 6, 2100, NOW(), 1, true),
       (22, 'user22@test.com', 'p22', '유저22', 'handle22', 6, 2200, NOW(), 2, true),
       (23, 'user23@test.com', 'p23', '유저23', 'handle23', 6, 2300, NOW(), 3, true),
       (24, 'user24@test.com', 'p24', '유저24', 'handle24', 6, 2400, NOW(), 4, true);

-- 브론즈 유저 리그 데이터 (league_point = LP)
INSERT INTO user_league (id, user_id, season_id, league_id, league_point, updated_at)
VALUES (1, 1, 1,1, 50, NOW()),
       (2, 2, 1,1, 70, NOW()),
       (3, 3, 1,1, 20, NOW()),
       (4, 4, 1,1, 30, NOW()),
       (5, 5, 1,1, 50, NOW()),
       (6, 6, 1,1, 90, NOW()),
       (7, 7, 1,1, 95, NOW()),
       (8, 8, 1,1, 10, NOW()),
       (9, 9, 1,1, 15, NOW()),
       (10, 10, 1,1, 30, NOW()),
       (11, 11, 1,1, 20, NOW()),
       (12, 12, 1,1, 75, NOW());

-- 실버 1 유저 리그 (league_point = LP, 321~460 범위, 동점 포함)
INSERT INTO user_league (id, user_id, season_id, league_id, league_point, updated_at)
VALUES (13, 13, 1,4, 460, NOW()),
       (14, 14, 1,4, 455, NOW()),
       (15, 15, 1,4, 450, NOW()),
       (16, 16, 1,4, 450, NOW()), -- 동점
       (17, 17, 1,4, 440, NOW()),
       (18, 18, 1,4, 435, NOW()),
       (19, 19, 1,4, 430, NOW()),
       (20, 20, 1,4, 425, NOW()),
       (21, 21, 1,4, 410, NOW()),
       (22, 22, 1,4, 390, NOW()),
       (23, 23, 1,4, 360, NOW()),
       (24, 24, 1,4, 321, NOW());