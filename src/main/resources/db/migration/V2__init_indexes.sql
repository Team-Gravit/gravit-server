-- V2__init_indexes.sql

-- 0) 확장
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1) 프리픽스 검색 (handle이 VARCHAR이므로 varchar_pattern_ops!)
CREATE INDEX IF NOT EXISTS ix_users_handle_like_with_id
    ON users (handle varchar_pattern_ops, id);

-- 2) 커버링 인덱스 (친구 조회 프로필 조회용)
CREATE INDEX IF NOT EXISTS ix_users_friends_covering
    ON users (handle, id) INCLUDE (profile_img_number, nickname);

-- 3) 포함 검색('%...%')용 trigram GIN
CREATE INDEX IF NOT EXISTS gin_users_handle_trgm
    ON users USING gin (handle gin_trgm_ops);

-- 4) 리그 랭킹 조회
CREATE INDEX IF NOT EXISTS ix_ul_league_rank
    ON user_league (league_id, league_point DESC, user_id);

-- 5) 커버링 인덱스 (유저 조회 프로필 조회용)
CREATE INDEX IF NOT EXISTS ix_users_cover
    ON users (id) INCLUDE (nickname, profile_img_number, level);

