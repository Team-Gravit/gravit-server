-- =====================================================================
-- QA 페르소나 데이터셋 01 - 유저
--
-- 재적재 API(POST /api/v1/test/fixtures/qa/reload?set=) 전용입니다. 수동 실행 대상이 아닙니다.
--   - {set}은 실행 시 세트 키(auto, manual)로 치환됩니다
--   - API가 트랜잭션 첫 문장으로 SET LOCAL TIME ZONE 'Asia/Seoul'을 실행하므로 now(), current_date는 KST입니다
--   - 페르소나 명세: sql/seed/qa/PERSONAS.md
--
-- 식별: provider_id, handle = 'qa-persona-{set}-{key}', email = 'qa-persona-{set}-{key}@gravit.test'
-- 레벨, XP, 상태, 역할은 이후 파일에서 페르소나별로 바꿉니다
-- =====================================================================

INSERT INTO users (
    is_onboarded, level, profile_img_number, xp,
    created_at, updated_at, last_accessed_at,
    email, handle, nickname, provider_id, role, status
)
SELECT
    p.key <> 'pre-onboarding',
    1,
    1,
    0,
    CASE WHEN p.key = 'pre-onboarding' THEN now() ELSE now() - INTERVAL '30 days' END,
    CASE WHEN p.key = 'pre-onboarding' THEN now() ELSE now() - INTERVAL '30 days' END,
    CASE WHEN p.key = 'pre-onboarding' THEN NULL ELSE now() - INTERVAL '1 day' END,
    'qa-persona-{set}-' || p.key || '@gravit.test',
    'qa-persona-{set}-' || p.key,
    p.nickname,
    'qa-persona-{set}-' || p.key,
    'USER',
    'ACTIVE'
FROM (VALUES
    ('pre-onboarding', 'QA온보딩전'),
    ('fresh',          'QA신규'),
    ('learner',        'QA학습자'),
    ('streak',         'QA연속'),
    ('chapter-almost', 'QA챕터'),
    ('social',         'QA소셜'),
    ('league-edge',    'QA리그'),
    ('mission',        'QA미션'),
    ('interviewer',    'QA면접'),
    ('inquirer',       'QA문의'),
    ('withdrawing',    'QA탈퇴'),
    ('suspended',      'QA정지'),
    ('admin',          'QA관리자'),
    ('aux-01',         'QA보조01'),
    ('aux-02',         'QA보조02'),
    ('aux-03',         'QA보조03'),
    ('aux-04',         'QA보조04'),
    ('aux-05',         'QA보조05'),
    ('aux-06',         'QA보조06')
) AS p(key, nickname);
