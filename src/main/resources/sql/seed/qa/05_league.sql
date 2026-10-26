-- =====================================================================
-- QA 페르소나 데이터셋 05 - 리그 경계 (league-edge, aux-03 ~ aux-06)
--
-- 실버 2(461 ~ 620)에 league-edge 615와 보조 유저 620, 618, 540, 470을 둡니다.
-- 정확도 28% 이상인 신규 레슨 1개(+6 LP 이상)로 621이 되어 실버 1로 승급합니다.
-- 리그 이력: 가장 최근 CLOSED 시즌이 있으면 1건(최종 실버 1, LP 700, 순위 2), 없으면 넣지 않습니다.
-- =====================================================================

UPDATE user_league ul
SET league_point = v.league_point,
    league_id = (SELECT l.id FROM league l WHERE v.league_point BETWEEN l.min_lp AND l.max_lp),
    updated_at = now()
FROM users u
JOIN (VALUES
    ('league-edge', 615),
    ('aux-03',      620),
    ('aux-04',      618),
    ('aux-05',      540),
    ('aux-06',      470)
) AS v(key, league_point) ON u.email = 'qa-persona-{set}-' || v.key || '@gravit.test'
WHERE ul.user_id = u.id;

INSERT INTO user_league_history (
    final_lp, final_rank, created_at, updated_at, final_league_id, season_id, user_id
)
SELECT
    700,
    2,
    s.ends_at,
    s.ends_at,
    (SELECT l.id FROM league l WHERE 700 BETWEEN l.min_lp AND l.max_lp),
    s.id,
    u.id
FROM users u
CROSS JOIN (
    SELECT id, ends_at
    FROM season
    WHERE status = 'CLOSED'
    ORDER BY ends_at DESC
    LIMIT 1
) AS s
WHERE u.email = 'qa-persona-{set}-league-edge@gravit.test';
