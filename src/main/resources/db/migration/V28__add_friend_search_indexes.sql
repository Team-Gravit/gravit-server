-- V28__add_friend_search_indexes.sql

-- trigram 확장 활성화
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- is_following 조인용 인덱스
CREATE INDEX IF NOT EXISTS ix_friends_follower_followee
    ON friends (follower_id, followee_id);

-- 닉네임 정확/접두 검색용 커버링 부분 인덱스
CREATE INDEX IF NOT EXISTS ix_users_nickname_lower_cover
    ON users (lower(nickname) COLLATE "C")
    INCLUDE (id, profile_img_number, nickname, handle)
    WHERE deleted_at IS NULL;

-- 닉네임 부분 검색('%x%')용 trigram GIN 인덱스
CREATE INDEX IF NOT EXISTS gin_users_nickname_trgm
    ON users USING gin (nickname gin_trgm_ops);
