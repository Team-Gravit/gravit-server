--V24__add_inquiry_answered_notification_type.sql

-- 문의 답변 알림(INQUIRY_ANSWERED) 타입 추가를 위해 notification type CHECK 제약을 갱신한다
ALTER TABLE notification DROP CONSTRAINT IF EXISTS ck_notification_type;

ALTER TABLE notification ADD CONSTRAINT ck_notification_type CHECK (
    type IN (
        'CONSECUTIVE_LEARNING_WARNING', 'DAILY_INCOMPLETE', 'INACTIVITY', 'SEASON_ENDING',
        'SEASON_RESET', 'FOLLOW', 'CONGRATULATION', 'FRIEND_ACTIVITY',
        'NOTICE', 'VERSION', 'NEW_CONTENT', 'INQUIRY_ANSWERED'
    )
);
