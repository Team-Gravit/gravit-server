-- V17__add_user_last_accessed_at.sql

ALTER TABLE users ADD COLUMN last_accessed_at TIMESTAMP(6);

UPDATE users SET last_accessed_at = created_at WHERE last_accessed_at IS NULL;

CREATE INDEX IF NOT EXISTS ix_users_last_accessed_at ON users (last_accessed_at);
