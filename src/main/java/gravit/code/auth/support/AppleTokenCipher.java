package gravit.code.auth.support;

import gravit.code.auth.infrastructure.config.AppleOAuthProps;
import gravit.code.global.exception.domain.RestApiException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Base64;

import static gravit.code.global.exception.domain.CustomErrorCode.APPLE_CONFIG_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.APPLE_TOKEN_CRYPTO_FAILED;
import static java.nio.charset.StandardCharsets.UTF_8;

@Slf4j
@Component
public class AppleTokenCipher {

    private static final String KEY_ALGORITHM = "AES";
    private static final String CIPHER_TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int KEY_LENGTH_BYTES = 32;
    private static final int IV_LENGTH_BYTES = 12;
    private static final int TAG_LENGTH_BITS = 128;

    private final SecretKey secretKey;
    private final SecureRandom secureRandom = new SecureRandom();

    public AppleTokenCipher(AppleOAuthProps props) {
        this.secretKey = parseKey(props.tokenEncryptionKey());
    }

    private SecretKey parseKey(String encodedKey) {
        if (encodedKey == null || encodedKey.isBlank()) {
            log.error("Apple 토큰 암호화 키(oauth.apple.token-encryption-key)가 비어 있습니다.");
            throw new RestApiException(APPLE_CONFIG_INVALID);
        }

        byte[] decoded;
        try {
            decoded = Base64.getDecoder().decode(encodedKey);
        } catch (IllegalArgumentException e) {
            log.error("Apple 토큰 암호화 키(oauth.apple.token-encryption-key)가 Base64 형식이 아닙니다.", e);
            throw new RestApiException(APPLE_CONFIG_INVALID);
        }

        if (decoded.length != KEY_LENGTH_BYTES) {
            log.error("Apple 토큰 암호화 키는 {}바이트여야 합니다. 현재 {}바이트", KEY_LENGTH_BYTES, decoded.length);
            throw new RestApiException(APPLE_CONFIG_INVALID);
        }

        return new SecretKeySpec(decoded, KEY_ALGORITHM);
    }

    public String encrypt(String plainText) {
        try {
            byte[] iv = new byte[IV_LENGTH_BYTES];
            secureRandom.nextBytes(iv);

            Cipher cipher = Cipher.getInstance(CIPHER_TRANSFORMATION);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, new GCMParameterSpec(TAG_LENGTH_BITS, iv));
            byte[] encrypted = cipher.doFinal(plainText.getBytes(UTF_8));

            byte[] ivAndEncrypted = ByteBuffer.allocate(iv.length + encrypted.length)
                    .put(iv)
                    .put(encrypted)
                    .array();

            return Base64.getEncoder().encodeToString(ivAndEncrypted);
        } catch (GeneralSecurityException e) {
            log.error("Apple 토큰 암호화에 실패했습니다.", e);
            throw new RestApiException(APPLE_TOKEN_CRYPTO_FAILED);
        }
    }

    public String decrypt(String cipherText) {
        try {
            byte[] ivAndEncrypted = Base64.getDecoder().decode(cipherText);
            if (ivAndEncrypted.length <= IV_LENGTH_BYTES) {
                throw new RestApiException(APPLE_TOKEN_CRYPTO_FAILED);
            }

            Cipher cipher = Cipher.getInstance(CIPHER_TRANSFORMATION);
            cipher.init(Cipher.DECRYPT_MODE, secretKey, new GCMParameterSpec(TAG_LENGTH_BITS, ivAndEncrypted, 0, IV_LENGTH_BYTES));
            byte[] decrypted = cipher.doFinal(ivAndEncrypted, IV_LENGTH_BYTES, ivAndEncrypted.length - IV_LENGTH_BYTES);

            return new String(decrypted, UTF_8);
        } catch (IllegalArgumentException | GeneralSecurityException e) {
            log.error("Apple 토큰 복호화에 실패했습니다.", e);
            throw new RestApiException(APPLE_TOKEN_CRYPTO_FAILED);
        }
    }
}
