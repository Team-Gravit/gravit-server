package gravit.code.auth.oauth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "auth0")
public record Auth0Props(String issuer, String androidClientId) {}
