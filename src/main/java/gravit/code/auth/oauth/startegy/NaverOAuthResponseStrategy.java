package gravit.code.auth.oauth.startegy;


import gravit.code.auth.oauth.dto.NaverUserInfo;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class NaverOAuthResponseStrategy implements OAuthResponseStrategy {
    @Override
    public String getProviderName() {
        return "naver";
    }

    @Override
    public OAuthUserInfo createOAuthUserInfo(Map<String, Object> attributes) {
        return new NaverUserInfo(attributes);
    }
}
