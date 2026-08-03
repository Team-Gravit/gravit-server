-- V37__add_user_league_history_user_season_index.sql

-- user_league_history에는 PK 인덱스만 있어 user_id로 행을 찾는 조회가 전부 풀스캔이었다.
-- FK 제약이 걸려 있지만 PostgreSQL은 참조 측 컬럼에 인덱스를 만들어 주지 않는다.
-- 시즌이 닫힐 때마다 유저 수만큼 행이 쌓이는 테이블이라(4개월 주기 기준 1년이면 유저당 3행)
-- 방치하면 스캔 비용이 시즌 수에 비례해 커진다.
--
-- 선두 키는 등호 조건인 user_id다. 리그 이력 조회(findAllByUserIdOrderBySeason)가 user_id만으로 필터하므로
-- 이 컬럼이 앞에 있어야 두 조회 형태를 하나의 인덱스로 받을 수 있다.
-- season_id를 두 번째 키로 붙이는 이유는 리그 홈의 지난 시즌 팝업 판정이
-- (user_id, season_id)로 존재 확인과 단건 조회를 연달아 하기 때문이다. 둘 다 등호 조건이라
-- 선두 키만으로 좁힌 뒤 남는 행을 season_id로 바로 지목할 수 있다.
--
-- 정렬 키인 season.starts_at은 조인된 테이블의 컬럼이라 이 인덱스로 해소되지 않는다.
-- 유저당 행 수가 시즌 수만큼이라 정렬 대상이 애초에 작으므로 컬럼을 더 늘리지 않는다.
CREATE INDEX IF NOT EXISTS ix_user_league_history_user_season
    ON user_league_history (user_id, season_id);
