package gravit.code.auth.strategy;


import gravit.code.auth.dto.oauth.GoogleUserInfo;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class GoogleOAuthResponseStrategy implements OAuthResponseStrategy {
    @Override
    public String getProviderName() {
        return "google";
    }

    @Override
    public OAuthUserInfo createOAuthUserInfo(Map<String, Object> attributes) {
        return new GoogleUserInfo(attributes);
    }
}
