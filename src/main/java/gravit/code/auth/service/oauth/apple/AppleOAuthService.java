package gravit.code.auth.service.oauth.apple;

import gravit.code.auth.dto.internal.AppleLoginDto;
import gravit.code.auth.dto.oauth.AppleUserInfo;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.infrastructure.client.AppleIdTokenDecoder;
import gravit.code.auth.infrastructure.config.AppleOAuthProps;
import gravit.code.auth.service.oauth.OAuthClient;
import gravit.code.auth.service.oauth.OAuthLoginUrlService;
import gravit.code.auth.strategy.support.OAuthUserInfoValidator;
import gravit.code.auth.support.AppleClientSecretGenerator;
import gravit.code.global.consts.RedirectHostConst;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.AUDIENCE_IS_EMPTY;
import static gravit.code.global.exception.domain.CustomErrorCode.AUDIENCE_NOT_MATCHING;
import static gravit.code.global.exception.domain.CustomErrorCode.AUTH_CODE_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;
import static gravit.code.global.exception.domain.CustomErrorCode.ISSUER_NOT_MATCHING;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_ID_TOKEN_INVALID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AppleOAuthService {

    private static final String GRANT_TYPE = "authorization_code";
    private static final String TOKEN_TYPE_HINT = "refresh_token";
    private static final String RESPONSE_ID_TOKEN = "id_token";
    private static final String RESPONSE_REFRESH_TOKEN = "refresh_token";

    private final OAuthClient oAuthClient;
    private final AppleIdTokenDecoder appleIdTokenDecoder;
    private final AppleClientSecretGenerator appleClientSecretGenerator;

    private final AppleOAuthProps props;

    public AppleLoginDto getUserInfo(
            String authCode,
            String dest
    ) {
        validateAuthCode(authCode);
        String baseHost = validateDest(dest);

        String decodedCode = URLDecoder.decode(authCode, StandardCharsets.UTF_8);
        String redirectUri = baseHost + OAuthLoginUrlService.REDIRECT_PATH_PREFIX + AppleUserInfo.PROVIDER;

        Map<String, Object> tokenResponse = requestToken(decodedCode, redirectUri);

        Jwt idToken = decodeIdToken(tokenResponse);
        validateIssuer(idToken);
        validateAudience(idToken);

        OAuthUserInfo userInfo = new AppleUserInfo(idToken.getClaims());
        OAuthUserInfoValidator.validate(userInfo);

        String refreshToken = (String) tokenResponse.get(RESPONSE_REFRESH_TOKEN);
        return AppleLoginDto.of(userInfo, refreshToken);
    }

    private void validateAuthCode(String authCode) {
        if (authCode == null || authCode.isBlank()) {
            throw new RestApiException(AUTH_CODE_INVALID);
        }
    }

    private String validateDest(String dest) {
        String base = RedirectHostConst.DEST_BASE.get(dest);

        if (base == null || base.isBlank()) {
            throw new RestApiException(DEST_NOT_VALID);
        }

        return base;
    }

    private Map<String, Object> requestToken(
            String decodedCode,
            String redirectUri
    ) {
        MultiValueMap<String, String> tokenRequest = new LinkedMultiValueMap<>();
        tokenRequest.add("grant_type", GRANT_TYPE);
        tokenRequest.add("client_id", props.clientId());
        tokenRequest.add("client_secret", appleClientSecretGenerator.generate());
        tokenRequest.add("redirect_uri", redirectUri);
        tokenRequest.add("code", decodedCode);

        return oAuthClient.getAccessTokenResponse(props.tokenUri(), tokenRequest);
    }

    private Jwt decodeIdToken(Map<String, Object> tokenResponse) {
        Object idToken = tokenResponse.get(RESPONSE_ID_TOKEN);

        if (!(idToken instanceof String idTokenValue) || idTokenValue.isBlank()) {
            log.warn("Apple 토큰 응답에 id_token 이 없습니다.");
            throw new RestApiException(OAUTH_ID_TOKEN_INVALID);
        }

        return appleIdTokenDecoder.decode(idTokenValue);
    }

    private void validateIssuer(Jwt idToken) {
        String expectedIssuer = props.issuer();
        String targetIssuer = idToken.getIssuer() == null ? null : idToken.getIssuer().toString();

        if (!expectedIssuer.equals(targetIssuer)) {
            log.info("Apple Issuer 가 매칭되지 않습니다 : expected : {}, target: {}", expectedIssuer, targetIssuer);
            throw new RestApiException(ISSUER_NOT_MATCHING);
        }
    }

    private void validateAudience(Jwt idToken) {
        String expectedClientId = props.clientId();
        List<String> audiences = idToken.getAudience();

        if (audiences == null || audiences.isEmpty()) {
            log.error("Apple IdToken 에 audience claim 이 존재하지 않습니다.");
            throw new RestApiException(AUDIENCE_IS_EMPTY);
        }

        if (!audiences.contains(expectedClientId)) {
            log.error("Apple audiences 가 유효하지 않습니다 : expected : {} , target : {}", expectedClientId, audiences);
            throw new RestApiException(AUDIENCE_NOT_MATCHING);
        }
    }

    public void revokeRefreshToken(String refreshToken) {
        MultiValueMap<String, String> revokeRequest = new LinkedMultiValueMap<>();
        revokeRequest.add("client_id", props.clientId());
        revokeRequest.add("client_secret", appleClientSecretGenerator.generate());
        revokeRequest.add("token", refreshToken);
        revokeRequest.add("token_type_hint", TOKEN_TYPE_HINT);

        oAuthClient.revokeToken(props.revokeUri(), revokeRequest);
    }
}
