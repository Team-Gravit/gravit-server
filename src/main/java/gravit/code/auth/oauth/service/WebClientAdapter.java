package gravit.code.auth.oauth.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientException;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebClientAdapter {
    private final WebClient webClient;

    public Map<String, Object> getTokenResponse(String tokenUri, MultiValueMap<String, String> tokenRequest) {
        try {
            return webClient.post()
                    .uri(tokenUri)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_FORM_URLENCODED_VALUE)
                    .body(BodyInserters.fromFormData(tokenRequest))
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {})
                    .blockOptional()
                    .orElseThrow(() -> new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR));
        } catch (WebClientResponseException.BadRequest e) {
            log.warn("유효하지 않은 AuthCode 요청 : {}",e.getCause().getMessage());
            throw new RestApiException(CustomErrorCode.AUTH_CODE_INVALID);
        } catch (WebClientException e) {
            log.error("OAuth 서버 통신 오류", e);
            throw new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR);
        }
    }

    public Map<String, Object> getWithAccessToken(String uri, String accessToken) {
        try {
            return webClient.get()
                    .uri(uri)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {})
                    .blockOptional()
                    .orElseThrow(() -> new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR));
        } catch (WebClientResponseException.BadRequest e) {
            log.warn("유효하지 않은 AccessToken 요청 : {}", e.getCause().getMessage());
            throw new RestApiException(CustomErrorCode.OAUTH_ACCESS_TOKEN_INVALID);
        } catch (WebClientException e) {
            log.error("OAuth 서버 통신 오류", e);
            throw new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR);
        }
    }

}
