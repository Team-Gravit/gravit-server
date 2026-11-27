-- 팔로우 시드: friends
--
-- 필요한 변수: user_start, user_count, hot_user_count, hot_followers, follows_per_user, follow_stride,
--             mutual_pct, follow_window_days
-- 선행 모듈: user
--
-- 유저 범위 [user_start, user_start + user_count) 를 두 무리로 나눈다.
--   hot  : 앞쪽 hot_user_count 명. k6가 로그인하는 측정 사용자. 팔로워를 정확히 hot_followers 명씩 갖는다
--   base : 나머지. 각자 base 무리 안에서 follows_per_user 명을 팔로우한다 (팔로워도 평균 follows_per_user 명)
-- hot 사용자는 자기 팔로워 중 앞쪽 mutual_pct % 를 맞팔로우한다 (팔로워 목록의 f2 조인 대상).
--
-- 세 묶음은 (follower, followee) 쌍이 겹치지 않는다.
--   base  : base → base
--   hot   : base → hot
--   mutual: hot  → base
-- friends에 유니크 제약이 없으므로 재실행 가드는 묶음마다 대표 쌍 하나를 (follower_id, followee_id) 인덱스로 확인한다.
-- 가드를 지우지 마라.
--
-- follow_stride: base 무리에서 i번째 사용자가 (i + k * stride) mod M 번째를 팔로우한다 (k = 1..follows_per_user, M = base 인원).
-- k * stride mod M 이 k마다 서로 다르고 0이 아니어야 중복, 자기 팔로우가 생기지 않는다.
-- M = 99900, follows_per_user = 20 이면 stride = 4999 가 조건을 만족한다. 규모를 바꾸면 이 조건을 다시 확인한다.
--
-- created_at은 follow_window_days 안에 흩어 둔다. 팔로워 목록이 created_at 역순으로 정렬하므로 한 시각에 몰리지 않게 한다.
-- 흩는 식의 곱셈은 integer 범위를 넘으므로 bigint로 계산한다.

\echo '[friend.sql] friends 적재'

BEGIN;

-- base → base
INSERT INTO friends (follower_id, followee_id, created_at, updated_at)
SELECT f.id,
       :user_start + :hot_user_count
           + (((f.id - :user_start - :hot_user_count) + k * :follow_stride) % (:user_count - :hot_user_count)),
       now() - ((f.id::bigint * 7919 + k::bigint * 104729) % (:follow_window_days * 86400)) * INTERVAL '1 second',
       now()
FROM generate_series(:user_start + :hot_user_count, :user_start + :user_count - 1) AS f(id)
CROSS JOIN generate_series(1, :follows_per_user) AS k
WHERE NOT EXISTS (
    SELECT 1 FROM friends x
    WHERE x.follower_id = f.id
      AND x.followee_id = :user_start + :hot_user_count
              + (((f.id - :user_start - :hot_user_count) + :follow_stride) % (:user_count - :hot_user_count))
);

-- base → hot (hot 사용자마다 팔로워 hot_followers 명)
INSERT INTO friends (follower_id, followee_id, created_at, updated_at)
SELECT :user_start + :hot_user_count
           + (((h.id - :user_start) * :hot_followers + j) % (:user_count - :hot_user_count)),
       h.id,
       now() - ((h.id::bigint * 104729 + j::bigint * 7919) % (:follow_window_days * 86400)) * INTERVAL '1 second',
       now()
FROM generate_series(:user_start, :user_start + :hot_user_count - 1) AS h(id)
CROSS JOIN generate_series(0, :hot_followers - 1) AS j
WHERE NOT EXISTS (
    SELECT 1 FROM friends x
    WHERE x.followee_id = h.id
      AND x.follower_id = :user_start + :hot_user_count
              + (((h.id - :user_start) * :hot_followers) % (:user_count - :hot_user_count))
);

-- hot → base (팔로워 중 앞쪽 mutual_pct % 맞팔)
INSERT INTO friends (follower_id, followee_id, created_at, updated_at)
SELECT h.id,
       :user_start + :hot_user_count
           + (((h.id - :user_start) * :hot_followers + j) % (:user_count - :hot_user_count)),
       now() - ((h.id::bigint * 15485863 + j::bigint * 7919) % (:follow_window_days * 86400)) * INTERVAL '1 second',
       now()
FROM generate_series(:user_start, :user_start + :hot_user_count - 1) AS h(id)
CROSS JOIN generate_series(0, (:hot_followers * :mutual_pct / 100) - 1) AS j
WHERE NOT EXISTS (
    SELECT 1 FROM friends x
    WHERE x.follower_id = h.id
      AND x.followee_id = :user_start + :hot_user_count
              + (((h.id - :user_start) * :hot_followers) % (:user_count - :hot_user_count))
);

COMMIT;

ANALYZE friends;

-- 검증
SELECT 'friends' AS table_name,
       count(*)                                                AS rows_in_seed_range,
       count(DISTINCT followee_id)                             AS followee_cardinality,
       count(DISTINCT follower_id)                             AS follower_cardinality,
       count(*) FILTER (WHERE follower_id = followee_id)       AS self_follows,
       min(created_at)                                         AS min_created_at,
       max(created_at)                                         AS max_created_at
FROM friends
WHERE follower_id BETWEEN :user_start AND :user_start + :user_count - 1;

SELECT 'hot_followers' AS metric,
       min(c) AS min_followers, max(c) AS max_followers, count(*) AS hot_users
FROM (SELECT followee_id, count(*) AS c
      FROM friends
      WHERE followee_id BETWEEN :user_start AND :user_start + :hot_user_count - 1
      GROUP BY followee_id) s;

SELECT 'hot_mutual' AS metric,
       min(c) AS min_mutual, max(c) AS max_mutual
FROM (SELECT follower_id, count(*) AS c
      FROM friends
      WHERE follower_id BETWEEN :user_start AND :user_start + :hot_user_count - 1
      GROUP BY follower_id) s;

SELECT 'duplicate_pairs' AS metric, count(*) AS pairs
FROM (SELECT follower_id, followee_id
      FROM friends
      WHERE follower_id BETWEEN :user_start AND :user_start + :user_count - 1
      GROUP BY follower_id, followee_id
      HAVING count(*) > 1) d;
