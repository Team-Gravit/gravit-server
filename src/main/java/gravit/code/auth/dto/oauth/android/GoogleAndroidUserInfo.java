package gravit.code.auth.dto.oauth.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import lombok.RequiredArgsConstructor;

import java.util.Map;

import static gravit.code.auth.util.oauth.OAuthClaimsUtil.*;

@RequiredArgsConstructor
public class GoogleAndroidUserInfo implements OAuthUserInfo {

    private static final String PROVIDER = "google";

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
        String email = getString(claims, "email"); // scope에 email 필요
        return isBlank(email) ? null : email;
    }

    @Override
    public String getName() {
        String name = getString(claims, "name");
        return isBlank(name) ? null : name;
    }


}
