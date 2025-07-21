package gravit.code.auth.oauth.startegy;

import gravit.code.auth.oauth.dto.OAuthUserInfo;

import java.util.Map;

// OAuth2 인증 제공자별로 다른 사용자 정보 처리 전략을 정의에 사용
public interface OAuthResponseStrategy {

    // OAuth2 제공자 이름을 반환
    String getProviderName();

    // OAuth2 제공자로부터 받은 사용자 정보를 가공하여 통일되게 사용
    OAuthUserInfo createOAuthUserInfo(Map<String, Object> attributes);
}
