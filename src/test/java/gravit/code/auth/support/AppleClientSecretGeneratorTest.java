package gravit.code.auth.support;

import gravit.code.auth.infrastructure.config.AppleOAuthProps;
import gravit.code.global.exception.domain.RestApiException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.spec.ECGenParameterSpec;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.util.Base64;
import java.util.Date;

import static gravit.code.global.exception.domain.CustomErrorCode.APPLE_CONFIG_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

class AppleClientSecretGeneratorTest {

    private static final Instant NOW = Instant.parse("2025-08-05T03:00:00Z");
    private static final Clock FIXED_CLOCK = Clock.fixed(NOW, ZoneId.of("Asia/Seoul"));
    private static final String ISSUER = "https://appleid.apple.com";
    private static final String TEAM_ID = "TESTTEAMID";
    private static final String CLIENT_ID = "test.apple.client.id";
    private static final String KEY_ID = "TESTKEYID0";
    private static final Duration CLIENT_SECRET_TTL = Duration.ofMinutes(5);

    private KeyPair keyPair;

    @BeforeEach
    void setUp() throws Exception {
        KeyPairGenerator generator = KeyPairGenerator.getInstance("EC");
        generator.initialize(new ECGenParameterSpec("secp256r1"));
        keyPair = generator.generateKeyPair();
    }

    private AppleOAuthProps 개인키_설정(String privateKey) {
        return new AppleOAuthProps(ISSUER, null, null, null, TEAM_ID, CLIENT_ID, KEY_ID, privateKey, null);
    }

    private String 인코딩된_개인키() {
        return Base64.getEncoder().encodeToString(keyPair.getPrivate().getEncoded());
    }

    @Nested
    @DisplayName("client_secret을 만들 때")
    class Generate {

        @Test
        void 개인키로_서명하고_Apple이_요구하는_헤더와_클레임을_담는다() {
            // given
            AppleClientSecretGenerator generator = new AppleClientSecretGenerator(FIXED_CLOCK, 개인키_설정(인코딩된_개인키()));

            // when
            String clientSecret = generator.generate();

            // then
            Jws<Claims> jws = Jwts.parser()
                    .verifyWith(keyPair.getPublic())
                    .clock(() -> Date.from(NOW))
                    .build()
                    .parseSignedClaims(clientSecret);
            Claims claims = jws.getPayload();

            assertSoftly(softly -> {
                softly.assertThat(jws.getHeader().getKeyId()).isEqualTo(KEY_ID);
                softly.assertThat(jws.getHeader().getAlgorithm()).isEqualTo("ES256");
                softly.assertThat(claims.getIssuer()).isEqualTo(TEAM_ID);
                softly.assertThat(claims.getSubject()).isEqualTo(CLIENT_ID);
                softly.assertThat(claims.getAudience()).containsExactly(ISSUER);
                softly.assertThat(claims.getIssuedAt().toInstant()).isEqualTo(NOW);
                softly.assertThat(claims.getExpiration().toInstant()).isEqualTo(NOW.plus(CLIENT_SECRET_TTL));
            });
        }

        @Test
        void aud는_배열이_아닌_문자열로_담는다() {
            // given
            AppleClientSecretGenerator generator = new AppleClientSecretGenerator(FIXED_CLOCK, 개인키_설정(인코딩된_개인키()));

            // when
            String clientSecret = generator.generate();

            // then
            String payload = new String(Base64.getUrlDecoder().decode(clientSecret.split("\\.")[1]));
            assertThat(payload).contains("\"aud\":\"" + ISSUER + "\"");
        }
    }

    @Nested
    @DisplayName("개인키 설정을 읽을 때")
    class ParsePrivateKey {

        @Test
        void 개인키가_비어_있으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> new AppleClientSecretGenerator(FIXED_CLOCK, 개인키_설정(" ")))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_CONFIG_INVALID);
        }

        @Test
        void 개인키가_없으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> new AppleClientSecretGenerator(FIXED_CLOCK, 개인키_설정(null)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_CONFIG_INVALID);
        }

        @Test
        void PKCS8_EC_키가_아니면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> new AppleClientSecretGenerator(FIXED_CLOCK, 개인키_설정("CHANGE_ME")))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_CONFIG_INVALID);
        }
    }
}
