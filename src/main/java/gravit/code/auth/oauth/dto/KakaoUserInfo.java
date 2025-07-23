package gravit.code.auth.oauth.dto;

import lombok.RequiredArgsConstructor;

import java.util.Map;

@RequiredArgsConstructor
public class KakaoUserInfo implements OAuthUserInfo {

    private final Map<String, Object> attributes;

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
