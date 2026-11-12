package gravit.code.auth.strategy;

import gravit.code.auth.dto.oauth.OAuthUserInfo;

import java.util.Map;

public interface OAuthResponseStrategy {

    String getProviderName();

    OAuthUserInfo createOAuthUserInfo(Map<String, Object> attributes);
}
