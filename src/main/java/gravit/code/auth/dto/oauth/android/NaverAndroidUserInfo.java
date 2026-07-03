package gravit.code.auth.dto.oauth.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;

public record NaverAndroidUserInfo(
        String providerId,
        String email,
        String nickname
) implements OAuthUserInfo {

    @Override
    public String getProvider() {
        return "naver";
    }

    @Override
    public String getProviderId() {
        return providerId;
    }

    @Override
    public String getEmail() {
        return email;
    }

    @Override
    public String getName() {
        return nickname;
    }
}
