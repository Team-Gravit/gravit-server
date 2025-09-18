-- 10) BaseEntity 컬럼 추가 (없으면 추가)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS created_at  TIMESTAMP(6),
    ADD COLUMN IF NOT EXISTS updated_at  TIMESTAMP(6);

-- 11) BaseEntity 컬럼 백필
-- created_at이 비어있으면 서울 타임존 기준 현재 시각으로 채움
UPDATE users
SET created_at = (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Seoul')
WHERE created_at IS NULL;

-- updated_at이 비어있으면 created_at으로 채움
UPDATE users
SET updated_at = created_at
WHERE updated_at IS NULL;

-- 12) BaseEntity 컬럼 제약 (NOT NULL)
ALTER TABLE users
    ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL;

-- 13) role 컬럼 추가
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS role VARCHAR(20);

-- 14) 기존 데이터 role 백필 (없던 행은 USER)
UPDATE users
SET role = 'USER'
WHERE role IS NULL;

-- 15) role 기본값/NOT NULL
ALTER TABLE users
    ALTER COLUMN role SET DEFAULT 'USER',
ALTER COLUMN role SET NOT NULL;

-- 16) role 값 유효성 체크 (ADMIN/USER만)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'users'::regclass
      AND conname = 'ck_users_role'
  ) THEN
ALTER TABLE users
    ADD CONSTRAINT ck_users_role
        CHECK (role IN ('ADMIN','USER'));
END IF;
END $$;