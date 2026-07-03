package gravit.code.auth.dto.oauth;

import java.util.Map;

public record NaverUserInfo(Map<String, Object> attributes) implements OAuthUserInfo {

    public NaverUserInfo {
        attributes = (Map<String, Object>) attributes.get("response");
    }

    @Override
    public String getProvider() {
        return "naver";
    }

    @Override
    public String getProviderId() {
        return attributes.get("id").toString();
    }

    @Override
    public String getEmail() {
        return attributes.get("email").toString();
    }

    @Override
    public String getName() {
        return attributes.get("name").toString();
    }
}
