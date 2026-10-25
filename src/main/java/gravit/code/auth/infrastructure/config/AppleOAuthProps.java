package gravit.code.auth.infrastructure.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "oauth.apple")
public record AppleOAuthProps(
        String issuer,
        String tokenUri,
        String revokeUri,
        String jwkSetUri,
        String teamId,
        String clientId,
        String keyId,
        String privateKey,
        String tokenEncryptionKey
) {
}
