-- 외래 키 제약 조건 비활성화
SET session_replication_role = replica;

-- 테이블 데이터 삭제
-- NOTE: mission은 Flyway가 시딩한 정의 테이블이라 지우지 않는다
TRUNCATE TABLE friends CASCADE;
TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE user_league CASCADE;
TRUNCATE TABLE league CASCADE;
TRUNCATE TABLE season CASCADE;
TRUNCATE TABLE user_mission CASCADE;

-- IDENTITY 값 초기화
ALTER TABLE friends ALTER COLUMN id RESTART WITH 1;
ALTER TABLE users ALTER COLUMN id RESTART WITH 1;
ALTER TABLE user_league ALTER COLUMN id RESTART WITH 1;
ALTER TABLE league ALTER COLUMN id RESTART WITH 1;
ALTER TABLE season ALTER COLUMN id RESTART WITH 1;
ALTER TABLE user_mission ALTER COLUMN id RESTART WITH 1;

-- 외래 키 제약 조건 다시 활성화
SET session_replication_role = DEFAULT;