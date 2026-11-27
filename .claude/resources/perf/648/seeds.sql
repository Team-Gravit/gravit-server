-- PERF-648 시드
-- 대상: GET /api/v1/friends/follower, GET /api/v1/social/feed (social_feed, user_feed, congratulation은 feed 대상의 3-A에서 추가)
--
-- k6: USER_ID_START = 1001, USER_COUNT = 100 (hot 사용자)

\set user_start 1001
\set user_count 100000

\set hot_user_count 100
\set hot_followers 1000
\set follows_per_user 20
\set follow_stride 4999
\set mutual_pct 30
\set follow_window_days 365

\set feed_id_base 1000000
\set feeds_per_actor 5
\set feed_window_days 365
\set hidden_pct 5
\set congrats_per_hot_user 2

\i .claude/skills/optimize-performance/template/seeds/user.sql
\i .claude/skills/optimize-performance/template/seeds/friend.sql
\i .claude/skills/optimize-performance/template/seeds/feed.sql
