package gravit.code.auth.dto.oauth;

import java.util.Map;

import static gravit.code.auth.dto.oauth.support.OAuthAttributeExtractor.getAttributeAsString;

public record GoogleUserInfo(Map<String, Object> attributes) implements OAuthUserInfo {

    private static final String PROVIDER = "google";
    private static final String ATTRIBUTE_SUB = "sub";
    private static final String ATTRIBUTE_EMAIL = "email";
    private static final String ATTRIBUTE_NAME = "name";

    @Override
    public String getProvider() {
        return PROVIDER;
    }

    @Override
    public String getProviderId() {
        return getAttributeAsString(attributes, ATTRIBUTE_SUB);
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
