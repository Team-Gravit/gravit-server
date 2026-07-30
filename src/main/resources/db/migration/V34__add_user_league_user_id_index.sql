-- V34__add_user_league_user_id_index.sql

-- LP 적립의 진입 조회(findByUserId)와 /ranking/me 가 user_id 로 행을 찾는데 인덱스가 없어
-- 매번 테이블 전체를 훑고 있었다. 유저 100만 기준 쓰기 최대 TPS 315 → 32,100.
CREATE INDEX IF NOT EXISTS ix_ul_user_id ON user_league (user_id);
