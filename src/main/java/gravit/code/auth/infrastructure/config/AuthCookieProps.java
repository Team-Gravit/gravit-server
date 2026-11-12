package gravit.code.auth.infrastructure.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "auth.cookie")
public record AuthCookieProps(
        String sameSite
) {
}
