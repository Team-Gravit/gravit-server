package gravit.code.auth.dto.internal;

import gravit.code.auth.domain.AppleClient;
import gravit.code.auth.dto.oauth.OAuthUserInfo;

public record AppleLoginDto(

        OAuthUserInfo userInfo,

        String refreshToken,

        AppleClient client
) {
    public static AppleLoginDto of(
            OAuthUserInfo userInfo,
            String refreshToken,
            AppleClient client
    ) {
        return new AppleLoginDto(userInfo, refreshToken, client);
    }
}
