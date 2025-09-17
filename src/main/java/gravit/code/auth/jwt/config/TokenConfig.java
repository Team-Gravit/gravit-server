package gravit.code.auth.jwt.config;

import java.time.Duration;

public record TokenConfig(
        String storageKeyPrefix,
        Duration expireTime
) {
}
