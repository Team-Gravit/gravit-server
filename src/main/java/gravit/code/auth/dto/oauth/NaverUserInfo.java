package gravit.code.auth.dto.oauth;

import java.util.Map;

public class NaverUserInfo implements OAuthUserInfo {

    private final Map<String, Object> attributes;
    public NaverUserInfo(Map<String, Object> attributes){
        this.attributes = (Map<String, Object>)attributes.get("response");
    }

    @Override
    public String getProvider() {
        return "naver";
    }

    @Override
    public String getProviderId() {
        return attributes.get("id").toString();
    }

    @Override
    public String getEmail() {
        return attributes.get("email").toString();
    }

    @Override
    public String getName() {
        return attributes.get("title").toString();
    }
}
