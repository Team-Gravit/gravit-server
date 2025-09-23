ALTER TABLE friends
    ADD COLUMN IF NOT EXISTS created_at  TIMESTAMP(6),
    ADD COLUMN IF NOT EXISTS updated_at  TIMESTAMP(6);

UPDATE friends
SET created_at = (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Seoul')
WHERE created_at IS NULL;

-- updated_at이 비어있으면 created_at으로 채움
UPDATE friends
SET updated_at = created_at
WHERE updated_at IS NULL;

ALTER TABLE friends
    ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL;