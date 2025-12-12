package gravit.code.auth.strategy.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.oauth.android.GoogleAndroidUserInfo;
import gravit.code.auth.dto.oauth.android.KakaoAndroidUserInfo;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public final class AndroidUserInfoFactory {
    private AndroidUserInfoFactory() {}

    public static OAuthUserInfo fromClaims(String provider, Map<String, Object> claims) {
        return switch (provider){
            case "kakao" -> new KakaoAndroidUserInfo(claims);
            case "google" -> new GoogleAndroidUserInfo(claims);
            default -> throw new RestApiException(CustomErrorCode.PROVIDER_INVALID);
        };
    }
}
