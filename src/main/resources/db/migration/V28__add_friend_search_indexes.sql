-- V28__add_friend_search_indexes.sql
-- 친구 검색(닉네임) 및 is_following 조인 성능 개선용 인덱스.
-- 설계 근거와 실측치: docs/retrospective-friend-search.md

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1) is_following 조인용. friends에 PK만 있어 LEFT JOIN이 매 후보 행마다 랜덤 액세스를 유발했다.
--    선행 컬럼에 상수(me)가 걸려 좁은 range seek이 되고, 존재 확인만 필요해 INCLUDE가 없어도 Index-Only가 된다.
CREATE INDEX IF NOT EXISTS ix_friends_follower_followee
    ON friends (follower_id, followee_id);

-- 2) 닉네임 정확/접두 검색용 커버링 부분 인덱스.
--    COLLATE "C": text_pattern_ops를 쓰면 정렬 pathkey가 ~<~ 패밀리라 ORDER BY와 매칭되지 않아
--                 조기 종료가 불가능하다. 기본 연산자 클래스 + C 콜레이션이라야 둘 다 만족한다.
--                 이 인덱스를 쓰는 쿼리는 ORDER BY와 = 비교에 COLLATE "C"를 명시해야 한다.
--                 (LIKE 'x%'는 플래너가 범위를 도출해주므로 불필요)
--    INCLUDE: 키가 lower(nickname)이라 원본 nickname이 파생되지 않는다. SELECT 반환 컬럼을 모두
--             담아야 heap 방문이 사라진다. 하나라도 빠지면 Bitmap Heap Scan으로 폴백한다.
CREATE INDEX IF NOT EXISTS ix_users_nickname_lower_cover
    ON users (lower(nickname) COLLATE "C")
    INCLUDE (id, profile_img_number, nickname, handle)
    WHERE deleted_at IS NULL;

-- 3) 닉네임 부분 검색('%x%')용 trigram GIN.
--    선택도가 높을 때만 이 인덱스가 이기고, 낮을 때는 2)의 커버링 btree 조기 종료가 이긴다.
--    플래너가 두 구간을 알아서 가른다.
CREATE INDEX IF NOT EXISTS gin_users_nickname_trgm
    ON users USING gin (nickname gin_trgm_ops);
