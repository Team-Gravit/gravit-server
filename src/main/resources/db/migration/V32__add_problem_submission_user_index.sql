-- V32__add_problem_submission_user_index.sql

-- 마이페이지 취약 개념 조회(GET /api/v1/my-pages/learning/weak-concepts)가 유저 단위로 문제 제출을
-- 집계하지만 problem_submission에는 PK 인덱스만 있어 전체 스캔이 발생한다.
-- user_id를 선두 키로 두고, 같은 유저 안에서 problem_id 순으로 정렬되게 해 중복 제거 정렬을 덜어낸다.
-- is_correct는 검색·정렬에 쓰이지 않고 값만 읽히므로 INCLUDE로 리프에만 실어 힙 접근을 없앤다.
CREATE INDEX IF NOT EXISTS ix_problem_submission_user_problem
    ON problem_submission (user_id, problem_id) INCLUDE (is_correct);
