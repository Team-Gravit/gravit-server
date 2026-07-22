-- V28__convert_lesson_submission_to_history.sql
-- 레슨 제출을 유저+레슨당 1행 덮어쓰기에서 제출마다 새 행을 쌓는 이력 구조로 전환

-- 시도 횟수는 엔티티 필드 대신 행 개수로 센다
ALTER TABLE lesson_submission
    DROP COLUMN try_count;

-- 주간 리포트 기준 시각이 created_at으로 바뀌므로, V7 이전 행의 빈 created_at을 채운다
UPDATE lesson_submission
SET created_at = COALESCE(updated_at, NOW())
WHERE created_at IS NULL;
