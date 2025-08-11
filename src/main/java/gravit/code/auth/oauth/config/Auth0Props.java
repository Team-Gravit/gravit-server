package gravit.code.auth.oauth.config;

import lombok.Getter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@ConfigurationProperties(prefix = "auth0")
public class Auth0Props {
    private final String issuer;
    private final String androidClientId;

    public Auth0Props(String issuer, String androidClientId) {
        this.issuer = issuer;
        this.androidClientId = androidClientId;
    }
}
