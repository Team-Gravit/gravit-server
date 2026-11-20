-- V55__add_user_nickname_reset_audit_action.sql

-- 관리자 닉네임 초기화를 감사 로그에 남기도록 action 허용 값에 USER_NICKNAME_RESET을 더한다
ALTER TABLE audit_log DROP CONSTRAINT IF EXISTS audit_log_action_check;

ALTER TABLE audit_log
    ADD CONSTRAINT audit_log_action_check CHECK (action IN
                                                 ('USER_STATUS_CHANGE', 'USER_ROLE_CHANGE',
                                                  'NOTICE_DELETE', 'NOTICE_STATUS_CHANGE', 'STAGING_PROMOTE',
                                                  'USER_NICKNAME_RESET'));
