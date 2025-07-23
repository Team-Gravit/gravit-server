package gravit.code.auth.oauth.service;

import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.auth.oauth.startegy.OAuthResponseFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class OAuthClientService {
    private final ClientRegistrationRepository clientRegistrationRepository;
    private final OAuthResponseFactory oAuthResponseFactory;
    private final WebClient webClient;

    public OAuthUserInfo getUserInfo(String code, String provider) {
        String decodedCode = URLDecoder.decode(code, StandardCharsets.UTF_8);

        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(provider);

        // 토큰 요청
        MultiValueMap<String, String> tokenRequest = new LinkedMultiValueMap<>();
        tokenRequest.add("grant_type", "authorization_code");
        tokenRequest.add("client_id", registration.getClientId());
        tokenRequest.add("client_secret", registration.getClientSecret());
        tokenRequest.add("redirect_uri", registration.getRedirectUri());
        tokenRequest.add("code", decodedCode);

        String tokenUri = registration.getProviderDetails().getTokenUri();
        Map<String, Object> tokenResponse = webClient.post()
                .uri(tokenUri)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_FORM_URLENCODED_VALUE)
                .body(BodyInserters.fromFormData(tokenRequest))
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<Map<String,Object>>() {})
                .blockOptional()
                .orElseThrow(RuntimeException::new);


        String accessToken = (String) tokenResponse.get("access_token");

        // 사용자 정보 요청
        String userInfoUri = registration.getProviderDetails().getUserInfoEndpoint().getUri();
        Map<String, Object> userInfo = webClient.get()
                .uri(userInfoUri)
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<Map<String,Object>>() {})
                .blockOptional()
                .orElseThrow(RuntimeException::new);

        return oAuthResponseFactory.createOAuthUserInfo(provider, userInfo);
    }
}
