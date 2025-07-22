package gravit.code.common.auth.oauth.startegy;


import gravit.code.common.auth.oauth.dto.NaverUserInfo;
import gravit.code.common.auth.oauth.dto.OAuthUserInfo;
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
