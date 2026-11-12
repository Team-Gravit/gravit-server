-- notification에 알림 종류(type)와 액션 라우팅 대상(target_id) 컬럼 추가
-- type: 알림 종류. 버튼 종류는 type에서 파생되므로 별도 컬럼을 두지 않는다.
-- target_id: 액션이 이동할 리소스 id. 의미(noticeId/lessonId/userId/feedId)는 type이 결정. 대상 없으면 NULL.
ALTER TABLE notification ADD COLUMN type      VARCHAR(255);
ALTER TABLE notification ADD COLUMN target_id BIGINT;

-- 기존 행 백필: V12 이후 생성된 알림은 축하받음(3.10) 알림뿐이므로 CONGRATULATION으로 채운다
UPDATE notification SET type = 'CONGRATULATION' WHERE type IS NULL;

-- type은 필수값
ALTER TABLE notification ALTER COLUMN type SET NOT NULL;

-- enum 값 제약
ALTER TABLE notification ADD CONSTRAINT ck_notification_type CHECK (
    type IN (
        'STREAK_WARNING', 'DAILY_INCOMPLETE', 'INACTIVITY', 'SEASON_ENDING',
        'SEASON_RESET', 'FOLLOW', 'CONGRATULATION', 'FRIEND_ACTIVITY',
        'NOTICE', 'VERSION', 'NEW_CONTENT'
    )
);
