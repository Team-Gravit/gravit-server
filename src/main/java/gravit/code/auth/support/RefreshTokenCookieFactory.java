package gravit.code.auth.support;

import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.infrastructure.config.AuthCookieProps;
import gravit.code.auth.token.config.TokenProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
@RequiredArgsConstructor
public class RefreshTokenCookieFactory {

    public static final String COOKIE_NAME = "refreshToken";
    private static final String COOKIE_PATH = "/api/v1/auth";

    private final AuthCookieProps props;

    public ResponseCookie create(String refreshToken) {
        return baseCookie(refreshToken)
                .maxAge(TokenProperties.getExpireTime(RefreshToken.class))
                .build();
    }

    private ResponseCookie.ResponseCookieBuilder baseCookie(String value) {
        return ResponseCookie.from(COOKIE_NAME, value)
                .httpOnly(true)
                .secure(true)
                .path(COOKIE_PATH)
                .sameSite(props.sameSite());
    }

    public ResponseCookie expire() {
        return baseCookie("")
                .maxAge(Duration.ZERO)
                .build();
    }
}
