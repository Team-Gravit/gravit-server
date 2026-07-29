package gravit.code.auth.service.oauth;

import gravit.code.auth.domain.Provider;
import gravit.code.global.config.RedirectDestProps;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Optional;

@RequiredArgsConstructor
@Service
public class OAuthLoginUrlService {

    private final ClientRegistrationRepository clientRegistrationRepository;
    private final RedirectDestProps redirectDestProps;

    public String generateLoginUrl(
            String provider,
            String dest
    ) {
        String validProvider = getValidProvider(Provider.parse(provider));
        String baseHost = redirectDestProps.resolveBaseUrl(dest);

        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(validProvider);
        String authorizationUri = registration.getProviderDetails().getAuthorizationUri();
        String clientId = registration.getClientId();
        String responseType = "code";
        String redirectUri = baseHost + "/login/oauth2/code/" + validProvider;
        String scope = String.join(" ", registration.getScopes()); // 공백이 표준

        return UriComponentsBuilder.fromUriString(authorizationUri)
                .queryParam("client_id", clientId)
                .queryParam("response_type", responseType)
                .queryParam("redirect_uri", redirectUri)
                .queryParam("scope",scope)
                .build().toUriString();
    }

    private String getValidProvider(Optional<String> provider) {
        return provider.orElseThrow(() -> new RestApiException(CustomErrorCode.PROVIDER_INVALID));
    }
}
