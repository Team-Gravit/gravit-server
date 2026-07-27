package gravit.code.auth.service.oauth.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.service.oauth.OAuthClient;
import gravit.code.auth.strategy.OAuthResponseFactory;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Service;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_ACCESS_TOKEN_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_USER_INFO_INVALID;

@Service
@RequiredArgsConstructor
@Slf4j
public class NaverAndroidUserInfoService {

    private static final String PROVIDER = "naver";
    private static final String RESULT_CODE_KEY = "resultcode";
    private static final String RESULT_CODE_SUCCESS = "00";
    private static final String RESPONSE_KEY = "response";

    private final ClientRegistrationRepository clientRegistrationRepository;
    private final OAuthClient oAuthClient;
    private final OAuthResponseFactory oAuthResponseFactory;

    public OAuthUserInfo getUserInfo(String accessToken) {
        validateAccessToken(accessToken);

        ClientRegistration registration = clientRegistrationRepository.findByRegistrationId(PROVIDER);
        String userInfoUri = registration.getProviderDetails().getUserInfoEndpoint().getUri();

        Map<String, Object> userInfo = oAuthClient.getUserInfoWithAccessToken(userInfoUri, accessToken);
        validateResultCode(userInfo);

        log.info("네이버 사용자 정보 조회 성공");
        return oAuthResponseFactory.createOAuthUserInfo(PROVIDER, userInfo);
    }

    private void validateAccessToken(String accessToken) {
        if (accessToken == null || accessToken.isBlank()) {
            throw new RestApiException(OAUTH_ACCESS_TOKEN_INVALID);
        }
    }

    private void validateResultCode(Map<String, Object> userInfo) {
        Object resultCode = userInfo.get(RESULT_CODE_KEY);

        if (!RESULT_CODE_SUCCESS.equals(resultCode)) {
            log.warn("네이버 사용자 정보 조회에 실패하였습니다 : resultcode : {}", resultCode);
            throw new RestApiException(OAUTH_USER_INFO_INVALID);
        }

        if (!(userInfo.get(RESPONSE_KEY) instanceof Map)) {
            log.warn("네이버 사용자 정보 응답에 response 가 존재하지 않습니다.");
            throw new RestApiException(OAUTH_USER_INFO_INVALID);
        }
    }
}
