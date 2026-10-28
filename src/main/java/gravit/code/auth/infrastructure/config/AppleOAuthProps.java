package gravit.code.auth.infrastructure.config;

import gravit.code.auth.domain.AppleClient;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "oauth.apple")
public record AppleOAuthProps(
        String issuer,
        String tokenUri,
        String revokeUri,
        String jwkSetUri,
        String teamId,
        String clientId,
        String iosBundleId,
        String keyId,
        String privateKey,
        String tokenEncryptionKey
) {
    public String clientId(AppleClient client) {
        return switch (client) {
            case WEB -> clientId;
            case IOS -> iosBundleId;
        };
    }
}
