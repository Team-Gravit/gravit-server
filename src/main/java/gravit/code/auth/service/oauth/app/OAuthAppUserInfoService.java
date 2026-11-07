package gravit.code.auth.service.oauth.app;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.infrastructure.config.OAuthAndroidProps;
import gravit.code.auth.infrastructure.config.OAuthIdTokenProps;
import gravit.code.auth.infrastructure.config.OAuthIosProps;
import gravit.code.auth.strategy.app.AppUserInfoFactory;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthAppUserInfoService {

    private final Map<String, JwtDecoder> jwtDecoderMap;
    private final OAuthAndroidProps androidProps;
    private final OAuthIosProps iosProps;

    public OAuthUserInfo parseAndroidIdToken(
            String provider,
            String idToken
    ) {
        return parseIdToken(provider, idToken, androidProps);
    }

    private OAuthUserInfo parseIdToken(
            String provider,
            String idToken,
            OAuthIdTokenProps props
    ) {
        validateNullAndBlankIdToken(idToken);

        JwtDecoder decoder = selectJwtDecoder(provider);
        Jwt jwt = decodingIdTokenToJwt(idToken, decoder);

        validateIssuer(jwt, provider, props);
        validateAudience(jwt, provider, props);

        Map<String, Object> claims = jwt.getClaims();
        log.info("IdToken 파싱 성공 provider: {}, subject: {}", provider, jwt.getSubject());

        return AppUserInfoFactory.fromClaims(provider, claims);
    }

    private JwtDecoder selectJwtDecoder(String provider) {
        String normalizedProvider = provider.toLowerCase().strip();
        JwtDecoder decoder = jwtDecoderMap.get(normalizedProvider);

        if(decoder == null) {
            log.error("JwtDecoder 선택에 실패하였습니다 provider {}", normalizedProvider);
            throw new RestApiException(PROVIDER_INVALID);
        }

        return decoder;
    }

    private Jwt decodingIdTokenToJwt(
            String idToken,
            JwtDecoder decoder
    ) {
        try{
            return decoder.decode(idToken);
        }catch (Exception e) {
            throw new RestApiException(FAIL_DECODE_ID_TOKEN_TO_JWT);
        }
    }

    private void validateIssuer(
            Jwt jwt,
            String provider,
            OAuthIdTokenProps props
    ) {
        String expectedIssuer = props.getIssuer(provider);
        String targetIssuer = jwt.getIssuer().toString();

        if(!expectedIssuer.equals(targetIssuer)) {
            log.info("Issuer 가 매칭되지 않습니다 : expected : {}, target: {}", expectedIssuer, targetIssuer);
            throw new RestApiException(ISSUER_NOT_MATCHING);
        }
    }

    private void validateAudience(
            Jwt jwt,
            String provider,
            OAuthIdTokenProps props
    ) {
        String expectedClientId = props.getClientId(provider);
        List<String> audiences = jwt.getAudience();

        if(audiences.isEmpty()){
            log.error("IdToken 에 audience claim 이 존재하지 않습니다.");
            throw new RestApiException(AUDIENCE_IS_EMPTY);
        }

        if(!audiences.contains(expectedClientId)) {
            log.error("audiences 가 유효하지 않습니다 : expected : {} , target : {}", expectedClientId, audiences);
            throw new RestApiException(AUDIENCE_NOT_MATCHING);
        }
    }

    private static void validateNullAndBlankIdToken(String idToken) {
        if (idToken == null || idToken.isEmpty()) {
            throw new RestApiException(OAUTH_ID_TOKEN_INVALID);
        }
    }

    public OAuthUserInfo parseIosIdToken(
            String provider,
            String idToken
    ) {
        return parseIdToken(provider, idToken, iosProps);
    }
}
