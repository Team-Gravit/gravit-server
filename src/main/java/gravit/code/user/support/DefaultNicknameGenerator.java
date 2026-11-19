package gravit.code.user.support;

import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.util.Random;

@Component
public class DefaultNicknameGenerator {

    private static final String PREFIX = "유저";
    private static final int DIGIT_BOUND = 1_000_000;
    private static final String DIGIT_FORMAT = "%06d";
    private static final Random RANDOM = new SecureRandom();

    public String generate() {
        return PREFIX + String.format(DIGIT_FORMAT, RANDOM.nextInt(DIGIT_BOUND));
    }
}
