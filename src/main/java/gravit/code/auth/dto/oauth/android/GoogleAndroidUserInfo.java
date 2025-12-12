package gravit.code.auth.dto.oauth.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import lombok.RequiredArgsConstructor;

import java.util.Map;

import static gravit.code.auth.dto.oauth.android.support.AndroidOAuthClaimsExtractor.*;

@RequiredArgsConstructor
public class GoogleAndroidUserInfo implements OAuthUserInfo {

    private static final String PROVIDER = "google";
    private static final String CLAIM_SUB = "sub";
    private static final String CLAIM_EMAIL = "email";
    private static final String CLAIM_NAME = "name";

    private final Map<String, Object> claims;

    @Override
    public String getProvider() {
        return PROVIDER;
    }

    @Override
    public String getProviderId() {
        String providerId = getClaimAsString(claims, CLAIM_SUB);
        return isBlank(providerId) ? null : providerId;
    }

    @Override
    public String getEmail() {
        String email = getClaimAsString(claims, CLAIM_EMAIL);
        return isBlank(email) ? null : email;
    }

    @Override
    public String getName() {
        String name = getClaimAsString(claims, CLAIM_NAME);
        return isBlank(name) ? null : name;
    }


}
