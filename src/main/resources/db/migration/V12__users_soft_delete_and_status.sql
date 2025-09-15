-- 1) 컬럼 추가
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP(6);

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS status VARCHAR(20);

-- 2) 기존 데이터 백필
UPDATE users SET status = 'ACTIVE' WHERE status IS NULL;

-- 3) 기본값/NOT NULL
ALTER TABLE users
    ALTER COLUMN status SET DEFAULT 'ACTIVE',
ALTER COLUMN status SET NOT NULL;

-- 4) handle 을 NULL 허용(소프트 삭제 시 NULL로 만들기 위함)
ALTER TABLE users
    ALTER COLUMN handle DROP NOT NULL;

-- 5) is_onboarded NOT NULL + DEFAULT 정리 (엔티티가 nullable=false)
UPDATE users SET is_onboarded = COALESCE(is_onboarded, FALSE);
ALTER TABLE users
    ALTER COLUMN is_onboarded SET DEFAULT FALSE,
ALTER COLUMN is_onboarded SET NOT NULL;

-- 6) 기존 유니크 제약/인덱스 제거 (이름이 제약/인덱스 어느쪽일지 몰라서 모두 방어)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint
             WHERE conrelid = 'users'::regclass AND conname = 'uk_users_handle') THEN
ALTER TABLE users DROP CONSTRAINT uk_users_handle;
END IF;
END $$;

DROP INDEX IF EXISTS uk_users_handle;

-- 7) 활성(Row)에게만 유니크(부분 인덱스)
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_handle
    ON users(handle);

-- 9) 상태-삭제일시 정합성 체크(선택: 운영 정책 일치 강제)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint
                 WHERE conname = 'users_deleted_consistent') THEN
ALTER TABLE users ADD CONSTRAINT users_deleted_consistent
    CHECK ( (status = 'DELETED') = (deleted_at IS NOT NULL) );
END IF;
END $$;
