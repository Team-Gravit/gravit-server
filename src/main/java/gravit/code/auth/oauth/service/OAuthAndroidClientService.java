package gravit.code.auth.oauth.service;

import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.auth.oauth.startegy.OAuthResponseFactory;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;

import java.util.Map;

import static gravit.code.auth.oauth.OAuthConstants.OAUTH_PROVIDERS;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthAndroidClientService {

    private final ClientRegistrationRepository clientRegistrationRepository;
    private final OAuthResponseFactory oAuthResponseFactory;
    private final WebClientAdapter webClientAdapter;

    public OAuthUserInfo getUserInfo(String oauthAccessToken, String provider) {
        validateProvider(provider);
        validateOAuthAccessToken(oauthAccessToken);

        // 웹에서 특수 문자나 공백 등이 URL 인코딩 된 상태로 전달되는 문제를 해결하기 위함
        String lowerCaseProvider = provider.toLowerCase();

        // OAuth 설정 정보 가져오기
        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(lowerCaseProvider);

        // 사용자 정보 요청
        Map<String, Object> userInfo = getUserInfo(registration, oauthAccessToken);

        return oAuthResponseFactory.createOAuthUserInfo(lowerCaseProvider, userInfo);
    }

    private Map<String, Object> getUserInfo(ClientRegistration registration, String accessToken) {

        // 사용자 정보를 조회하기 위한 엔드포인트
        String userInfoUri = registration.getProviderDetails().getUserInfoEndpoint().getUri();

        return webClientAdapter.getUserInfoWithAccessToken(userInfoUri, accessToken);
    }

    private void validateOAuthAccessToken(String authCode) {
        if(authCode == null || authCode.isBlank()){
            throw new RestApiException(CustomErrorCode.OAUTH_ACCESS_TOKEN_INVALID);
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
