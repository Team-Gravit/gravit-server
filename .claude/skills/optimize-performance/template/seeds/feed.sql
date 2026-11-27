-- 소셜 피드 시드: social_feed, user_feed, congratulation
--
-- 필요한 변수: user_start, user_count, hot_user_count, feed_id_base, feeds_per_actor, feed_window_days,
--             hidden_pct, congrats_per_hot_user
-- 선행 모듈: user, friend
--
-- 배포 구조는 SocialFacade.publishFeed와 같다. 피드 1건은 작성자의 팔로워 전원에게 user_feed 1행씩 배포된다.
-- 그래서 사용자 한 명이 보는 피드 수는 (팔로잉 수 × feeds_per_actor)이고, user_feed 전체는 약 (friends 행 수 × feeds_per_actor)다.
--   social_feed : 유저 범위의 모든 사용자가 작성자. 1명당 feeds_per_actor 건
--   user_feed   : friends의 (follower → followee)를 따라 followee의 피드를 follower에게 배포. hidden_pct % 를 숨김 처리
--   congratulation : hot 사용자가 자기 피드 중 숨기지 않은 최신 congrats_per_hot_user 건을 축하한 상태
--
-- social_feed.id는 feed_id_base 뒤로 직접 매기고, created_at은 id 순서와 같게 feed_window_days 구간에 고르게 편다.
-- 운영에서 created_at은 INSERT 시각이라 IDENTITY id와 순서가 같다. 이 성질을 시드에서도 지킨다.
-- 적재 후 IDENTITY 시퀀스를 max(id)로 맞춘다. 맞추지 않으면 앱이 만드는 다음 피드가 시드 id와 충돌한다.
--
-- 시드 범위는 id [feed_id_base + 1, feed_id_base + user_count * feeds_per_actor]다. 앱이나 다른 시드가 만든 피드의 id가 이 범위 뒤에 있을 수 있으므로
-- 배포, 축하, 검증은 모두 상한까지 건 범위로 거른다. `id > feed_id_base`로 줄이지 마라.
--
-- 재실행 가드: social_feed와 user_feed는 대표 행(feed_id_base + 1) 존재 여부, congratulation은 (user_id, feed_id) 유니크 기준.
-- 가드를 지우지 마라.

\echo '[feed.sql] social_feed 적재'

BEGIN;

-- 순번 s = (k - 1) * user_count + (작성자 - user_start), 0부터. id와 created_at이 모두 s를 따라 증가한다
INSERT INTO social_feed (id, actor_id, event_type, event_value, created_at, updated_at)
SELECT :feed_id_base + s + 1,
       :user_start + (s % :user_count),
       (ARRAY['PLANET_COMPLETE', 'STREAK_DAYS', 'TIER_PROMOTION', 'LEVEL_UP'])[(s % 4) + 1],
       (ARRAY['perf-planet', '7', 'perf-tier', '10'])[(s % 4) + 1],
       now() - (:feed_window_days * INTERVAL '1 day')
           + (s::bigint * :feed_window_days * 86400 / (:user_count::bigint * :feeds_per_actor)) * INTERVAL '1 second',
       now()
FROM generate_series(0, :user_count * :feeds_per_actor - 1) AS g(s)
WHERE NOT EXISTS (SELECT 1 FROM social_feed x WHERE x.id = :feed_id_base + 1);

SELECT setval(pg_get_serial_sequence('social_feed', 'id'), (SELECT max(id) FROM social_feed));

COMMIT;

\echo '[feed.sql] user_feed 적재 (팔로워에게 배포)'

BEGIN;

INSERT INTO user_feed (user_id, feed_id, is_hidden, congratulated_at, created_at, updated_at)
SELECT f.follower_id,
       sf.id,
       ((sf.id * 31 + f.follower_id) % 100) < :hidden_pct,
       NULL,
       sf.created_at,
       sf.created_at
FROM social_feed sf
JOIN friends f ON f.followee_id = sf.actor_id
WHERE sf.id BETWEEN :feed_id_base + 1 AND :feed_id_base + :user_count * :feeds_per_actor
  AND f.follower_id BETWEEN :user_start AND :user_start + :user_count - 1
  AND NOT EXISTS (SELECT 1 FROM user_feed x WHERE x.feed_id = :feed_id_base + 1);

COMMIT;

ANALYZE social_feed;
ANALYZE user_feed;

\echo '[feed.sql] congratulation 적재 (hot 사용자의 최신 피드)'

BEGIN;

WITH picked AS (
    SELECT uf.user_id, sf.actor_id, sf.id AS feed_id
    FROM (
        SELECT uf.user_id, uf.feed_id,
               row_number() OVER (PARTITION BY uf.user_id ORDER BY sf.created_at DESC, sf.id DESC) AS rn
        FROM user_feed uf
        JOIN social_feed sf ON sf.id = uf.feed_id
        WHERE uf.user_id BETWEEN :user_start AND :user_start + :hot_user_count - 1
          AND uf.is_hidden = false
          AND sf.id BETWEEN :feed_id_base + 1 AND :feed_id_base + :user_count * :feeds_per_actor
    ) uf
    JOIN social_feed sf ON sf.id = uf.feed_id
    WHERE uf.rn <= :congrats_per_hot_user
), inserted AS (
    INSERT INTO congratulation (user_id, actor_id, feed_id, created_at, updated_at)
    SELECT p.user_id, p.actor_id, p.feed_id, now(), now()
    FROM picked p
    WHERE NOT EXISTS (SELECT 1 FROM congratulation c WHERE c.user_id = p.user_id AND c.feed_id = p.feed_id)
    RETURNING user_id, feed_id
)
UPDATE user_feed uf
SET congratulated_at = now()
FROM inserted i
WHERE uf.user_id = i.user_id AND uf.feed_id = i.feed_id;

COMMIT;

ANALYZE congratulation;

-- 검증
SELECT 'social_feed' AS table_name,
       count(*)                 AS rows_in_seed_range,
       count(DISTINCT actor_id) AS actor_cardinality,
       min(created_at)          AS min_created_at,
       max(created_at)          AS max_created_at
FROM social_feed
WHERE id BETWEEN :feed_id_base + 1 AND :feed_id_base + :user_count * :feeds_per_actor;

SELECT 'id_created_at_inversions' AS metric, count(*) AS inversions
FROM (SELECT created_at, lag(created_at) OVER (ORDER BY id) AS prev
      FROM social_feed
      WHERE id BETWEEN :feed_id_base + 1 AND :feed_id_base + :user_count * :feeds_per_actor) s
WHERE created_at < prev;

SELECT 'user_feed' AS table_name,
       count(*)                                    AS rows_in_seed_range,
       count(DISTINCT user_id)                     AS user_cardinality,
       count(DISTINCT feed_id)                     AS feed_cardinality,
       round(100.0 * count(*) FILTER (WHERE is_hidden) / count(*), 2) AS hidden_pct
FROM user_feed
WHERE feed_id BETWEEN :feed_id_base + 1 AND :feed_id_base + :user_count * :feeds_per_actor;

SELECT 'hot_user_feeds' AS metric,
       min(total) AS min_total, max(total) AS max_total,
       min(visible) AS min_visible, max(visible) AS max_visible,
       count(*) AS hot_users
FROM (SELECT user_id, count(*) AS total, count(*) FILTER (WHERE NOT is_hidden) AS visible
      FROM user_feed
      WHERE user_id BETWEEN :user_start AND :user_start + :hot_user_count - 1
        AND feed_id BETWEEN :feed_id_base + 1 AND :feed_id_base + :user_count * :feeds_per_actor
      GROUP BY user_id) s;

SELECT 'base_user_feeds' AS metric,
       min(total) AS min_total, max(total) AS max_total, round(avg(total), 2) AS avg_total
FROM (SELECT user_id, count(*) AS total
      FROM user_feed
      WHERE user_id BETWEEN :user_start + :hot_user_count AND :user_start + :user_count - 1
        AND feed_id BETWEEN :feed_id_base + 1 AND :feed_id_base + :user_count * :feeds_per_actor
      GROUP BY user_id) s;

SELECT 'congratulation' AS table_name,
       sum(c)   AS rows_in_seed_range,
       count(*) AS user_cardinality,
       min(c)   AS min_per_user,
       max(c)   AS max_per_user
FROM (SELECT user_id, count(*) AS c
      FROM congratulation
      WHERE feed_id BETWEEN :feed_id_base + 1 AND :feed_id_base + :user_count * :feeds_per_actor
      GROUP BY user_id) s;
