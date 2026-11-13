-- V53__add_users_nickname_lower_stats.sql

-- 닉네임 정확, 접두 검색의 선택도 추정용 표현식 통계
-- 식 인덱스가 부분 인덱스(ix_users_nickname_lower_cover)뿐이라 플래너가 그 통계를 쓰지 못해,
-- 정확 일치 0건 검색어를 0.5%로 추정하고 30만~40만부터 기본키 전체 스캔을 고른다
CREATE STATISTICS IF NOT EXISTS st_users_nickname_lower_c
    ON (lower(nickname) COLLATE "C") FROM users;

-- 통계 값을 바로 채운다. 없으면 다음 자동 ANALYZE까지 통계가 비어 있다
ANALYZE users;
