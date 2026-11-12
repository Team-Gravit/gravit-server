-- =====================================================================
-- QA 페르소나 데이터셋 02 - 온보딩 기본 행
--
-- 온보딩된 유저(pre-onboarding 제외 전원, 보조 유저 포함)에게 온보딩 시 생기는 행을 만듭니다.
--   - learning    : 연속 0일, 정복률 0, 오늘 미학습, 최근 챕터 1 (version은 DB 기본값)
--   - user_mission: 오늘 배정, COMPLETE_LESSON_ONE, 진행 0
--   - user_league : ACTIVE 시즌, LP 0, LP 구간에 맞는 리그
-- =====================================================================

INSERT INTO learning (
    consecutive_solved_days, planet_conquest_rate, today_solved,
    recent_solved_chapter_id, user_id
)
SELECT 0, 0, false, 1, u.id
FROM users u
WHERE u.provider_id LIKE 'qa-persona-{set}-%'
  AND u.is_onboarded;

INSERT INTO user_mission (
    user_id, mission_id, assigned_date, progress_count, completed_at,
    created_at, updated_at
)
SELECT u.id, m.id, current_date, 0, NULL, now(), now()
FROM users u
JOIN mission m ON m.code = 'COMPLETE_LESSON_ONE'
WHERE u.provider_id LIKE 'qa-persona-{set}-%'
  AND u.is_onboarded;

INSERT INTO user_league (
    league_point, created_at, updated_at, league_id, season_id, user_id
)
SELECT 0, now(), now(), l.id, s.id, u.id
FROM users u
JOIN league l ON 0 BETWEEN l.min_lp AND l.max_lp
JOIN season s ON s.status = 'ACTIVE'
WHERE u.provider_id LIKE 'qa-persona-{set}-%'
  AND u.is_onboarded;
