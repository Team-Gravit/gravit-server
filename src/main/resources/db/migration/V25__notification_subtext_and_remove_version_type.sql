-- 알림 카드의 서브텍스트(헤드라인 하위 보조 문구)를 저장하는 컬럼 추가
-- 3.1(연속학습 위기)·3.7(시즌 종료 임박)·3.12(공지) 등에서 사용. 없으면 NULL.
ALTER TABLE notification ADD COLUMN sub_text VARCHAR(255);

-- 미사용 VERSION 타입 제거 (기획에서 삭제된 항목, 실제 생성 이력 없음)
ALTER TABLE notification DROP CONSTRAINT IF EXISTS ck_notification_type;

ALTER TABLE notification ADD CONSTRAINT ck_notification_type CHECK (
    type IN (
        'CONSECUTIVE_LEARNING_WARNING', 'DAILY_INCOMPLETE', 'INACTIVITY', 'SEASON_ENDING',
        'SEASON_RESET', 'FOLLOW', 'CONGRATULATION', 'FRIEND_ACTIVITY',
        'NOTICE', 'NEW_CONTENT', 'INQUIRY_ANSWERED'
    )
);
