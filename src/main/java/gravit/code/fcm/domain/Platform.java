package gravit.code.fcm.domain;

// 푸시 발송 대상 플랫폼. 웹은 푸시 미지원이라 ANDROID 토큰에만 푸시한다
public enum Platform {
    ANDROID,
    WEB
}
