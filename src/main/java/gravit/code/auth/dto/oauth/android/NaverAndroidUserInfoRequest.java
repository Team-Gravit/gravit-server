package gravit.code.auth.dto.oauth.android;

public record NaverAndroidUserInfoRequest(
        String email,
        String providerId,
        String nickname
){

}