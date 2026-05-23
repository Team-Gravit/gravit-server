-- 동일 피드에 대한 중복 축하 방지
ALTER TABLE congratulation ADD CONSTRAINT uq_congratulation_user_feed UNIQUE (user_id, feed_id);
