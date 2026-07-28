package gravit.code.auth.dto.oauth;

import java.util.Map;

import static gravit.code.auth.dto.oauth.support.OAuthAttributeExtractor.getAttributeAsString;
import static gravit.code.auth.dto.oauth.support.OAuthAttributeExtractor.getNestedAttributes;

public record NaverUserInfo(Map<String, Object> attributes) implements OAuthUserInfo {

    private static final String PROVIDER = "naver";
    private static final String RESPONSE_KEY = "response";
    private static final String ATTRIBUTE_ID = "id";
    private static final String ATTRIBUTE_EMAIL = "email";
    private static final String ATTRIBUTE_NAME = "name";

    public NaverUserInfo {
        attributes = getNestedAttributes(attributes, RESPONSE_KEY);
    }

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
        return getAttributeAsString(attributes, ATTRIBUTE_EMAIL);
    }

    @Override
    public String getName() {
        return getAttributeAsString(attributes, ATTRIBUTE_NAME);
    }
}
