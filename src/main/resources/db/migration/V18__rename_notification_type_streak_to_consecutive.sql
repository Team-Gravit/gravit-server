--V18__rename_notification_type_streak_to_consecutive.sql

ALTER TABLE notification DROP CONSTRAINT IF EXISTS ck_notification_type;

UPDATE notification SET type = 'CONSECUTIVE_LEARNING_WARNING' WHERE type = 'STREAK_WARNING';

ALTER TABLE notification ADD CONSTRAINT ck_notification_type CHECK (
    type IN (
        'CONSECUTIVE_LEARNING_WARNING', 'DAILY_INCOMPLETE', 'INACTIVITY', 'SEASON_ENDING',
        'SEASON_RESET', 'FOLLOW', 'CONGRATULATION', 'FRIEND_ACTIVITY',
        'NOTICE', 'VERSION', 'NEW_CONTENT'
    )
);
