-- V7__add_base_entity_columns_to_lesson_submission.sql
-- lesson_submission 테이블에 BaseEntity 공통 컬럼(created_at, updated_at) 추가
-- 기존 레코드는 NULL 허용 (생성/수정 시점 정보 부재)
ALTER TABLE lesson_submission
    ADD COLUMN created_at TIMESTAMP(6),
    ADD COLUMN updated_at TIMESTAMP(6);
