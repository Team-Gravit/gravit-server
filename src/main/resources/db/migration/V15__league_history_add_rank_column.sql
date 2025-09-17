-- V15__league_history_add_rank_column.sql

-- 1) 컬럼 추가 (없으면)
ALTER TABLE user_league_history
    ADD COLUMN IF NOT EXISTS final_rank INTEGER;

ALTER TABLE user_league_history
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP(6);

-- 2) updated_at 백필: 기존 행은 created_at로 채움
UPDATE user_league_history
SET updated_at = created_at
WHERE updated_at IS NULL;

-- 3) final_rank 백필: 시즌·리그별 DENSE_RANK (lp 내림차순, created_at 오름차순, user_id 오름차순)
WITH ranked AS (
    SELECT
        id,
        DENSE_RANK() OVER (
      PARTITION BY season_id, final_league_id
      ORDER BY final_lp DESC, created_at ASC, user_id ASC
    ) AS rk
    FROM user_league_history
)

UPDATE user_league_history h
SET final_rank = r.rk
    FROM ranked r
WHERE h.id = r.id
  AND h.final_rank IS NULL;

-- 4) 제약/기본값 설정
ALTER TABLE user_league_history
    ALTER COLUMN updated_at SET NOT NULL;

ALTER TABLE user_league_history
    ALTER COLUMN final_rank SET NOT NULL;

ALTER TABLE user_league_history
    ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP(6);

-- 5) 조회 최적화 인덱스
CREATE INDEX IF NOT EXISTS idx_ulh_season_league_rank
    ON user_league_history (season_id, final_league_id, final_rank);

CREATE INDEX IF NOT EXISTS idx_ulh_user
    ON user_league_history (user_id);
