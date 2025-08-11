package gravit.code.auth.oauth.dto.android;

import gravit.code.auth.oauth.dto.OAuthUserInfo;
import lombok.RequiredArgsConstructor;

import java.util.Map;

import static gravit.code.auth.oauth.util.OAuthClaimsUtil.*;


@RequiredArgsConstructor
public class KakaoAndroidUserInfo implements OAuthUserInfo {

    private static final String PROVIDER = "kakao";

    private final Map<String, Object> claims;

    @Override
    public String getProvider() {
        return PROVIDER;
    }

    @Override
    public String getProviderId() {
        String sub = getString(claims, "sub");
        return providerUserIdFromSub(sub);
    }

    @Override
    public String getEmail() {
        String email = getString(claims, "email");
        return isBlank(email) ? null : email;
    }

    @Override
    public String getName() {
        String nickname = getString(claims, "nickname");
        return isBlank(nickname) ? null : nickname;
    }
}