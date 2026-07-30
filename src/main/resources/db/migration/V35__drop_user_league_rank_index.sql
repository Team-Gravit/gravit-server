-- V35__drop_user_league_rank_index.sql

-- 순위 계산이 Redis Sorted Set 으로 이관되어 이 인덱스를 읽는 쿼리가 남지 않는다.
-- league_point 가 인덱스 키에 있어 LP 갱신마다 HOT update 를 막고 있었다(HOT 0% → 95.46%).
-- Redis 장애 시 쓰는 폴백 쿼리는 이 인덱스 없이도 동일하게 동작한다(실측: 목록 51,146 → 51,106 페이지).
DROP INDEX IF EXISTS ix_ul_league_rank;
