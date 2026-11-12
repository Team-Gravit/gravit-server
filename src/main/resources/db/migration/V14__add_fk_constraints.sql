-- congratulation 테이블 참조 무결성 강화
ALTER TABLE congratulation
    ADD CONSTRAINT fk_congratulation_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_congratulation_actor
        FOREIGN KEY (actor_id) REFERENCES users(id),
    ADD CONSTRAINT fk_congratulation_feed
        FOREIGN KEY (feed_id) REFERENCES social_feed(id);

-- notification 테이블 참조 무결성 강화
ALTER TABLE notification
    ADD CONSTRAINT fk_notification_user
        FOREIGN KEY (user_id) REFERENCES users(id);
