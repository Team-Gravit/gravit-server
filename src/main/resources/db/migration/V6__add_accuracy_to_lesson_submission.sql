-- V6__add_accuracy_to_lesson_submission.sql
-- lesson_submission 테이블에 정확도(accuracy) 컬럼 추가
-- 0~100 범위의 정수, 매 제출마다 갱신
-- 기존 행이 있을 경우 마이그레이션 실패를 방지하기 위해 DEFAULT 0을 지정한다
ALTER TABLE lesson_submission
    ADD COLUMN accuracy INTEGER NOT NULL DEFAULT 0;
