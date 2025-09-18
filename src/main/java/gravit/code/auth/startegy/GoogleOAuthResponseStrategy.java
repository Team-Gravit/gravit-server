package gravit.code.auth.startegy;


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
        System.out.println(attributes);
        return new GoogleUserInfo(attributes);
    }
}
