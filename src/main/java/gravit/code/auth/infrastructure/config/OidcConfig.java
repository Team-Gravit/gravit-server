package gravit.code.auth.infrastructure.config;

import java.util.Map;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtDecoders;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;

@Configuration
@Profile("!test")
public class OidcConfig {

    @Bean
    public JwtDecoder googleJwtDecoder() {
        return NimbusJwtDecoder
                .withJwkSetUri("https://www.googleapis.com/oauth2/v3/certs")
                .build();
    }

    @Bean
    public JwtDecoder kakaoJwtDecoder() {
        return NimbusJwtDecoder
                .withJwkSetUri("https://kauth.kakao.com/.well-known/jwks.json")
                .build();
    }


    @Bean
    public Map<String, JwtDecoder> jwtDecoderMap(
            JwtDecoder googleJwtDecoder,
            JwtDecoder kakaoJwtDecoder) {
        return Map.of(
                "google", googleJwtDecoder,
                "kakao", kakaoJwtDecoder
        );
    }
}
