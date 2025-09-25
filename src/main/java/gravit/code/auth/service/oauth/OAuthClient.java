package gravit.code.auth.service.oauth;

import org.springframework.util.MultiValueMap;

import java.util.Map;

public interface OAuthClient {

    Map<String, Object> getAccessTokenResponse(
            String tokenUri,
            MultiValueMap<String, String> tokenRequest
    );

    Map<String, Object> getUserInfoWithAccessToken(
            String uri,
            String accessToken
    );
}
