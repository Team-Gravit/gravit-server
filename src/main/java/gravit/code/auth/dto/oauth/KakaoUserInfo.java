package gravit.code.auth.dto.oauth;

import java.util.Map;

import static gravit.code.auth.dto.oauth.support.OAuthAttributeExtractor.getAttributeAsString;
import static gravit.code.auth.dto.oauth.support.OAuthAttributeExtractor.getNestedAttributeAsString;

public record KakaoUserInfo(Map<String, Object> attributes) implements OAuthUserInfo {

    private static final String PROVIDER = "kakao";
    private static final String ATTRIBUTE_ID = "id";
    private static final String KAKAO_ACCOUNT_KEY = "kakao_account";
    private static final String ATTRIBUTE_EMAIL = "email";
    private static final String PROPERTIES_KEY = "properties";
    private static final String ATTRIBUTE_NICKNAME = "nickname";

    @Override
    public String getProvider() {
        return PROVIDER;
    }

    @Override
    public String getProviderId() {
        return getAttributeAsString(attributes, ATTRIBUTE_ID);
    }

    @Override
    public String getEmail() {
        return getNestedAttributeAsString(attributes, KAKAO_ACCOUNT_KEY, ATTRIBUTE_EMAIL);
    }

    @Override
    public String getName() {
        return getNestedAttributeAsString(attributes, PROPERTIES_KEY, ATTRIBUTE_NICKNAME);
    }
}
