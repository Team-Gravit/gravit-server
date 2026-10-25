package gravit.code.auth.support;

import gravit.code.auth.infrastructure.config.AppleOAuthProps;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.util.Base64;

import static gravit.code.global.exception.domain.CustomErrorCode.APPLE_CONFIG_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.APPLE_TOKEN_CRYPTO_FAILED;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

class AppleTokenCipherTest {

    private static final String ENCRYPTION_KEY = "zaK9adGxW9qk5Pii8kOIUaM3oWTwChIwOXmbhiS2PsI=";
    private static final String OTHER_ENCRYPTION_KEY = "4kZSeJm9ml6FidIZXDNtsKqpfMUlXzTK+3Ge+6s59cg=";
    private static final String SHORT_KEY = "c2hvcnQta2V5";
    private static final String REFRESH_TOKEN = "r.apple-refresh-token.123";

    private AppleTokenCipher 암호기(String encryptionKey) {
        return new AppleTokenCipher(new AppleOAuthProps(null, null, null, null, null, null, null, null, encryptionKey));
    }

    @Nested
    @DisplayName("토큰을 암복호화할 때")
    class EncryptAndDecrypt {

        @Test
        void 암호화한_값을_복호화하면_원문이_나온다() {
            // given
            AppleTokenCipher cipher = 암호기(ENCRYPTION_KEY);

            // when
            String encrypted = cipher.encrypt(REFRESH_TOKEN);

            // then
            assertSoftly(softly -> {
                softly.assertThat(encrypted).isNotEqualTo(REFRESH_TOKEN);
                softly.assertThat(cipher.decrypt(encrypted)).isEqualTo(REFRESH_TOKEN);
            });
        }

        @Test
        void 같은_원문도_암호화할_때마다_다른_값이_된다() {
            // given
            AppleTokenCipher cipher = 암호기(ENCRYPTION_KEY);

            // when
            String first = cipher.encrypt(REFRESH_TOKEN);
            String second = cipher.encrypt(REFRESH_TOKEN);

            // then
            assertThat(first).isNotEqualTo(second);
        }

        @Test
        void 다른_키로_복호화하면_예외를_던진다() {
            // given
            String encrypted = 암호기(ENCRYPTION_KEY).encrypt(REFRESH_TOKEN);

            // when & then
            assertThatThrownBy(() -> 암호기(OTHER_ENCRYPTION_KEY).decrypt(encrypted))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_TOKEN_CRYPTO_FAILED);
        }

        @Test
        void 변조된_암호문을_복호화하면_예외를_던진다() {
            // given
            AppleTokenCipher cipher = 암호기(ENCRYPTION_KEY);
            byte[] encrypted = Base64.getDecoder().decode(cipher.encrypt(REFRESH_TOKEN));
            encrypted[encrypted.length - 1] ^= 1;
            String tampered = Base64.getEncoder().encodeToString(encrypted);

            // when & then
            assertThatThrownBy(() -> cipher.decrypt(tampered))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_TOKEN_CRYPTO_FAILED);
        }

        @Test
        void IV보다_짧은_암호문을_복호화하면_예외를_던진다() {
            // given
            AppleTokenCipher cipher = 암호기(ENCRYPTION_KEY);
            String tooShort = Base64.getEncoder().encodeToString(new byte[12]);

            // when & then
            assertThatThrownBy(() -> cipher.decrypt(tooShort))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_TOKEN_CRYPTO_FAILED);
        }

        @Test
        void Base64가_아닌_암호문을_복호화하면_예외를_던진다() {
            // given
            AppleTokenCipher cipher = 암호기(ENCRYPTION_KEY);

            // when & then
            assertThatThrownBy(() -> cipher.decrypt("not-base64!!"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_TOKEN_CRYPTO_FAILED);
        }
    }

    @Nested
    @DisplayName("암호화 키 설정을 읽을 때")
    class ParseKey {

        @Test
        void 키가_비어_있으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> 암호기(""))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_CONFIG_INVALID);
        }

        @Test
        void 키가_Base64가_아니면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> 암호기("not-base64!!"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_CONFIG_INVALID);
        }

        @Test
        void 키가_32바이트가_아니면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> 암호기(SHORT_KEY))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(APPLE_CONFIG_INVALID);
        }
    }
}
