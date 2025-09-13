package gravit.code.user.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "user-delete-mail")
public record UserDeleteMailProps(
        int codeLength,
        int expireTime,
        String serviceEmail
) {
}
