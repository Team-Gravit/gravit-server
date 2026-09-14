package gravit.code.auth.service.oauth;

import gravit.code.auth.domain.Provider;
import gravit.code.global.consts.RedirectHostConst;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;
import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;

@RequiredArgsConstructor
@Service
public class OAuthLoginUrlService {

    public static final String REDIRECT_PATH_PREFIX = "/login/oauth2/code/";

    private final ClientRegistrationRepository clientRegistrationRepository;

    public String generateLoginUrl(
            String provider,
            String dest
    ) {
        String validProvider = getValidProvider(Provider.parse(provider));
        String baseHost = validateDest(dest);

        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(validProvider);
        String authorizationUri = registration.getProviderDetails().getAuthorizationUri();
        String clientId = registration.getClientId();
        String responseType = "code";
        String redirectUri = baseHost + REDIRECT_PATH_PREFIX + validProvider;
        String scope = String.join(" ", registration.getScopes());

        return UriComponentsBuilder.fromUriString(authorizationUri)
                .queryParam("client_id", clientId)
                .queryParam("response_type", responseType)
                .queryParam("redirect_uri", redirectUri)
                .queryParam("scope",scope)
                .build().toUriString();
    }

    private String validateDest(String dest) {
        String base = RedirectHostConst.DEST_BASE.get(dest);

        if(base == null || base.isBlank()){
            throw new RestApiException(DEST_NOT_VALID);
        }

        return base;
    }

    private String getValidProvider(Optional<String> provider) {
        return provider.orElseThrow(() -> new RestApiException(PROVIDER_INVALID));
    }
}
