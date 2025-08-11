package gravit.code.auth.oauth.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtDecoders;

@Configuration
@EnableConfigurationProperties(Auth0Props.class)
public class OidcConfig {

    // Auth0 JWK 로 서명/iss 자동 검증
    @Bean
    public JwtDecoder idTokenDecoder(Auth0Props props) {
        return JwtDecoders.fromIssuerLocation(props.getIssuer());
    }
}
