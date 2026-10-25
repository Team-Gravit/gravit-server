package gravit.code.auth.dto.oauth;

import java.util.Map;

import static gravit.code.auth.dto.oauth.support.OAuthAttributeExtractor.getAttributeAsString;

public record AppleUserInfo(Map<String, Object> claims) implements OAuthUserInfo {

    public static final String PROVIDER = "apple";
    public static final String DEFAULT_NAME = "애플사용자";

    private static final String CLAIM_SUB = "sub";
    private static final String CLAIM_EMAIL = "email";

    @Override
    public String getProvider() {
        return PROVIDER;
    }

    @Override
    public String getProviderId() {
        return getAttributeAsString(claims, CLAIM_SUB);
    }

    @Override
    public String getEmail() {
        return getAttributeAsString(claims, CLAIM_EMAIL);
    }

    @Override
    public String getName() {
        return DEFAULT_NAME;
    }
}
