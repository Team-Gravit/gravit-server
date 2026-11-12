-- =====================================================================
-- QA 페르소나 데이터셋 08 - 계정 상태 (withdrawing, suspended, admin)
--
-- withdrawing: 실제 탈퇴 직후와 같이 DELETED, deleted_at = now(), handle 반납(NULL). 온보딩 기본 행은 유지
--              Redis 처리(랭킹 제외, user:clean:due 등록)는 재적재 API가 커밋 뒤에 합니다
-- suspended  : status = SUSPENDED
-- admin      : role = ADMIN
-- =====================================================================

UPDATE users
SET status = 'DELETED',
    deleted_at = now(),
    handle = NULL,
    updated_at = now()
WHERE email = 'qa-persona-{set}-withdrawing@gravit.test';

UPDATE users
SET status = 'SUSPENDED',
    updated_at = now()
WHERE email = 'qa-persona-{set}-suspended@gravit.test';

UPDATE users
SET role = 'ADMIN',
    updated_at = now()
WHERE email = 'qa-persona-{set}-admin@gravit.test';
