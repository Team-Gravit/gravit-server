package gravit.code.auth.policy;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

@ConfigurationProperties(prefix = "admin.bootstrap")
public record AdminWhitelistProps(
        boolean enabled,
        List<String> emails
) {}
