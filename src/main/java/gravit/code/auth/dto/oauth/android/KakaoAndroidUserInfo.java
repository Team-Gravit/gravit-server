package gravit.code.auth.dto.oauth.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;

import java.util.Map;

import static gravit.code.auth.dto.oauth.support.OAuthAttributeExtractor.getAttributeAsString;

public record KakaoAndroidUserInfo(Map<String, Object> claims) implements OAuthUserInfo {

    private static final String PROVIDER = "kakao";
    private static final String CLAIM_SUB = "sub";
    private static final String CLAIM_EMAIL = "email";
    private static final String CLAIM_NAME = "nickname";

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
        return getAttributeAsString(claims, CLAIM_NAME);
    }
}
