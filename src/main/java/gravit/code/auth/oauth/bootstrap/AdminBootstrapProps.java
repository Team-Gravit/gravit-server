package gravit.code.auth.oauth.bootstrap;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

@ConfigurationProperties(prefix = "admin.bootstrap")
public record AdminBootstrapProps(
        boolean enabled,
        List<String> emails
) {}
