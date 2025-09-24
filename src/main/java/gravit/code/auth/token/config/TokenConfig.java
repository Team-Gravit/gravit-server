package gravit.code.auth.token.config;

import java.time.Duration;

public record TokenConfig(
        String storageKeyPrefix,
        Duration expireTime
) {
}
