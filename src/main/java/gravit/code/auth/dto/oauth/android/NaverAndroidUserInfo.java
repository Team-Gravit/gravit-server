package gravit.code.auth.dto.oauth.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;


public class NaverAndroidUserInfo implements OAuthUserInfo {
    private final String providerId;
    private final String email;
    private final String nickname;

    public NaverAndroidUserInfo(
            String providerId,
            String email,
            String nickname
    ) {
        this.providerId = providerId;
        this.email = email;
        this.nickname = nickname;
    }

    @Override
    public String getProvider() {
        return "naver";
    }

    @Override
    public String getProviderId() {
        return this.providerId;
    }

    @Override
    public String getEmail() {
        return this.email;
    }

    @Override
    public String getName() {
        return this.nickname;
    }

}