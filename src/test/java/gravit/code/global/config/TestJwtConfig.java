package gravit.code.global.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;

@Configuration
@Profile("test")
public class TestJwtConfig {
    @Bean @Primary
    JwtDecoder idTokenDecoder() {
        return token -> Jwt.withTokenValue(token)
                .header("alg","none")
                .claim("iss","https://test-issuer/")
                .claim("aud", java.util.List.of("TEST_ANDROID_CLIENT_ID"))
                .claim("sub","oauth2|Naver|naver|test-user")
                .issuedAt(java.time.Instant.now())
                .expiresAt(java.time.Instant.now().plusSeconds(3600))
                .build();
    }
}
