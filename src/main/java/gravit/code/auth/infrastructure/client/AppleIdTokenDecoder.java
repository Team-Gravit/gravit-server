package gravit.code.auth.infrastructure.client;

import gravit.code.auth.infrastructure.config.AppleOAuthProps;
import gravit.code.global.exception.domain.RestApiException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Component;

import static gravit.code.global.exception.domain.CustomErrorCode.APPLE_CONFIG_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.FAIL_DECODE_ID_TOKEN_TO_JWT;

@Slf4j
@Component
public class AppleIdTokenDecoder {

    private final JwtDecoder jwtDecoder;

    public AppleIdTokenDecoder(AppleOAuthProps props) {
        String jwkSetUri = props.jwkSetUri();
        if (jwkSetUri == null || jwkSetUri.isBlank()) {
            log.error("Apple 공개키 주소(oauth.apple.jwk-set-uri)가 비어 있습니다.");
            throw new RestApiException(APPLE_CONFIG_INVALID);
        }

        this.jwtDecoder = NimbusJwtDecoder.withJwkSetUri(jwkSetUri).build();
    }

    public Jwt decode(String idToken) {
        try {
            return jwtDecoder.decode(idToken);
        } catch (JwtException e) {
            log.warn("Apple IdToken 디코딩 실패 : {}", e.getMessage());
            throw new RestApiException(FAIL_DECODE_ID_TOKEN_TO_JWT);
        }
    }
}
