-- =====================================================================
-- QA 페르소나 데이터셋 07 - 문의 (inquirer, 답변자 admin)
--
-- RESOLVED 1건(D-2 접수, D-1 답변)과 답변 알림, PENDING 1건(now() - 1시간)
-- 답변의 admin_id는 같은 세트의 admin 페르소나입니다.
-- =====================================================================

INSERT INTO inquiry (title, type, content, status, user_id, created_at, updated_at, deleted_at)
SELECT q.title, q.type, q.content, q.status, u.id, q.created_at, q.updated_at, NULL
FROM users u
CROSS JOIN (VALUES
    ('QA 학습 화면이 멈춰요', 'BUG_REPORT',
        'QA 페르소나 문의입니다. 레슨을 제출한 뒤 결과 화면에서 다음 버튼이 눌리지 않습니다.',
        'RESOLVED',
        date_trunc('day', now()) - INTERVAL '2 days' + INTERVAL '20 hours',
        date_trunc('day', now()) - INTERVAL '1 day' + INTERVAL '10 hours'),
    ('QA 오답 노트 정렬 기능 제안', 'FEATURE_SUGGESTION',
        'QA 페르소나 문의입니다. 오답 노트를 틀린 횟수 순으로 정렬하는 기능이 있으면 좋겠습니다.',
        'PENDING',
        now() - INTERVAL '1 hour',
        now() - INTERVAL '1 hour')
) AS q(title, type, content, status, created_at, updated_at)
WHERE u.email = 'qa-persona-{set}-inquirer@gravit.test';

INSERT INTO inquiry_answer (inquiry_id, content, admin_id, created_at, updated_at)
SELECT
    i.id,
    '안녕하세요, 그래빗입니다. 말씀해 주신 현상을 확인해 수정했습니다. 앱을 다시 실행한 뒤 확인해 주세요.',
    (SELECT id FROM users WHERE email = 'qa-persona-{set}-admin@gravit.test'),
    i.updated_at,
    i.updated_at
FROM inquiry i
JOIN users u ON u.id = i.user_id
WHERE u.email = 'qa-persona-{set}-inquirer@gravit.test'
  AND i.status = 'RESOLVED';

INSERT INTO notification (user_id, message, is_read, type, target_id, sub_text, created_at, updated_at)
SELECT i.user_id, '[' || i.title || ']에 답변이 달렸어요!', false, 'INQUIRY_ANSWERED', i.id, NULL, ia.created_at, ia.created_at
FROM inquiry i
JOIN inquiry_answer ia ON ia.inquiry_id = i.id
JOIN users u ON u.id = i.user_id
WHERE u.email = 'qa-persona-{set}-inquirer@gravit.test';
