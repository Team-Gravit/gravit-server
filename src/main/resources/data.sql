INSERT INTO league (id, name, min_lp, max_lp, sort_order)
VALUES (1, '브론즈 3', 0, 100, 1),
       (2, '브론즈 2', 101, 200, 2),
       (3, '브론즈 1', 201, 320, 3),

       (4, '실버 3', 321, 460, 4),
       (5, '실버 2', 461, 620, 5),
       (6, '실버 1', 621, 800, 6),

       (7, '골드 3', 801, 1000, 7),
       (8, '골드 2', 1001, 1220, 8),
       (9, '골드 1', 1221, 1460, 9),

       (10, '플래티넘 3', 1461, 1720, 10),
       (11, '플래티넘 2', 1721, 2000, 11),
       (12, '플래티넘 1', 2001, 2300, 12),

       (13, '다이아몬드 3', 2301, 2620, 13),
       (14, '다이아몬드 2', 2621, 2960, 14),
       (15, '다이아몬드 1', 2961, 9999, 15);

INSERT INTO badge_category (id, name, display_order, description, created_at, updated_at)
VALUES
    (1, '행성 완료', 1, '챕터 완료시 각 챕터에 맞는 행성 뱃지 획득', now(), now()),
    (2, '연속 학습', 2, '매일 한 개 이상의 레슨 풀이시, 연속학습 유지', now(), now()),
    (3, '풀이 속도', 3, '85% 이상의 정답률만 인정해요', now(), now()),
    (4, '미션 완료', 4, '오늘의 미션을 특정 개수 이상 완료시 획득', now(), now());

INSERT INTO badge
(name, code, description, icon_id, category_id, display_order, criteria_type, criteria_params, created_at, updated_at)
VALUES
    -- 모든 행성 완료 (올스타)
    ('올스타', 'PLANETS_ALL_COMPLETE', '모든 행성(챕터)을 완료하세요.', 100, 1,1, 'ALL_PLANETS_COMPLETE', '{}'::jsonb, now(), now()),
    ('지구',   'PLANET_EARTH_COMPLETE',   '지구 행성(챕터)을 완료하세요.',   101, 1,2,  'PLANET_COMPLETE', '{"planet":"EARTH"}'::jsonb,   now(), now()),
    ('달',     'PLANET_MOON_COMPLETE',    '달 행성(챕터)을 완료하세요.',     102, 1, 3, 'PLANET_COMPLETE', '{"planet":"MOON"}'::jsonb,    now(), now()),
    ('수성',   'PLANET_MERCURY_COMPLETE', '수성 행성(챕터)을 완료하세요.',   103, 1,4,  'PLANET_COMPLETE', '{"planet":"MERCURY"}'::jsonb, now(), now()),
    ('금성',   'PLANET_VENUS_COMPLETE',   '금성 행성(챕터)을 완료하세요.',   104, 1, 5, 'PLANET_COMPLETE', '{"planet":"VENUS"}'::jsonb,   now(), now()),
    ('화성',   'PLANET_MARS_COMPLETE',    '화성 행성(챕터)을 완료하세요.',   105, 1, 6, 'PLANET_COMPLETE', '{"planet":"MARS"}'::jsonb,    now(), now()),
    ('목성',   'PLANET_JUPITER_COMPLETE', '목성 행성(챕터)을 완료하세요.',   106, 1, 7, 'PLANET_COMPLETE', '{"planet":"JUPITER"}'::jsonb, now(), now()),
    ('토성',   'PLANET_SATURN_COMPLETE',  '토성 행성(챕터)을 완료하세요.',   107, 1, 8,'PLANET_COMPLETE', '{"planet":"SATURN"}'::jsonb,  now(), now()),
    ('천왕성', 'PLANET_URANUS_COMPLETE',  '천왕성 행성(챕터)을 완료하세요.', 108, 1, 9, 'PLANET_COMPLETE', '{"planet":"URANUS"}'::jsonb,  now(), now());

-- 연속 학습
INSERT INTO badge
(name, code, description, icon_id, category_id, display_order, criteria_type, criteria_params, created_at, updated_at)
VALUES
    -- 모든 연속 학습 뱃지 획득 완료
    ('올스타', 'STREAK_ALL_STAR', '연속 학습 카테고리의 모든 뱃지를 획득하세요.', 200, 2, 1,'STREAK_DAYS', '{}'::jsonb, now(), now()),

    ('10일',  'STREAK_10_DAYS',  '연속 학습 10일을 달성하세요.',  201, 2,2,  'STREAK_DAYS', '{"days":10}'::jsonb,  now(), now()),
    ('30일',  'STREAK_30_DAYS',  '연속 학습 30일을 달성하세요.',  202, 2, 3, 'STREAK_DAYS', '{"days":30}'::jsonb,  now(), now()),
    ('50일',  'STREAK_50_DAYS',  '연속 학습 50일을 달성하세요.',  203, 2, 4, 'STREAK_DAYS', '{"days":50}'::jsonb,  now(), now()),
    ('100일', 'STREAK_100_DAYS', '연속 학습 100일을 달성하세요.', 204, 2, 5, 'STREAK_DAYS', '{"days":100}'::jsonb, now(), now());

-- 풀이 속도 (3분 이내 85% 이상 정답률을 달성한 문제 수)
INSERT INTO badge
(name, code, description, icon_id, category_id, display_order, criteria_type, criteria_params, created_at, updated_at)
VALUES
    ('올스타', 'SPEED_ALL_STAR', '풀이 속도 카테고리의 모든 뱃지를 획득하세요.', 300, 3,1,  'SPEED_QUALIFIED_COUNT', '{}'::jsonb, now(), now()),
    ('10개',  'SPEED_QUALIFIED_10',  '2분 이내 85% 이상 정답률로 10개를 달성하세요.',  301, 3, 2, 'SPEED_QUALIFIED_COUNT', '{"count":10}'::jsonb,  now(), now()),
    ('20개',  'SPEED_QUALIFIED_20',  '2분 이내 85% 이상 정답률로 20개를 달성하세요.',  302, 3,3,  'SPEED_QUALIFIED_COUNT', '{"count":20}'::jsonb,  now(), now()),
    ('30개',  'SPEED_QUALIFIED_30',  '2분 이내 85% 이상 정답률로 30개를 달성하세요.',  303, 3,4,  'SPEED_QUALIFIED_COUNT', '{"count":30}'::jsonb,  now(), now()),
    ('50개',  'SPEED_QUALIFIED_50',  '2분 이내 85% 이상 정답률로 50개를 달성하세요.',  304, 3,5,  'SPEED_QUALIFIED_COUNT', '{"count":50}'::jsonb,  now(), now());

-- 미션 완료
INSERT INTO badge
(name, code, description, icon_id, category_id, display_order, criteria_type, criteria_params, created_at, updated_at)
VALUES
    ('올스타', 'MISSION_ALL_STAR', '미션 완료 카테고리의 모든 뱃지를 획득하세요.', 400, 4, 1, 'MISSION_COUNT', '{}'::jsonb, now(), now()),
    ('10개',  'MISSION_10',  '미션 10개 완료를 달성하세요.',  401, 4, 2, 'MISSION_COUNT', '{"count":10}'::jsonb,  now(), now()),
    ('20개',  'MISSION_20',  '미션 20개 완료를 달성하세요.',  402, 4, 3, 'MISSION_COUNT', '{"count":20}'::jsonb,  now(), now()),
    ('30개',  'MISSION_30',  '미션 30개 완료를 달성하세요.',  403, 4, 4, 'MISSION_COUNT', '{"count":30}'::jsonb,  now(), now()),
    ('50개',  'MISSION_50',  '미션 50개 완료를 달성하세요.',  404, 4, 5, 'MISSION_COUNT', '{"count":50}'::jsonb,  now(), now());

