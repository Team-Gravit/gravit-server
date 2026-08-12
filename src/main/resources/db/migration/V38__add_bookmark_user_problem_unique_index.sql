-- V38__add_bookmark_user_problem_unique_index.sql

-- 유닛별 북마크 문제 조회(GET /api/v1/bookmarks/{unitId})가 bookmark를 user_id로 거르지만
-- bookmark에는 PK 인덱스만 있어 매번 전체 스캔이 발생한다.
-- 156,000행 기준 실행계획에서 155,844행(99.9%)을 필터로 버리고 156행만 남기며,
-- 이 노드 하나가 쿼리 실행시간의 84%와 만진 페이지의 87.9%를 차지한다.
-- user_id를 선두 키로 두어 user_id 단독으로 필터하는 북마크 개수 조회도 같은 인덱스를 타게 한다.
-- 북마크는 유저와 문제 단위로 하나만 존재하고 BookmarkService가 이미 그 전제로 동작하므로
-- (addBookmark가 중복 시 BOOKMARK_DUPLICATED를 던지고 deleteByProblemIdAndUserId가 그 쌍으로 단건을 지운다)
-- UNIQUE로 제약을 명시해 조회 후 저장 사이의 경쟁으로 중복 행이 생기는 것을 DB가 막는다.
CREATE UNIQUE INDEX IF NOT EXISTS ix_bookmark_user_problem
    ON bookmark (user_id, problem_id);
