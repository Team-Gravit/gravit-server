-- 유저 시드: users
--
-- 필요한 변수: user_start, user_count
--
-- id를 명시 삽입하므로 k6 스크립트의 USER_ID_START / USER_COUNT와 그대로 맞아떨어진다.
-- 토큰 발급(/api/v1/test/users/login)이 이 범위의 id를 쓴다.
-- 대량 시드에 /api/v1/test/users/create 를 쓰지 마라. 요청당 커밋이라 느리다.

\echo '[user.sql] users 적재'

BEGIN;

INSERT INTO users (id, email, handle, nickname, provider_id,
                   is_onboarded, level, xp, profile_img_number,
                   role, status, created_at, updated_at, last_accessed_at)
SELECT i,
       'perf-' || i || '@seed.local',
       'perf-' || i,
       'perf' || i,
       'perf-seed-' || i,
       true,
       1 + (i % 30),
       (i % 5000),
       1 + (i % 8),
       'USER',
       'ACTIVE',
       now() - INTERVAL '200 days',
       now(),
       now()
FROM generate_series(:user_start, :user_start + :user_count - 1) AS i
ON CONFLICT DO NOTHING;

SELECT setval(pg_get_serial_sequence('users', 'id'), (SELECT COALESCE(max(id), 1) FROM users));

COMMIT;

ANALYZE users;

-- 검증
SELECT 'users' AS table_name,
       count(*)                    AS rows,
       count(DISTINCT level)       AS level_cardinality,
       min(id)                     AS min_id,
       max(id)                     AS max_id
FROM users
WHERE id BETWEEN :user_start AND :user_start + :user_count - 1;
