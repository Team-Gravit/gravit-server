INSERT INTO users (id, email, provider_id, nickname, handle, level, xp, created_at, profile_img_number, is_onboarded)
VALUES
-- requester
(1, 'owner@test.com', 'p0', '요청자', 'owner001', 5, 500, CURRENT_TIMESTAMP, 1, TRUE),

-- prefix: zb000001 ~ zb000012 (12개)
(2, 'user02@test.com', 'p2', '유저02', 'zb000001', 5, 500, CURRENT_TIMESTAMP, 2, TRUE),
(3, 'user03@test.com', 'p3', '유저03', 'zb000002', 5, 500, CURRENT_TIMESTAMP, 3, TRUE),
(4, 'user04@test.com', 'p4', '유저04', 'zb000003', 5, 500, CURRENT_TIMESTAMP, 4, TRUE),
(5, 'user05@test.com', 'p5', '유저05', 'zb000004', 5, 500, CURRENT_TIMESTAMP, 5, TRUE),
(6, 'user06@test.com', 'p6', '유저06', 'zb000005', 5, 500, CURRENT_TIMESTAMP, 6, TRUE),
(7, 'user07@test.com', 'p7', '유저07', 'zb000006', 4, 480, CURRENT_TIMESTAMP, 7, TRUE),
(8, 'user08@test.com', 'p8', '유저08', 'zb000007', 4, 470, CURRENT_TIMESTAMP, 8, TRUE),
(9, 'user09@test.com', 'p9', '유저09', 'zb000008', 4, 470, CURRENT_TIMESTAMP, 9, TRUE),
(10, 'user10@test.com', 'p10', '유저10', 'zb000009', 3, 460, CURRENT_TIMESTAMP, 10, TRUE),
(11, 'user11@test.com', 'p11', '유저11', 'zb000010', 3, 450, CURRENT_TIMESTAMP, 1, TRUE),
(12, 'user12@test.com', 'p12', '유저12', 'zb000011', 3, 450, CURRENT_TIMESTAMP, 2, TRUE),
(13, 'user13@test.com', 'p13', '유저13', 'zb000012', 2, 440, CURRENT_TIMESTAMP, 3, TRUE),

-- prefix: exact-ish 1개 더 (총 prefix 13개)
(14, 'user14@test.com', 'p14', '유저14', 'zzb000011', 2, 430, CURRENT_TIMESTAMP, 4, TRUE),

-- contains: 중간에 'zb' 포함 (6개)
(15, 'user15@test.com', 'p15', '유저15', 'azb00001', 2, 420, CURRENT_TIMESTAMP, 5, TRUE),
(16, 'user16@test.com', 'p16', '유저16', 'xzb00002', 2, 410, CURRENT_TIMESTAMP, 6, TRUE),
(17, 'user17@test.com', 'p17', '유저17', 'b0zb0003', 1, 400, CURRENT_TIMESTAMP, 7, TRUE),
(18, 'user18@test.com', 'p18', '유저18', '12zb0004', 1, 390, CURRENT_TIMESTAMP, 8, TRUE),
(19, 'user19@test.com', 'p19', '유저19', 'abzbcd12', 1, 380, CURRENT_TIMESTAMP, 9, TRUE),
(20, 'user20@test.com', 'p20', '유저20', 'q1zb9w0e', 1, 370, CURRENT_TIMESTAMP, 10, TRUE),

-- others: zb 미포함 (11개)
(21, 'user21@test.com', 'p21', '유저21', 'user0001', 5, 500, CURRENT_TIMESTAMP, 1, TRUE),
(22, 'user22@test.com', 'p22', '유저22', 'user0002', 5, 500, CURRENT_TIMESTAMP, 2, TRUE),
(23, 'user23@test.com', 'p23', '유저23', 'user0003', 5, 500, CURRENT_TIMESTAMP, 3, TRUE),
(24, 'user24@test.com', 'p24', '유저24', 'alpha001', 4, 480, CURRENT_TIMESTAMP, 4, TRUE),
(25, 'user25@test.com', 'p25', '유저25', 'beta0001', 4, 470, CURRENT_TIMESTAMP, 5, TRUE),
(26, 'user26@test.com', 'p26', '유저26', 'gamma001', 4, 470, CURRENT_TIMESTAMP, 6, TRUE),
(27, 'user27@test.com', 'p27', '유저27', 'delta001', 3, 460, CURRENT_TIMESTAMP, 7, TRUE),
(28, 'user28@test.com', 'p28', '유저28', 'theta001', 3, 450, CURRENT_TIMESTAMP, 8, TRUE),
(29, 'user29@test.com', 'p29', '유저29', 'kappa001', 3, 450, CURRENT_TIMESTAMP, 9, TRUE),
(30, 'user30@test.com', 'p30', '유저30', 'lambda01', 2, 440, CURRENT_TIMESTAMP, 10, TRUE),
(31, 'user31@test.com', 'p31', '유저31', 'omega001', 2, 430, CURRENT_TIMESTAMP, 1, TRUE);


INSERT INTO friends (id,follower_id, followee_id)
VALUES (1,1, 2),
       (2,1, 3),
       (3,1, 6),
       (4,1, 15),
       (5,1, 21);