-- V39__relax_learning_version.sql

-- Learning의 낙관적 락을 제거하면서 @Version 매핑이 사라진다.
-- 컬럼을 지금 드롭하면 rollback-prod가 예전 이미지를 되돌릴 때
-- Flyway는 되감기지 않아 예전 코드의 learning INSERT/UPDATE가 전부 깨진다.
-- 이번엔 기본값만 주어 매핑 없는 INSERT가 NOT NULL을 만족하게 하고,
-- 컬럼 드롭은 배포 안정화 확인 후 후속 이슈로 분리한다.
ALTER TABLE learning
    ALTER COLUMN version SET DEFAULT 0;
