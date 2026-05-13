package gravit.code.auth.infrastructure.client;

import gravit.code.auth.service.oauth.OAuthClient;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.net.http.HttpTimeoutException;
import java.util.Map;
import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
public class OAuthHttpClientAdapter implements OAuthClient {
    private final RestClient restClient;

    @Override
    public Map<String, Object> getAccessTokenResponse(
            String tokenUri,
            MultiValueMap<String, String> tokenRequest
    ) {
        try {
            return Optional.ofNullable(
                    restClient.post()
                            .uri(tokenUri)
                            .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                            .body(tokenRequest)
                            .retrieve()
                            .body(new ParameterizedTypeReference<Map<String, Object>>() {})
            ).orElseThrow(() -> new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR));
        } catch (HttpClientErrorException.BadRequest e) {
            log.warn("유효하지 않은 AuthCode 요청 : {}", e.getMessage());
            throw new RestApiException(CustomErrorCode.AUTH_CODE_INVALID);
        } catch(ResourceAccessException e){ // timeout 과 일반 네트워크 에러를 구분
            if(e.getCause() instanceof HttpTimeoutException){
                log.warn("OAuth 서버 timeout 발생", e);
            }else{
                log.warn("OAuth 서버 통신 오류", e);
            }
            throw new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR);
        } catch (RestClientException e) {
            log.error("OAuth 서버 통신 오류", e);
            throw new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR);
        }
    }

    @Override
    public Map<String, Object> getUserInfoWithAccessToken(
            String uri,
            String accessToken
    ) {
        try {
            return Optional.ofNullable(
                    restClient.get()
                            .uri(uri)
                            .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                            .retrieve()
                            .body(new ParameterizedTypeReference<Map<String, Object>>() {})
            ).orElseThrow(() -> new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR));
        } catch (HttpClientErrorException.BadRequest e) {
            log.warn("유효하지 않은 AccessToken 요청 : {}", e.getMessage());
            throw new RestApiException(CustomErrorCode.OAUTH_ACCESS_TOKEN_INVALID);
        } catch (RestClientException e) {
            log.error("OAuth 서버 통신 오류", e);
            throw new RestApiException(CustomErrorCode.OAUTH_SERVER_ERROR);
        }
    }
}
