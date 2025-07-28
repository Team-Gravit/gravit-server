package gravit.code.auth.oauth.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import static gravit.code.auth.oauth.OAuthConstants.OAUTH_PROVIDERS;

@RequiredArgsConstructor
@Service
public class OAuthLoginUrlService {

    private final ClientRegistrationRepository clientRegistrationRepository;

    public String generateLoginUrl(String provider) {
        validateProvider(provider);

        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(provider.toLowerCase());
        String authorizationUri = registration.getProviderDetails().getAuthorizationUri();
        String clientId = registration.getClientId();
        String responseType = "code";
        String redirectUri = registration.getRedirectUri();
        String scope = String.join(" ", registration.getScopes()); // 공백이 표준

        return UriComponentsBuilder.fromUriString(authorizationUri)
                .queryParam("client_id", clientId)
                .queryParam("response_type", responseType)
                .queryParam("redirect_uri", redirectUri)
                .queryParam("scope",scope)
                .build().toUriString();
    }

    private void validateProvider(String provider) {
        if(provider == null || provider.isBlank()){
            throw new RestApiException(CustomErrorCode.PROVIDER_INVALID);
        }

        String lowerCaseProvider = provider.toLowerCase();
        if(!OAUTH_PROVIDERS.contains(lowerCaseProvider)){
            throw new RestApiException(CustomErrorCode.PROVIDER_INVALID);
        }
    }
}
