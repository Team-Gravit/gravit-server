package gravit.code.auth.client.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtDecoders;

@Configuration
@Profile("!test")
public class OidcConfig {

    // Auth0 JWK 로 서명/iss 자동 검증
    @Bean
    public JwtDecoder idTokenDecoder(Auth0Props props) {
        return JwtDecoders.fromIssuerLocation(props.issuer());
    }
}
