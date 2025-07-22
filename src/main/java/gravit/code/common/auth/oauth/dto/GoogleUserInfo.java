package gravit.code.common.auth.oauth.dto;

import lombok.RequiredArgsConstructor;

import java.util.Map;

@RequiredArgsConstructor
public class GoogleUserInfo implements OAuthUserInfo {

    private final Map<String, Object> attributes;

    @Override
    public String getProvider() {
        return "google";
    }

    @Override
    public String getProviderId() {
        return attributes.get("sub").toString();
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
