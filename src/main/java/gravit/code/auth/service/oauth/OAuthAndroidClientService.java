package gravit.code.auth.service.oauth;

import gravit.code.auth.client.config.Auth0Props;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.strategy.android.AndroidUserInfoFactory;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthAndroidClientService {

    private final JwtDecoder jwtDecoder;
    private final Auth0Props props;

    public OAuthUserInfo parseIdToken(String idToken) {
        validateNullAndBlankIdToken(idToken);

        // idToken 을 jwt 로 디코딩
        Jwt jwt = decodingIdTokenToJwt(idToken);

        // 수신자 정보와 비교, client-id 로 유효한 idToken 인지 판단
        List<String> aud = jwt.getAudience();
        validateClientIdByIdToken(aud);
        
        // idToken 에서 claim 획득
        Map<String, Object> claims = jwt.getClaims();
        log.info("claims: {}", claims);

        return AndroidUserInfoFactory.fromClaims(claims);
    }

    private void validateClientIdByIdToken(List<String> aud) {
        if(aud.isEmpty() || !aud.contains(props.androidClientId())) {
            throw new RestApiException(CustomErrorCode.ID_TOKEN_CLIENT_ID_INVALID);
        }
    }

    private Jwt decodingIdTokenToJwt(String idToken) {
        try{
            return jwtDecoder.decode(idToken);
        }catch (Exception e) {
            throw new RestApiException(CustomErrorCode.FAIL_DECODE_ID_TOKEN_TO_JWT);
        }
    }

    private static void validateNullAndBlankIdToken(String idToken) {
        if (idToken == null || idToken.isEmpty()) {
            throw new RestApiException(CustomErrorCode.OAUTH_ID_TOKEN_INVALID);
        }
    }
}
