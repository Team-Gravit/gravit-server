-- =====================================================================
-- QA 페르소나 데이터셋 06 - 면접 (interviewer)
--
-- 공통: TEXT 입력, NORMAL, 만점 70/15/15, 시도 차수는 생성 순서
--   1차 COMPLETED      D-3 20:00 ~ 20:15  COMMON_CS DATA_STRUCTURE 3 + NETWORK 2, 총점 57
--   2차 GRADING_FAILED D-2 20:00 ~ 20:15  1차와 같은 문항, 피드백 없음
--   3차 GRADING        D-1 20:00 ~ 20:15  1차와 같은 문항, 피드백 없음
--   4차 IN_PROGRESS    now() - 10분       JOB_SPECIFIC JAVA_SPRING_BOOT, 답안 PENDING
-- 문항은 주제별 활성 NORMAL 문제를 id 오름차순으로 고릅니다.
-- XP, LP 17 = 1차 완료 보상 round(30 * 57 / 100)
-- =====================================================================

UPDATE users
SET xp = 17,
    level = 1
WHERE email = 'qa-persona-{set}-interviewer@gravit.test';

UPDATE user_league ul
SET league_point = 17,
    league_id = (SELECT l.id FROM league l WHERE 17 BETWEEN l.min_lp AND l.max_lp),
    updated_at = now()
FROM users u
WHERE ul.user_id = u.id
  AND u.email = 'qa-persona-{set}-interviewer@gravit.test';

INSERT INTO interview_session (
    user_id, attempt_count, mode, input_type, difficulty, stack, status,
    accuracy_score, delivery_score, accuracy_max_score, structure_max_score, clarity_max_score,
    grading_attempt_count, started_at, ended_at, created_at, updated_at
)
SELECT
    u.id,
    s.attempt_count,
    s.mode,
    'TEXT',
    'NORMAL',
    s.stack,
    s.status,
    s.accuracy_score,
    s.delivery_score,
    70,
    15,
    15,
    s.grading_attempt_count,
    s.started_at,
    s.ended_at,
    s.started_at,
    coalesce(s.ended_at, s.started_at)
FROM users u
CROSS JOIN (VALUES
    (1, 'COMMON_CS',    NULL,               'COMPLETED',      40, 17, 1,
        date_trunc('day', now()) - INTERVAL '3 days' + INTERVAL '20 hours',
        date_trunc('day', now()) - INTERVAL '3 days' + INTERVAL '20 hours 15 minutes'),
    (2, 'COMMON_CS',    NULL,               'GRADING_FAILED', 0,  0,  1,
        date_trunc('day', now()) - INTERVAL '2 days' + INTERVAL '20 hours',
        date_trunc('day', now()) - INTERVAL '2 days' + INTERVAL '20 hours 15 minutes'),
    (3, 'COMMON_CS',    NULL,               'GRADING',        0,  0,  1,
        date_trunc('day', now()) - INTERVAL '1 day' + INTERVAL '20 hours',
        date_trunc('day', now()) - INTERVAL '1 day' + INTERVAL '20 hours 15 minutes'),
    (4, 'JOB_SPECIFIC', 'JAVA_SPRING_BOOT', 'IN_PROGRESS',    0,  0,  0,
        now() - INTERVAL '10 minutes',
        NULL)
) AS s(attempt_count, mode, stack, status, accuracy_score, delivery_score, grading_attempt_count, started_at, ended_at)
WHERE u.email = 'qa-persona-{set}-interviewer@gravit.test';

INSERT INTO interview_session_topic (session_id, topic, created_at, updated_at)
SELECT session.id, t.topic, session.started_at, session.started_at
FROM interview_session session
JOIN users u ON u.id = session.user_id
JOIN (VALUES
    (1, 'DATA_STRUCTURE'),
    (1, 'NETWORK'),
    (2, 'DATA_STRUCTURE'),
    (2, 'NETWORK'),
    (3, 'DATA_STRUCTURE'),
    (3, 'NETWORK'),
    (4, 'SERVER_COMMON'),
    (4, 'JAVA'),
    (4, 'SPRING_BOOT')
) AS t(attempt_count, topic) ON t.attempt_count = session.attempt_count
WHERE u.email = 'qa-persona-{set}-interviewer@gravit.test';

-- 문항 배치: (차수, 주제, 주제 안 순번) -> 문항 번호
INSERT INTO interview_answer (
    session_id, question_id, display_order, status, content, audio_key, answered_at, created_at, updated_at
)
SELECT
    session.id,
    q.id,
    slot.display_order,
    CASE
        WHEN session.status = 'IN_PROGRESS' THEN 'PENDING'
        WHEN session.status = 'COMPLETED' AND slot.display_order = 5 THEN 'NO_RESPONSE'
        ELSE 'ANSWERED'
    END,
    CASE
        WHEN session.status = 'IN_PROGRESS' THEN NULL
        WHEN session.status = 'COMPLETED' AND slot.display_order = 5 THEN NULL
        ELSE 'QA 페르소나 답변입니다. 개념의 정의를 먼저 말하고 동작 방식과 장단점을 차례로 설명합니다.'
    END,
    NULL,
    session.ended_at,
    session.started_at,
    coalesce(session.ended_at, session.started_at)
FROM interview_session session
JOIN users u ON u.id = session.user_id
JOIN (VALUES
    ('COMMON_CS',    'DATA_STRUCTURE', 1, 1),
    ('COMMON_CS',    'DATA_STRUCTURE', 2, 2),
    ('COMMON_CS',    'DATA_STRUCTURE', 3, 3),
    ('COMMON_CS',    'NETWORK',        1, 4),
    ('COMMON_CS',    'NETWORK',        2, 5),
    ('JOB_SPECIFIC', 'SERVER_COMMON',  1, 1),
    ('JOB_SPECIFIC', 'JAVA',           1, 2),
    ('JOB_SPECIFIC', 'JAVA',           2, 3),
    ('JOB_SPECIFIC', 'SPRING_BOOT',    1, 4),
    ('JOB_SPECIFIC', 'SPRING_BOOT',    2, 5)
) AS slot(mode, topic, topic_seq, display_order) ON slot.mode = session.mode
JOIN (
    SELECT iq.id, iq.topic, ROW_NUMBER() OVER (PARTITION BY iq.topic ORDER BY iq.id) AS topic_seq
    FROM interview_question iq
    WHERE iq.is_active
      AND iq.difficulty = 'NORMAL'
) AS q ON q.topic = slot.topic AND q.topic_seq = slot.topic_seq
WHERE u.email = 'qa-persona-{set}-interviewer@gravit.test';

-- 1차 피드백: 정확도 14/12/9/5/0, 구조 3/3/2/1/0, 명료 3/2/2/1/0 -> 정확도 40, 전달력 17, 총점 57
-- 4번(7점), 5번(무응답 0점)이 약점(문항 10점 이하)
INSERT INTO interview_feedback (
    answer_id, accuracy_score, structure_score, clarity_score,
    accuracy_base_ratio, accuracy_multiplier, irrelevant_statement_count, improvement_suggestion,
    created_at, updated_at
)
SELECT
    a.id,
    f.accuracy_score,
    f.structure_score,
    f.clarity_score,
    f.accuracy_base_ratio,
    f.accuracy_multiplier,
    f.irrelevant_statement_count,
    f.improvement_suggestion,
    session.ended_at,
    session.ended_at
FROM interview_session session
JOIN users u ON u.id = session.user_id
JOIN interview_answer a ON a.session_id = session.id
JOIN (VALUES
    (1, 14, 3, 3, 1.000, 1.0, 0,    '**잘한 점**: 핵심 개념을 빠짐없이 설명했습니다.'),
    (2, 12, 3, 2, 0.875, 1.0, 0,    '**보완할 점**: 정의 다음에 동작 예시를 한 가지 덧붙여 보세요.'),
    (3, 9,  2, 2, 0.625, 1.0, 0,    '**보완할 점**: 빠진 필수 개념이 있습니다. 시간 복잡도를 함께 말해 보세요.'),
    (4, 5,  1, 1, 0.375, 1.0, 1,    '**보완할 점**: 질문과 관계없는 설명이 섞였습니다. 결론부터 말해 보세요.'),
    (5, 0,  0, 0, NULL,  NULL, NULL, NULL)
) AS f(display_order, accuracy_score, structure_score, clarity_score,
       accuracy_base_ratio, accuracy_multiplier, irrelevant_statement_count, improvement_suggestion)
    ON f.display_order = a.display_order
WHERE u.email = 'qa-persona-{set}-interviewer@gravit.test'
  AND session.status = 'COMPLETED';
