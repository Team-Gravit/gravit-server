package gravit.code.common.auth.oauth.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

@RequiredArgsConstructor
@Service
public class OAuthLoginUrlService {

    private final ClientRegistrationRepository clientRegistrationRepository;

    public String generateLoginUrl(String provider) {
        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(provider);

        String redirectUri = registration.getRedirectUri();
        return UriComponentsBuilder.fromUriString(registration.getProviderDetails().getAuthorizationUri())
                .queryParam("client_id", registration.getClientId())
                .queryParam("response_type", "code")
                .queryParam("redirect_uri", redirectUri)
                .queryParam("scope",String.join(" ", registration.getScopes()))
                .build().toUriString();
    }
}
