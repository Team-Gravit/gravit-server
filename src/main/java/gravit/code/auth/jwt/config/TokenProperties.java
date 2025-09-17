package gravit.code.auth.jwt.config;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.domain.Token;
import jakarta.annotation.PostConstruct;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;
import java.util.Map;

@ConfigurationProperties(prefix = "token")
public record TokenProperties(
        TokenConfig access,
        TokenConfig refresh
) {

    private static Map<Class<? extends Token>, TokenConfig> tokenConfigs;

    @PostConstruct
    public void init() {
        tokenConfigs = Map.of(
                AccessToken.class, access,
                RefreshToken.class, refresh
        );
    }

    public static Duration getExpireTime(Class<? extends Token> tokenClass) {
        return tokenConfigs.get(tokenClass).expireTime();
    }

    public static String getStorageKeyPrefix(Class<? extends Token> tokenClass) {
        return tokenConfigs.get(tokenClass).storageKeyPrefix();
    }

}
