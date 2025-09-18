package gravit.code.auth.service.oauth;

import gravit.code.global.consts.RedirectHostConst;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import static gravit.code.auth.util.oauth.OAuthConstants.OAUTH_PROVIDERS;

@RequiredArgsConstructor
@Service
public class OAuthLoginUrlService {

    private final ClientRegistrationRepository clientRegistrationRepository;

    public String generateLoginUrl(String provider, String dest) {
        validateProvider(provider);
        String baseHost = validateDest(dest);
        String lowerCaseProvider = provider.toLowerCase();

        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(lowerCaseProvider);
        String authorizationUri = registration.getProviderDetails().getAuthorizationUri();
        String clientId = registration.getClientId();
        String responseType = "code";
        String redirectUri = baseHost + "/login/oauth2/code/" + lowerCaseProvider;
        String scope = String.join(" ", registration.getScopes()); // 공백이 표준

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
            throw new RestApiException(CustomErrorCode.DEST_NOT_VALID);
        }

        return base;
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
