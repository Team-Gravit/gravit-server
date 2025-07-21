package gravit.code.auth.oauth.service;

import gravit.code.auth.oauth.dto.OAuthUserInfo;

public interface OAuthLoginService {
    boolean supports(String provider);
    OAuthUserInfo getUserInfo(String code);
}
