package gravit.code.auth.service.oauth;

import gravit.code.auth.domain.Provider;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.strategy.OAuthResponseFactory;
import gravit.code.global.consts.RedirectHostConst;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.AUTH_CODE_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;
import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthUserInfoService {

    private static final String GRANT_TYPE = "authorization_code";

    private final OAuthResponseFactory oAuthResponseFactory;
    private final OAuthClient oAuthClient;

    private final ClientRegistrationRepository clientRegistrationRepository;

    public OAuthUserInfo getUserInfo(
            String authCode,
            String provider,
            String dest
    ) {
        validateAuthCode(authCode);
        String baseHost = validateDest(dest);

        String validProvider = getValidProvider(Provider.parse(provider));

        String decodedCode = URLDecoder.decode(authCode, StandardCharsets.UTF_8);

        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(validProvider);

        String redirectUri = baseHost + OAuthLoginUrlService.REDIRECT_PATH_PREFIX + validProvider;
        String accessToken = getAccessToken(registration, decodedCode, redirectUri);

        Map<String, Object> userInfo = getUserInfo(registration, accessToken);

        return oAuthResponseFactory.createOAuthUserInfo(validProvider, userInfo);
    }

    private Map<String, Object> getUserInfo(
            ClientRegistration registration,
            String accessToken
    ) {
        String userInfoUri = registration.getProviderDetails().getUserInfoEndpoint().getUri();

        return oAuthClient.getUserInfoWithAccessToken(userInfoUri, accessToken);
    }

    private String getAccessToken(
            ClientRegistration registration,
            String decodedCode,
            String redirectUri
    ) {
        MultiValueMap<String, String> tokenRequest = new LinkedMultiValueMap<>();
        tokenRequest.add("grant_type", GRANT_TYPE);
        tokenRequest.add("client_id", registration.getClientId());
        tokenRequest.add("client_secret", registration.getClientSecret());
        tokenRequest.add("redirect_uri", redirectUri);
        tokenRequest.add("code", decodedCode);

        String tokenUri = registration.getProviderDetails().getTokenUri();

        Map<String, Object> tokenResponse = oAuthClient.getAccessTokenResponse(tokenUri, tokenRequest);
        return (String) tokenResponse.get("access_token");
    }

    private String validateDest(String dest) {
        String base = RedirectHostConst.DEST_BASE.get(dest);

        if(base == null || base.isBlank()){
            throw new RestApiException(DEST_NOT_VALID);
        }

        return base;
    }

    private void validateAuthCode(String authCode) {
        if(authCode == null || authCode.isBlank()){
            throw new RestApiException(AUTH_CODE_INVALID);
        }
    }

    private String getValidProvider(Optional<String> provider) {
        return provider.orElseThrow(() -> new RestApiException(PROVIDER_INVALID));
    }
}
