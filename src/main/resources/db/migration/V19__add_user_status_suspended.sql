-- users.status CHECK 제약에 SUSPENDED 추가 (admin 계정 정지 기능)
-- V1 의 인라인 CHECK 는 Postgres 기본명 users_status_check 로 생성됨.
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_status_check;
ALTER TABLE users ADD CONSTRAINT users_status_check
    CHECK (status IN ('ACTIVE', 'SUSPENDED', 'DELETED'));
