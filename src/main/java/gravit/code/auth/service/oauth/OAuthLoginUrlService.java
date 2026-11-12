package gravit.code.auth.service.oauth;

import gravit.code.auth.domain.AppleClient;
import gravit.code.auth.domain.Provider;
import gravit.code.auth.dto.oauth.AppleUserInfo;
import gravit.code.auth.dto.response.LoginUrlResponse;
import gravit.code.auth.infrastructure.config.AppleOAuthProps;
import gravit.code.auth.support.RedirectHostResolver;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;

@RequiredArgsConstructor
@Service
public class OAuthLoginUrlService {

    public static final String REDIRECT_PATH_PREFIX = "/login/oauth2/code/";
    private static final String RESPONSE_TYPE = "code";
    private static final String APPLE_AUTHORIZATION_URI = "https://appleid.apple.com/auth/authorize";
    private static final String APPLE_SCOPE = "email";
    private static final String APPLE_RESPONSE_MODE = "form_post";

    private final OAuthStateService oAuthStateService;

    private final RedirectHostResolver redirectHostResolver;

    private final ClientRegistrationRepository clientRegistrationRepository;
    private final AppleOAuthProps appleOAuthProps;

    public LoginUrlResponse generateLoginUrl(
            String provider,
            String origin,
            String dest
    ) {
        String validProvider = parseProvider(provider);
        String baseHost = redirectHostResolver.resolve(origin, dest);

        String state = oAuthStateService.issue(validProvider);

        String loginUrl = AppleUserInfo.PROVIDER.equals(validProvider)
                ? generateAppleLoginUrl(baseHost, state)
                : generateRegistrationLoginUrl(validProvider, baseHost, state);

        return LoginUrlResponse.of(loginUrl, state);
    }

    private String parseProvider(String provider) {
        if (provider != null && AppleUserInfo.PROVIDER.equalsIgnoreCase(provider.trim())) {
            return AppleUserInfo.PROVIDER;
        }

        return Provider.parse(provider)
                .orElseThrow(() -> new RestApiException(PROVIDER_INVALID));
    }

    private String generateAppleLoginUrl(
            String baseHost,
            String state
    ) {
        return UriComponentsBuilder.fromUriString(APPLE_AUTHORIZATION_URI)
                .queryParam("client_id", appleOAuthProps.clientId(AppleClient.WEB))
                .queryParam("redirect_uri", baseHost + REDIRECT_PATH_PREFIX + AppleUserInfo.PROVIDER)
                .queryParam("response_type", RESPONSE_TYPE)
                .queryParam("scope", APPLE_SCOPE)
                .queryParam("response_mode", APPLE_RESPONSE_MODE)
                .queryParam("state", state)
                .build().toUriString();
    }

    private String generateRegistrationLoginUrl(
            String validProvider,
            String baseHost,
            String state
    ) {
        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(validProvider);
        String authorizationUri = registration.getProviderDetails().getAuthorizationUri();
        String clientId = registration.getClientId();
        String redirectUri = baseHost + REDIRECT_PATH_PREFIX + validProvider;
        String scope = String.join(" ", registration.getScopes());

        return UriComponentsBuilder.fromUriString(authorizationUri)
                .queryParam("client_id", clientId)
                .queryParam("response_type", RESPONSE_TYPE)
                .queryParam("redirect_uri", redirectUri)
                .queryParam("scope", scope)
                .queryParam("state", state)
                .build().toUriString();
    }
}
