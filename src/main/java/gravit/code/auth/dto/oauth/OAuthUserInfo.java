package gravit.code.auth.dto.oauth;

public interface OAuthUserInfo {

    String getProvider();

    String getProviderId();

    String getEmail();

    String getName();
}
