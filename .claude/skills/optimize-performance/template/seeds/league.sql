-- 리그 시드: league, season, user_league, user_league_history
--
-- 선행 모듈: user.sql (users)
-- 필요한 변수: user_start, user_count, league_tier_count, past_season_count
--
-- 기존 데이터 존중
--   league: 이미 티어가 하나라도 있으면 그대로 쓴다 (sort_order 유니크 충돌 방지).
--   season: ACTIVE 시즌이 이미 있으면 그 시즌을 쓴다. 새로 만들지 않는다.
--           ACTIVE 시즌이 둘이 되면 애플리케이션의 현재 시즌 조회가 깨진다.
--
-- 재실행 가드: user_league는 (유저, 시즌) 조합이 이미 있으면 건너뛴다.

\echo '[league.sql] league / season / user_league / user_league_history 적재'

BEGIN;

-- 1) league: :league_tier_count 개 티어 (리그가 비어 있을 때만)
INSERT INTO league (id, name, sort_order, min_lp, max_lp)
SELECT t,
       'PERF-TIER-' || t,
       t,
       (t - 1) * 500,
       t * 500 - 1
FROM generate_series(1, :league_tier_count) AS t
WHERE NOT EXISTS (SELECT 1 FROM league)
ON CONFLICT DO NOTHING;

SELECT setval(pg_get_serial_sequence('league', 'id'), (SELECT COALESCE(max(id), 1) FROM league));

-- 2) season: 현재 ACTIVE 1개 (없을 때만) + 과거 CLOSED :past_season_count 개
INSERT INTO season (season_key, status, starts_at, ends_at, tz)
SELECT 'perf-active',
       'ACTIVE',
       now() - INTERVAL '7 days',
       now() + INTERVAL '7 days',
       'Asia/Seoul'
WHERE NOT EXISTS (SELECT 1 FROM season WHERE status = 'ACTIVE')
ON CONFLICT DO NOTHING;

INSERT INTO season (season_key, status, starts_at, ends_at, tz)
SELECT 'perf-past-' || s,
       'CLOSED',
       now() - (s * 14 + 7) * INTERVAL '1 day',
       now() - (s * 14 - 7) * INTERVAL '1 day',
       'Asia/Seoul'
FROM generate_series(1, :past_season_count) AS s
ON CONFLICT DO NOTHING;

-- 3) user_league: 현재 ACTIVE 시즌에 전 유저 배치, LP는 티어 구간에 흩는다
WITH active_season AS (
    SELECT id FROM season WHERE status = 'ACTIVE' ORDER BY starts_at DESC LIMIT 1
),
tier AS (
    SELECT id, row_number() OVER (ORDER BY sort_order) - 1 AS rn, count(*) OVER () AS total
    FROM league
)
INSERT INTO user_league (user_id, season_id, league_id, league_point, created_at, updated_at)
SELECT u.id,
       a.id,
       t.id,
       (u.id * 37) % 2500,
       now() - INTERVAL '7 days',
       now()
FROM users u
CROSS JOIN active_season a
JOIN tier t ON t.rn = (u.id % NULLIF(t.total, 0))
WHERE u.id BETWEEN :user_start AND :user_start + :user_count - 1
  AND NOT EXISTS (
      SELECT 1 FROM user_league ul
      WHERE ul.user_id = u.id AND ul.season_id = a.id
  );

-- 4) user_league_history: 과거 시즌마다 전 유저의 종료 기록
WITH past_season AS (
    SELECT id, row_number() OVER (ORDER BY starts_at DESC) AS seq
    FROM season
    WHERE status = 'CLOSED' AND season_key LIKE 'perf-past-%'
),
tier AS (
    SELECT id, row_number() OVER (ORDER BY sort_order) - 1 AS rn, count(*) OVER () AS total
    FROM league
)
INSERT INTO user_league_history (user_id, season_id, final_league_id, final_lp, final_rank, created_at, updated_at)
SELECT u.id,
       p.id,
       t.id,
       (u.id * 17 + p.seq * 101) % 2500,
       1 + ((u.id + p.seq) % 30),
       now() - INTERVAL '1 day',
       now() - INTERVAL '1 day'
FROM users u
CROSS JOIN past_season p
JOIN tier t ON t.rn = ((u.id + p.seq) % NULLIF(t.total, 0))
WHERE u.id BETWEEN :user_start AND :user_start + :user_count - 1
  AND NOT EXISTS (
      SELECT 1 FROM user_league_history h
      WHERE h.user_id = u.id AND h.season_id = p.id
  );

COMMIT;

ANALYZE league;
ANALYZE season;
ANALYZE user_league;
ANALYZE user_league_history;

-- 검증
SELECT 'league' AS table_name, count(*) AS rows, NULL::bigint AS user_cardinality, NULL::bigint AS season_cardinality FROM league
UNION ALL
SELECT 'season', count(*), NULL, count(*) FILTER (WHERE status = 'ACTIVE') FROM season
UNION ALL
SELECT 'user_league', count(*), count(DISTINCT user_id), count(DISTINCT season_id) FROM user_league
UNION ALL
SELECT 'user_league_history', count(*), count(DISTINCT user_id), count(DISTINCT season_id) FROM user_league_history;
