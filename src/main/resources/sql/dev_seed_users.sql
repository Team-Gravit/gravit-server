-- =====================================================================
-- DEV 전용 시드 스크립트 — RecommendUser / paging 테스트용 더미 유저 20명
--
-- ⚠ 수동 실행 전용입니다. Flyway 마이그레이션도, 앱 자동 실행 대상도 아닙니다.
--   반드시 DEV DB 에만 직접(psql / DB 클라이언트) 실행하세요.
--
-- 생성 데이터 (실제 회원가입 → 온보딩 완료 유저와 동일한 구성):
--   - users       : 온보딩 완료(is_onboarded=true) 유저 20명
--   - user_league : 유저당 1건. 티어를 브론즈3~실버1(league_id 1~6)로 순환 분산
--   - mission     : 유저당 1건 (온보딩 시 생성되는 기본 미션)
--   - learning    : 유저당 1건 (온보딩 시 생성되는 기본 학습 진행도)
--
-- 전제 조건:
--   1) 리그 시드(sql/league.sql)가 적용되어 있어야 함 → league.id 1~6 = 브론즈3~실버1
--   2) status='ACTIVE' 인 season 이 1건 이상 존재해야 함 (user_league.season_id FK)
--
-- 식별 / 정리:
--   - provider_id·email·handle 가 모두 'seed-dev-NN' 패턴 → 파일 하단 정리 쿼리로 일괄 삭제 가능
--   - provider_id 가 UNIQUE 이므로 재실행하면 충돌로 실패합니다(중복 삽입 방지).
--     다시 넣으려면 먼저 하단의 "정리(삭제)" 쿼리를 실행하세요.
-- =====================================================================

BEGIN;

-- 0) ACTIVE 시즌 존재 확인 (없으면 즉시 중단하여 FK 오류 방지)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM season WHERE status = 'ACTIVE') THEN
        RAISE EXCEPTION 'ACTIVE 상태의 season 이 없습니다. 활성 시즌을 먼저 만든 뒤 다시 실행하세요.';
    END IF;
END $$;

-- 1) 유저 20명 생성 (온보딩 완료 상태)
INSERT INTO users (
    is_onboarded, level, profile_img_number, xp,
    created_at, updated_at,
    email, handle, nickname, provider_id, role, status
)
SELECT
    true,                            -- is_onboarded
    1,                               -- level
    (n % 8) + 1,                     -- profile_img_number (1~8 분산, 아바타 셋이 더 작으면 1로 조정)
    0,                               -- xp
    now(), now(),
    'seed-dev-' || lpad(n::text, 2, '0') || '@gravit.test',
    'seed-dev-' || lpad(n::text, 2, '0'),
    '테스트유저' || lpad(n::text, 2, '0'),
    'seed-dev-' || lpad(n::text, 2, '0'),
    'USER', 'ACTIVE'
FROM generate_series(1, 20) AS n;

-- 2) UserLeague 생성 — 티어를 브론즈3~실버1(league_id 1~6)로 순환 분산
--    NN 값으로 ((NN-1) % 6) + 1 → 1,2,3,4,5,6,1,2,... 순환 배치
INSERT INTO user_league (
    league_point, created_at, updated_at, league_id, season_id, user_id
)
SELECT
    l.min_lp + split_part(u.provider_id, '-', 3)::int,        -- 해당 티어 LP 범위 내 값(랭킹 변별용 소폭 offset)
    now(), now(),
    l.id,
    (SELECT id FROM season WHERE status = 'ACTIVE' ORDER BY id LIMIT 1),
    u.id
FROM users u
JOIN league l
    ON l.id = ((split_part(u.provider_id, '-', 3)::int - 1) % 6) + 1
WHERE u.provider_id LIKE 'seed-dev-%';

-- 3) Mission 생성 (온보딩 기본 미션 — 진행도 0, 미완료)
INSERT INTO mission (
    is_completed, progress_rate, user_id, version, mission_type
)
SELECT
    false, 0.0, u.id, 0, 'COMPLETE_LESSON_ONE'
FROM users u
WHERE u.provider_id LIKE 'seed-dev-%';

-- 4) Learning 생성 (온보딩 기본 학습 진행도)
INSERT INTO learning (
    consecutive_solved_days, planet_conquest_rate, today_solved,
    recent_solved_chapter_id, user_id, version
)
SELECT
    0, 0, false, 1, u.id, 0
FROM users u
WHERE u.provider_id LIKE 'seed-dev-%';

COMMIT;

-- =====================================================================
-- 확인용 조회 (필요 시 주석 해제)
-- SELECT u.id, u.nickname, l.name AS tier, ul.league_point
-- FROM users u
-- JOIN user_league ul ON ul.user_id = u.id
-- JOIN league l        ON l.id = ul.league_id
-- WHERE u.provider_id LIKE 'seed-dev-%'
-- ORDER BY l.sort_order, ul.league_point;
--
-- 로그인 토큰 발급(프론트 테스트용): POST /api/v1/test/users/login?userId={위 조회한 id}
-- =====================================================================

-- =====================================================================
-- 정리(삭제) — 시드 유저 전체 제거 시 순서대로 실행 (FK 역순)
-- DELETE FROM learning    WHERE user_id IN (SELECT id FROM users WHERE provider_id LIKE 'seed-dev-%');
-- DELETE FROM mission     WHERE user_id IN (SELECT id FROM users WHERE provider_id LIKE 'seed-dev-%');
-- DELETE FROM user_league WHERE user_id IN (SELECT id FROM users WHERE provider_id LIKE 'seed-dev-%');
-- DELETE FROM users       WHERE provider_id LIKE 'seed-dev-%';
-- =====================================================================
