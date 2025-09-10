ALTER TABLE users
    ADD COLUMN IF NOT EXISTS deleted_at timestamp(6);

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS status varchar(255);

-- 2) 기존 데이터 백필 및 제약 강제
UPDATE users SET status = 'ACTIVE' WHERE status IS NULL;

-- 기본값과 NOT NULL 설정
ALTER TABLE users
    ALTER COLUMN status SET DEFAULT 'ACTIVE',
ALTER COLUMN status SET NOT NULL;

-- CHECK 제약 (이미 있으면 생략)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'users_status_chk'
  ) THEN
ALTER TABLE users
    ADD CONSTRAINT users_status_chk
        CHECK (status IN ('ACTIVE','INACTIVE','DELETED'));
END IF;
END$$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'users'::regclass AND conname = 'uk_users_handle'
    ) THEN
ALTER TABLE users DROP CONSTRAINT uk_users_handle;
END IF;
END$$;

CREATE UNIQUE INDEX IF NOT EXISTS ux_users_handle_live
    ON users(handle)
    WHERE deleted_at IS NULL;