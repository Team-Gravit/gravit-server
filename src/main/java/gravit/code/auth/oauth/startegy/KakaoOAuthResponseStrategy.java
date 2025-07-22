package gravit.code.auth.oauth.startegy;

import gravit.code.auth.oauth.dto.KakaoUserInfo;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class KakaoOAuthResponseStrategy implements OAuthResponseStrategy {
    @Override
    public String getProviderName() {
        return "kakao";
    }

    @Override
    public OAuthUserInfo createOAuthUserInfo(Map<String, Object> attributes) {
        System.out.println(attributes);
        return new KakaoUserInfo(attributes);
    }
}
