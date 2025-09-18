package gravit.code.auth.startegy.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.oauth.android.GoogleAndroidUserInfo;
import gravit.code.auth.dto.oauth.android.KakaoAndroidUserInfo;
import gravit.code.auth.dto.oauth.android.NaverAndroidUserInfo;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.extern.slf4j.Slf4j;

import java.util.Locale;
import java.util.Map;

import static gravit.code.auth.util.oauth.OAuthClaimsUtil.getString;
import static gravit.code.auth.util.oauth.OAuthClaimsUtil.isBlank;

@Slf4j
public final class AndroidUserInfoFactory {
    private AndroidUserInfoFactory() {}

    public static OAuthUserInfo fromClaims(Map<String, Object> claims) {
        String provider = resolveProvider(claims);
        log.info("resulve provider : {}", provider);

        return switch (provider){
            case "kakao" -> new KakaoAndroidUserInfo(claims);
            case "naver" -> new NaverAndroidUserInfo(claims);
            case "google" -> new GoogleAndroidUserInfo(claims);
            default -> throw new RestApiException(CustomErrorCode.PROVIDER_INVALID);
        };
    }

    // sub 꺼내기
    private static String resolveProvider(Map<String, Object> claims) {
        String sub = getString(claims, "sub");
        return providerFromSub(sub);
    }
    
    // sub 에서 provider 꺼내기
    private static String providerFromSub(String sub) {
        if (isBlank(sub)) return "unknown";

        String[] providerPart = sub.split("\\|");
        if (providerPart.length >= 2 && "oauth2".equalsIgnoreCase(providerPart[0])) {
            return providerPart[1].toLowerCase(Locale.ROOT);
        }else if(providerPart.length >= 2 && "google-oauth2".equals(providerPart[0])) {
            return "google";
        }

        return providerPart[0].toLowerCase(Locale.ROOT);
    }
}
