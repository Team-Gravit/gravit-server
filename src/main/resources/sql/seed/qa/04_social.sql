-- =====================================================================
-- QA 페르소나 데이터셋 04 - 소셜 (social, aux-01 맞팔로우, aux-02 단방향 팔로워)
--
-- friends      : social <-> aux-01, aux-02 -> social
-- social_feed  : social LEVEL_UP '2'(D-1), aux-01 STREAK_DAYS '7'(D-1), aux-01 TIER_PROMOTION '브론즈 2'(D-2)
-- user_feed    : 행위자의 팔로워에게 1행씩 (행위자 본인 행 없음)
-- congratulation: aux-01 -> social LEVEL_UP(D-1), social -> aux-01 TIER_PROMOTION(D-2)
-- notification : social이 받는 알림만 만듭니다 (보조 유저는 로그인하지 않음)
-- =====================================================================

UPDATE users
SET xp = 100,
    level = 2
WHERE email = 'qa-persona-{set}-social@gravit.test';

UPDATE user_league ul
SET league_point = v.league_point,
    league_id = (SELECT l.id FROM league l WHERE v.league_point BETWEEN l.min_lp AND l.max_lp),
    updated_at = now()
FROM users u
JOIN (VALUES
    ('social', 5),
    ('aux-01', 155)
) AS v(key, league_point) ON u.email = 'qa-persona-{set}-' || v.key || '@gravit.test'
WHERE ul.user_id = u.id;

INSERT INTO friends (created_at, updated_at, follower_id, followee_id)
SELECT f.followed_at, f.followed_at, follower.id, followee.id
FROM (VALUES
    ('social', 'aux-01', date_trunc('day', now()) - INTERVAL '5 days' + INTERVAL '20 hours'),
    ('aux-01', 'social', date_trunc('day', now()) - INTERVAL '5 days' + INTERVAL '21 hours'),
    ('aux-02', 'social', date_trunc('day', now()) - INTERVAL '4 days' + INTERVAL '20 hours')
) AS f(follower_key, followee_key, followed_at)
JOIN users follower ON follower.email = 'qa-persona-{set}-' || f.follower_key || '@gravit.test'
JOIN users followee ON followee.email = 'qa-persona-{set}-' || f.followee_key || '@gravit.test';

INSERT INTO social_feed (actor_id, event_type, event_value, created_at, updated_at)
SELECT actor.id, f.event_type, f.event_value, f.published_at, f.published_at
FROM (VALUES
    ('social', 'LEVEL_UP',       '2',      date_trunc('day', now()) - INTERVAL '1 day' + INTERVAL '21 hours'),
    ('aux-01', 'STREAK_DAYS',    '7',      date_trunc('day', now()) - INTERVAL '1 day' + INTERVAL '20 hours 30 minutes'),
    ('aux-01', 'TIER_PROMOTION', '브론즈 2', date_trunc('day', now()) - INTERVAL '2 days' + INTERVAL '20 hours 30 minutes')
) AS f(actor_key, event_type, event_value, published_at)
JOIN users actor ON actor.email = 'qa-persona-{set}-' || f.actor_key || '@gravit.test';

INSERT INTO user_feed (user_id, feed_id, is_hidden, congratulated_at, created_at, updated_at)
SELECT receiver.id, sf.id, false, NULL, sf.created_at, sf.created_at
FROM (VALUES
    ('social', 'LEVEL_UP',       'aux-01'),
    ('social', 'LEVEL_UP',       'aux-02'),
    ('aux-01', 'STREAK_DAYS',    'social'),
    ('aux-01', 'TIER_PROMOTION', 'social')
) AS fan_out(actor_key, event_type, receiver_key)
JOIN users actor ON actor.email = 'qa-persona-{set}-' || fan_out.actor_key || '@gravit.test'
JOIN social_feed sf ON sf.actor_id = actor.id AND sf.event_type = fan_out.event_type
JOIN users receiver ON receiver.email = 'qa-persona-{set}-' || fan_out.receiver_key || '@gravit.test';

INSERT INTO congratulation (user_id, actor_id, feed_id, created_at, updated_at)
SELECT sender.id, actor.id, sf.id, c.congratulated_at, c.congratulated_at
FROM (VALUES
    ('aux-01', 'social', 'LEVEL_UP',       date_trunc('day', now()) - INTERVAL '1 day' + INTERVAL '22 hours'),
    ('social', 'aux-01', 'TIER_PROMOTION', date_trunc('day', now()) - INTERVAL '2 days' + INTERVAL '21 hours')
) AS c(sender_key, actor_key, event_type, congratulated_at)
JOIN users sender ON sender.email = 'qa-persona-{set}-' || c.sender_key || '@gravit.test'
JOIN users actor ON actor.email = 'qa-persona-{set}-' || c.actor_key || '@gravit.test'
JOIN social_feed sf ON sf.actor_id = actor.id AND sf.event_type = c.event_type;

UPDATE user_feed uf
SET congratulated_at = c.created_at
FROM congratulation c
JOIN users sender ON sender.id = c.user_id
WHERE uf.user_id = c.user_id
  AND uf.feed_id = c.feed_id
  AND sender.provider_id LIKE 'qa-persona-{set}-%';

INSERT INTO notification (user_id, message, is_read, type, target_id, sub_text, created_at, updated_at)
SELECT receiver.id, follower.nickname || '님이 나를 팔로우했어요! 👀', false, 'FOLLOW', follower.id, NULL, fr.created_at, fr.created_at
FROM friends fr
JOIN users follower ON follower.id = fr.follower_id
JOIN users receiver ON receiver.id = fr.followee_id
WHERE receiver.email = 'qa-persona-{set}-social@gravit.test';

INSERT INTO notification (user_id, message, is_read, type, target_id, sub_text, created_at, updated_at)
SELECT
    receiver.id,
    CASE sf.event_type
        WHEN 'STREAK_DAYS' THEN actor.nickname || '님이 ' || sf.event_value || '일 연속학습을 달성했어요! 🔥'
        WHEN 'TIER_PROMOTION' THEN actor.nickname || '님이 ' || sf.event_value || '티어로 승급했어요! 🎉'
        WHEN 'LEVEL_UP' THEN actor.nickname || '님이 LV.' || sf.event_value || '이 됐어요! 💪'
    END,
    false,
    'FRIEND_ACTIVITY',
    sf.id,
    NULL,
    sf.created_at,
    sf.created_at
FROM user_feed uf
JOIN social_feed sf ON sf.id = uf.feed_id
JOIN users actor ON actor.id = sf.actor_id
JOIN users receiver ON receiver.id = uf.user_id
WHERE receiver.email = 'qa-persona-{set}-social@gravit.test';

INSERT INTO notification (user_id, message, is_read, type, target_id, sub_text, created_at, updated_at)
SELECT receiver.id, sender.nickname || '님이 축하해줬어요! 🎉', false, 'CONGRATULATION', NULL, NULL, c.created_at, c.created_at
FROM congratulation c
JOIN users sender ON sender.id = c.user_id
JOIN users receiver ON receiver.id = c.actor_id
WHERE receiver.email = 'qa-persona-{set}-social@gravit.test';
