package gravit.code.auth.support;

import gravit.code.auth.infrastructure.config.AppleOAuthProps;
import gravit.code.global.exception.domain.RestApiException;
import io.jsonwebtoken.Jwts;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.Date;

import static gravit.code.global.exception.domain.CustomErrorCode.APPLE_CONFIG_INVALID;

@Slf4j
@Component
public class AppleClientSecretGenerator {

    private static final String KEY_ALGORITHM = "EC";
    private static final Duration CLIENT_SECRET_TTL = Duration.ofMinutes(5);

    private final PrivateKey privateKey;

    private final Clock clock;
    private final AppleOAuthProps props;

    public AppleClientSecretGenerator(
            Clock clock,
            AppleOAuthProps props
    ) {
        this.clock = clock;
        this.props = props;
        this.privateKey = parsePrivateKey(props.privateKey());
    }

    private PrivateKey parsePrivateKey(String encodedPrivateKey) {
        if (encodedPrivateKey == null || encodedPrivateKey.isBlank()) {
            log.error("Apple 개인키(oauth.apple.private-key)가 비어 있습니다.");
            throw new RestApiException(APPLE_CONFIG_INVALID);
        }

        try {
            byte[] decoded = Base64.getMimeDecoder().decode(encodedPrivateKey);
            return KeyFactory.getInstance(KEY_ALGORITHM).generatePrivate(new PKCS8EncodedKeySpec(decoded));
        } catch (IllegalArgumentException | GeneralSecurityException e) {
            log.error("Apple 개인키(oauth.apple.private-key)를 읽지 못했습니다.", e);
            throw new RestApiException(APPLE_CONFIG_INVALID);
        }
    }

    public String generate() {
        Instant now = clock.instant();

        return Jwts.builder()
                .header().keyId(props.keyId()).and()
                .issuer(props.teamId())
                .subject(props.clientId())
                .audience().single(props.issuer())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plus(CLIENT_SECRET_TTL)))
                .signWith(privateKey, Jwts.SIG.ES256)
                .compact();
    }
}
