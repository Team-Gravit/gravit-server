-- V33__add_lesson_submission_user_week_index.sql

-- 마이페이지 상위 챕터 조회(GET /api/v1/my-pages/learning/top-chapters)는 주간 구간을 두 쿼리로 나눠
-- 집계하는데, lesson_submission에는 PK 인덱스만 있어 같은 전체 스캔이 요청당 두 번 발생한다.
-- 등호 조건인 user_id를 선두 키로, 범위 조건인 created_at을 뒤에 두어 한 유저의 주간 구간을 연속으로 읽는다.
-- lesson_id는 조인 키이자 COUNT(DISTINCT) 대상이지만 검색과 정렬에는 쓰이지 않으므로
-- INCLUDE로 리프에만 실어 힙 접근을 없앤다.
CREATE INDEX IF NOT EXISTS ix_lesson_submission_user_created_at
    ON lesson_submission (user_id, created_at) INCLUDE (lesson_id);
