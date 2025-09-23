package gravit.code.auth.strategy;


import gravit.code.auth.dto.oauth.NaverUserInfo;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
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
