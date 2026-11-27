-- PERF-648 시드
-- 대상: GET /api/v1/friends/follower (다음 대상 GET /api/v1/social/feed가 쓸 social_feed, user_feed는 그 대상의 3-A에서 추가)
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

\i .claude/skills/optimize-performance/template/seeds/user.sql
\i .claude/skills/optimize-performance/template/seeds/friend.sql
