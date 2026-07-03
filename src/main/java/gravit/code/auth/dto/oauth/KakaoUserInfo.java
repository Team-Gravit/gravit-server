package gravit.code.auth.dto.oauth;

import java.util.Map;

public record KakaoUserInfo(Map<String, Object> attributes) implements OAuthUserInfo {

    @Override
    public String getProvider() {
        return "kakao";
    }

    @Override
    public String getProviderId() {
        return attributes.get("id").toString();
    }

    @Override
    public String getEmail() {
        return ((Map)attributes.get("kakao_account")).get("email").toString();
    }

    @Override
    public String getName() {
        return ((Map)attributes.get("properties")).get("nickname").toString();
    }
}
