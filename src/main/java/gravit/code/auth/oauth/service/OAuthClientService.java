package gravit.code.auth.oauth.service;

import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.auth.oauth.startegy.OAuthResponseFactory;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
import org.springframework.web.reactive.function.client.WebClientException;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import static gravit.code.auth.oauth.OAuthConstants.OAUTH_PROVIDERS;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthClientService {
    private final static String GRANT_TYPE = "authorization_code";

    private final ClientRegistrationRepository clientRegistrationRepository;
    private final OAuthResponseFactory oAuthResponseFactory;
    private final WebClient webClient;

    public OAuthUserInfo getUserInfo(String authCode, String provider) {
        validateProvider(provider);
        validateAuthCode(authCode);

        // 웹에서 특수 문자나 공백 등이 URL 인코딩 된 상태로 전달되는 문제를 해결하기 위함
        String decodedCode = URLDecoder.decode(authCode, StandardCharsets.UTF_8);
        String lowerCaseProvider = provider.toLowerCase();

        // OAuth 설정 정보 가져오기
        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(lowerCaseProvider);

        // 토큰 요청
        String accessToken = getAccessToken(registration, decodedCode);

        // 사용자 정보 요청
        Map<String, Object> userInfo = getUserInfo(registration, accessToken);

        return oAuthResponseFactory.createOAuthUserInfo(lowerCaseProvider, userInfo);
    }

    private Map<String, Object> getUserInfo(ClientRegistration registration, String accessToken) {

        // 사용자 정보를 조회하기 위한 엔드포인트
        String userInfoUri = registration.getProviderDetails().getUserInfoEndpoint().getUri();

        Map<String, Object> userInfo;
        try{
            userInfo = webClient.get()
                    .uri(userInfoUri)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Map<String,Object>>() {})
                    .blockOptional()
                    .orElseThrow(()-> new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR));
        }catch (WebClientResponseException.BadRequest e){
            log.warn("유효하지 않은 AccessToken 요청 : {}", e.getCause().getMessage());
            throw new RestApiException(CustomErrorCode.OAUTH_ACCESS_TOKEN_INVALID);
        }catch (WebClientException e){
            log.error("OAuth 서버 통신 오류", e);
            throw new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR);
        }

        return userInfo;
    }

    private String getAccessToken(ClientRegistration registration, String decodedCode) {
        
        // 요청 만들기
        MultiValueMap<String, String> tokenRequest = new LinkedMultiValueMap<>();
        tokenRequest.add("grant_type", GRANT_TYPE);
        tokenRequest.add("client_id", registration.getClientId());
        tokenRequest.add("client_secret", registration.getClientSecret());
        tokenRequest.add("redirect_uri", registration.getRedirectUri());
        tokenRequest.add("code", decodedCode);

        // AccessToken 을 발급받기 위한 엔드포인트
        String tokenUri = registration.getProviderDetails().getTokenUri();

        Map<String, Object> tokenResponse;
        try{
            tokenResponse = webClient.post()
                    .uri(tokenUri)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_FORM_URLENCODED_VALUE)
                    .body(BodyInserters.fromFormData(tokenRequest))
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Map<String,Object>>() {})
                    .blockOptional()
                    .orElseThrow(()-> new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR));
        }catch (WebClientResponseException.BadRequest e){
            log.warn("유효하지 않은 AuthCode 요청 : {}",e.getCause().getMessage());
            throw new RestApiException(CustomErrorCode.AUTH_CODE_INVALID);
        }catch (WebClientException e){
            log.error("OAuth 서버 통신 오류", e);
            throw new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR);
        }

        return (String) tokenResponse.get("access_token");
    }


    private void validateAuthCode(String authCode) {
        if(authCode == null || authCode.isBlank()){
            throw new RestApiException(CustomErrorCode.AUTH_CODE_INVALID);
        }
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
