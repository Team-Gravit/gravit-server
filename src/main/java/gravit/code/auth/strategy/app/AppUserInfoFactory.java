package gravit.code.auth.strategy.app;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.oauth.app.GoogleAppUserInfo;
import gravit.code.auth.dto.oauth.app.KakaoAppUserInfo;
import gravit.code.auth.strategy.support.OAuthUserInfoValidator;
import gravit.code.global.exception.domain.RestApiException;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;

@Slf4j
public final class AppUserInfoFactory {
    private AppUserInfoFactory() {}

    public static OAuthUserInfo fromClaims(
            String provider,
            Map<String, Object> claims
    ) {
        OAuthUserInfo userInfo = switch (provider){
            case "kakao" -> new KakaoAppUserInfo(claims);
            case "google" -> new GoogleAppUserInfo(claims);
            default -> throw new RestApiException(PROVIDER_INVALID);
        };

        OAuthUserInfoValidator.validate(userInfo);

        return userInfo;
    }
}
