package gravit.code.auth.oauth.startegy;


import gravit.code.auth.oauth.dto.GoogleUserInfo;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
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
        System.out.println(attributes);
        return new GoogleUserInfo(attributes);
    }
}
