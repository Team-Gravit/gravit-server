-- V30__convert_wrong_answered_note_to_resolvable.sql
-- 오답노트를 물리 삭제 대상에서 극복 여부를 남기는 상태 테이블로 전환

-- BaseEntity 공통 컬럼. 기존 행은 최초 오답 시점을 알 수 없어 NULL을 허용한다
ALTER TABLE wrong_answered_note
    ADD COLUMN created_at TIMESTAMP(6),
    ADD COLUMN updated_at TIMESTAMP(6);

-- 같은 문제를 몇 번 틀렸는지 누적한다. 기존 행은 최소 1회 오답이므로 1로 채운다
ALTER TABLE wrong_answered_note
    ADD COLUMN wrong_count INTEGER NOT NULL DEFAULT 1;

-- NULL이면 오답노트에 노출되고, 값이 있으면 극복 처리되어 노출되지 않는다
-- 기존 행은 전부 미극복 상태이므로 NULL로 둔다
ALTER TABLE wrong_answered_note
    ADD COLUMN resolved_at TIMESTAMP(6);
