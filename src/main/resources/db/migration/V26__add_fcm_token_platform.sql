-- 푸시 발송 대상 플랫폼 컬럼 추가. 웹은 푸시 미지원이라 ANDROID 토큰에만 푸시한다.
-- 기존 토큰은 백필하지 않고 NULL로 둔다(재로그인 시 토큰이 재발급되며 platform이 채워짐).
-- 푸시 조회는 platform = 'ANDROID'로 필터하므로 NULL 토큰은 자연 제외된다.
ALTER TABLE fcm_token ADD COLUMN platform VARCHAR(255);

ALTER TABLE fcm_token ADD CONSTRAINT ck_fcm_token_platform CHECK (
    platform IS NULL OR platform IN ('ANDROID', 'WEB')
);
