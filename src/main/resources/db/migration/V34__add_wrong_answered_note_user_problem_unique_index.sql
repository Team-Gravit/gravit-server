-- V34__add_wrong_answered_note_user_problem_unique_index.sql

-- 레슨 풀이 저장(POST /api/v1/lessons/results)이 오답 1건마다 (problem_id, user_id)로 오답노트를
-- 조회하지만 wrong_answered_note에는 PK 인덱스만 있어 매번 전체 스캔이 발생한다.
-- user_id를 선두 키로 두어 user_id 단독으로 필터하는 오답노트 조회·개수 쿼리도 같은 인덱스를 타게 한다.
-- WrongAnsweredNoteRepository가 Optional을 반환해 (problem_id, user_id) 유일성을 이미 전제하고 있으므로
-- UNIQUE로 제약을 명시해 조회 후 저장 사이의 경쟁으로 중복 행이 생기는 것을 DB가 막는다.
CREATE UNIQUE INDEX IF NOT EXISTS ix_wrong_answered_note_user_problem
    ON wrong_answered_note (user_id, problem_id);
