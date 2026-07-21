-- V27__add_submission_history_to_problem_submission.sql
-- problem_submission에 BaseEntity 공통 컬럼(created_at, updated_at) 추가
-- 기존 레코드는 NULL 허용 (제출 시점 정보 부재)
ALTER TABLE problem_submission
    ADD COLUMN created_at TIMESTAMP(6),
    ADD COLUMN updated_at TIMESTAMP(6);

-- 사용자가 실제 제출한 답안 기록 (객관식은 selected_option_id, 주관식은 submitted_content)
-- 문제 유형에 따라 둘 중 하나만 채워지므로 모두 NULL 허용
ALTER TABLE problem_submission
    ADD COLUMN selected_option_id BIGINT,
    ADD COLUMN submitted_content  TEXT;
