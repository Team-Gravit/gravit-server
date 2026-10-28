-- V49__add_client_to_apple_credential.sql

-- Apple refresh_token을 발급한 클라이언트. 철회 때 같은 client_id를 써야 하므로 보관한다. 기존 행은 모두 웹에서 발급됐다
ALTER TABLE apple_credential
    ADD COLUMN client VARCHAR(255) NOT NULL DEFAULT 'WEB';

-- 허용 값은 WEB(웹 Services ID), IOS(iOS 앱 Bundle ID)뿐이다
ALTER TABLE apple_credential
    ADD CONSTRAINT ck_apple_credential_client CHECK (client IN ('WEB', 'IOS'));
