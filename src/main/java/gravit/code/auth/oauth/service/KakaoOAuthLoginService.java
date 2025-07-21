package gravit.code.auth.oauth.service;

import gravit.code.auth.oauth.dto.KakaoUserInfo;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class KakaoOAuthLoginService implements OAuthLoginService {

    private final WebClient webClient;

    @Value("${spring.security.oauth2.client.registration.kakao.client-id}")
    private String clientId;

    @Value("${spring.security.oauth2.client.registration.kakao.client-secret}")
    private String clientSecret;

    @Value("${spring.security.oauth2.client.registration.kakao.redirect-uri}")
    private String redirectUri;

    @Value("${spring.security.oauth2.client.provider.kakao.token-uri}")
    private String tokenUri;

    @Value("${spring.security.oauth2.client.provider.kakao.user-info-uri}")
    private String userInfoUri;

    @Override
    public boolean supports(String provider) {
        return "kakao".equalsIgnoreCase(provider);
    }

    @Override
    public OAuthUserInfo getUserInfo(String code) {
        // 토큰 요청
        MultiValueMap<String, String> tokenRequest = new LinkedMultiValueMap<>();
        tokenRequest.add("grant_type", "authorization_code");
        tokenRequest.add("client_id", clientId);
        tokenRequest.add("client_secret", clientSecret);
        tokenRequest.add("redirect_uri", redirectUri);
        tokenRequest.add("code", code);

        Map tokenResponse = webClient.post()
                .uri(tokenUri)
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_FORM_URLENCODED_VALUE)
                .body(BodyInserters.fromFormData(tokenRequest))
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        String accessToken = (String) tokenResponse.get("access_token");

        // 사용자 정보 요청
        Map userInfo = webClient.get()
                .uri(userInfoUri)
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        return new KakaoUserInfo(userInfo);
    }
}
