INSERT INTO badge_category (id, name, created_at, updated_at)
VALUES
    (1, '행성 완료', now(), now()),
    (2, '연속 학습', now(), now()),
    (3, '풀이 속도', now(), now()),
    (4, '미션 완료', now(), now());

INSERT INTO badge
(name, code, description, icon_id, catergory_id, criteria_type, criteria_params, created_at, updated_at)
VALUES
    -- 모든 행성 완료 (올스타)
    ('올스타', 'PLANETS_ALL_COMPLETE', '모든 행성(챕터)을 완료하세요.', 100, 1, 'ALL_PLANETS_COMPLETE', '{}'::jsonb, now(), now()),
    ('지구',   'PLANET_EARTH_COMPLETE',   '지구 행성(챕터)을 완료하세요.',   101, 1, 'PLANET_COMPLETE', '{"planet":"EARTH"}'::jsonb,   now(), now()),
    ('달',     'PLANET_MOON_COMPLETE',    '달 행성(챕터)을 완료하세요.',     102, 1, 'PLANET_COMPLETE', '{"planet":"MOON"}'::jsonb,    now(), now()),
    ('수성',   'PLANET_MERCURY_COMPLETE', '수성 행성(챕터)을 완료하세요.',   103, 1, 'PLANET_COMPLETE', '{"planet":"MERCURY"}'::jsonb, now(), now()),
    ('금성',   'PLANET_VENUS_COMPLETE',   '금성 행성(챕터)을 완료하세요.',   104, 1, 'PLANET_COMPLETE', '{"planet":"VENUS"}'::jsonb,   now(), now()),
    ('화성',   'PLANET_MARS_COMPLETE',    '화성 행성(챕터)을 완료하세요.',   105, 1, 'PLANET_COMPLETE', '{"planet":"MARS"}'::jsonb,    now(), now()),
    ('목성',   'PLANET_JUPITER_COMPLETE', '목성 행성(챕터)을 완료하세요.',   106, 1, 'PLANET_COMPLETE', '{"planet":"JUPITER"}'::jsonb, now(), now()),
    ('토성',   'PLANET_SATURN_COMPLETE',  '토성 행성(챕터)을 완료하세요.',   107, 1, 'PLANET_COMPLETE', '{"planet":"SATURN"}'::jsonb,  now(), now()),
    ('천왕성', 'PLANET_URANUS_COMPLETE',  '천왕성 행성(챕터)을 완료하세요.', 108, 1, 'PLANET_COMPLETE', '{"planet":"URANUS"}'::jsonb,  now(), now());

-- 연속 학습
INSERT INTO badge
(name, code, description, icon_id, catergory_id, criteria_type, criteria_params, created_at, updated_at)
VALUES
    -- 모든 연속 학습 뱃지 획득 완료
    ('올스타', 'STREAK_ALL_STAR', '연속 학습 카테고리의 모든 뱃지를 획득하세요.', 200, 2, 'STREAK_DAYS', '{}'::jsonb, now(), now()),

    ('10일',  'STREAK_10_DAYS',  '연속 학습 10일을 달성하세요.',  201, 2, 'STREAK_DAYS', '{"days":10}'::jsonb,  now(), now()),
    ('30일',  'STREAK_30_DAYS',  '연속 학습 30일을 달성하세요.',  202, 2, 'STREAK_DAYS', '{"days":30}'::jsonb,  now(), now()),
    ('50일',  'STREAK_50_DAYS',  '연속 학습 50일을 달성하세요.',  203, 2, 'STREAK_DAYS', '{"days":50}'::jsonb,  now(), now()),
    ('100일', 'STREAK_100_DAYS', '연속 학습 100일을 달성하세요.', 204, 2, 'STREAK_DAYS', '{"days":100}'::jsonb, now(), now());

-- 풀이 속도 (3분 이내 85% 이상 정답률을 달성한 문제 수)
INSERT INTO badge
(name, code, description, icon_id, catergory_id, criteria_type, criteria_params, created_at, updated_at)
VALUES
    ('올스타', 'SPEED_ALL_STAR', '풀이 속도 카테고리의 모든 뱃지를 획득하세요.', 300, 3, 'SPEED_QUALIFIED_COUNT', '{}'::jsonb, now(), now()),
    ('10개',  'SPEED_QUALIFIED_10',  '2분 이내 85% 이상 정답률로 10개를 달성하세요.',  301, 3, 'SPEED_QUALIFIED_COUNT', '{"count":10}'::jsonb,  now(), now()),
    ('20개',  'SPEED_QUALIFIED_20',  '2분 이내 85% 이상 정답률로 20개를 달성하세요.',  302, 3, 'SPEED_QUALIFIED_COUNT', '{"count":20}'::jsonb,  now(), now()),
    ('30개',  'SPEED_QUALIFIED_30',  '2분 이내 85% 이상 정답률로 30개를 달성하세요.',  303, 3, 'SPEED_QUALIFIED_COUNT', '{"count":30}'::jsonb,  now(), now()),
    ('50개',  'SPEED_QUALIFIED_50',  '2분 이내 85% 이상 정답률로 50개를 달성하세요.',  304, 3, 'SPEED_QUALIFIED_COUNT', '{"count":50}'::jsonb,  now(), now());

-- 미션 완료
INSERT INTO badge
(name, code, description, icon_id, catergory_id, criteria_type, criteria_params, created_at, updated_at)
VALUES
    ('올스타', 'MISSION_ALL_STAR', '미션 완료 카테고리의 모든 뱃지를 획득하세요.', 400, 4, 'MISSION_COUNT', '{}'::jsonb, now(), now()),
    ('10개',  'MISSION_10',  '미션 10개 완료를 달성하세요.',  401, 4, 'MISSION_COUNT', '{"count":10}'::jsonb,  now(), now()),
    ('20개',  'MISSION_20',  '미션 20개 완료를 달성하세요.',  402, 4, 'MISSION_COUNT', '{"count":20}'::jsonb,  now(), now()),
    ('30개',  'MISSION_30',  '미션 30개 완료를 달성하세요.',  403, 4, 'MISSION_COUNT', '{"count":30}'::jsonb,  now(), now()),
    ('50개',  'MISSION_50',  '미션 50개 완료를 달성하세요.',  404, 4, 'MISSION_COUNT', '{"count":50}'::jsonb,  now(), now());