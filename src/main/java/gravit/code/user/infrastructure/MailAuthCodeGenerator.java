package gravit.code.user.infrastructure;

import lombok.experimental.UtilityClass;

import java.security.SecureRandom;
import java.util.Base64;

@UtilityClass
public class MailAuthCodeGenerator {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    public static String createMailAuthCode(int codeLength) {
        byte[] bytes = new byte[codeLength];
        SECURE_RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
