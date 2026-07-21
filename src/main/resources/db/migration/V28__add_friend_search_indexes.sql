-- V28__add_friend_search_indexes.sql
-- 친구 검색(닉네임) 및 is_following 조인 성능 개선용 인덱스.
-- 근거: docs/friend-search-strategy.md "DB Access Patterns 기반 개선안" 섹션.
-- 주의: 이 파일은 초안이다. 반드시 EXPLAIN (ANALYZE, BUFFERS)로 적용 전후를 실측한 뒤 확정한다.

-- trigram 확장은 V2에서 이미 활성화되어 있으나, 순서 독립성을 위해 방어적으로 재확인한다.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1) is_following 조인 인덱스
--    friends 테이블에는 현재 PK(id)만 있어, LEFT JOIN friends (follower_id=me AND followee_id=s.id)가
--    인덱스를 못 타고 매 후보 행마다 랜덤 액세스를 유발한다.
--    선행 컬럼 follower_id에 상수(me)가 걸리므로 Seek + 좁은 Range가 되고,
--    "팔로우 여부" 존재 확인만 필요하므로 별도 INCLUDE 없이 Index-Only 프로브가 된다.
--    (팔로잉 목록 조회 findByFollowerId 경로도 함께 이득)
CREATE INDEX IF NOT EXISTS ix_friends_follower_followee
    ON friends (follower_id, followee_id);

-- 2) 닉네임 정확/접두 검색용 커버링(표현식) 부분 인덱스
--    SQL이 lower(nickname)으로 비교/정렬하므로 반드시 lower() 표현식 인덱스여야 한다.
--    text_pattern_ops로 LIKE 'x%' 접두 검색이 로케일과 무관하게 인덱스를 타게 한다.
--    INCLUDE에는 SELECT가 반환하는 컬럼(id, profile_img_number, nickname, handle)을 모두 담는다.
--      - 인덱스 키는 lower(nickname)이므로 원본 nickname은 파생되지 않는다 → nickname을 반드시 포함해야
--        heap 방문 없는 Index-Only Scan이 된다. (벤치 실측: 미포함 시 Bitmap Heap Scan로 폴백)
--    WHERE deleted_at IS NULL 부분 인덱스로 검색 대상만 인덱싱 → 크기 축소 + 필터가 인덱스에 반영.
--    (Index-Only Scan 실효는 autovacuum의 가시성 맵 최신화에 의존한다)
CREATE INDEX IF NOT EXISTS ix_users_nickname_lower_cover
    ON users (lower(nickname) text_pattern_ops)
    INCLUDE (id, profile_img_number, nickname, handle)
    WHERE deleted_at IS NULL;

-- 3) 닉네임 부분 검색('%x%')용 trigram GIN
--    ILIKE '%x%'를 위한 인덱스. 단, 흔한 한글 음절 등 저선택도 검색어에서는
--    옵티마이저가 여전히 스캔을 택할 수 있다(=근본 해결 아님). 실측으로 효과 범위를 확인한다.
CREATE INDEX IF NOT EXISTS gin_users_nickname_trgm
    ON users USING gin (nickname gin_trgm_ops);
