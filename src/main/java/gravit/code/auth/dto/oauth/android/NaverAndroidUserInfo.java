package gravit.code.auth.dto.oauth.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import lombok.RequiredArgsConstructor;

import java.util.Map;

import static gravit.code.auth.dto.oauth.android.support.AndroidOAuthClaimsExtractor.getClaimAsString;
import static gravit.code.auth.dto.oauth.android.support.AndroidOAuthClaimsExtractor.extractProviderUserIdFromSub;
import static gravit.code.auth.dto.oauth.android.support.AndroidOAuthClaimsExtractor.isBlank;


@RequiredArgsConstructor
public class NaverAndroidUserInfo implements OAuthUserInfo {

    private static final String PROVIDER = "naver";
    private static final String CLAIM_SUB = "sub";
    private static final String CLAIM_EMAIL = "email";
    private static final String CLAIM_NAME = "nickname";

    private final Map<String, Object> claims;

    @Override
    public String getProvider() {
        return PROVIDER;
    }

    @Override
    public String getProviderId() {
        String providerId = getClaimAsString(claims, CLAIM_SUB);
        return extractProviderUserIdFromSub(providerId);
    }

    @Override
    public String getEmail() {
        String email = getClaimAsString(claims, CLAIM_EMAIL);
        return isBlank(email) ? null : email;
    }

    @Override
    public String getName() {
        String nickname = getClaimAsString(claims, CLAIM_NAME);
        return isBlank(nickname) ? null : nickname;
    }

}