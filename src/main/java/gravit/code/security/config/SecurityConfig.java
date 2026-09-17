package gravit.code.security.config;


import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.security.exception.CustomAccessDeniedHandler;
import gravit.code.security.exception.CustomAuthenticationEntryPoint;
import gravit.code.security.filter.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private static final List<String> ALLOWED_ORIGINS = List.of(
            "https://grav-it.inuappcenter.kr",
            "https://grav-it-dev.inuappcenter.kr",
            "http://localhost:5173",
            "https://gravit.inuappcenter.kr",
            "https://gravit-cs.vercel.app",
            "https://dev.gravit.inuappcenter.kr",
            "https://gravit-admin.inuappcenter.kr"
    );

    private final AuthTokenProvider authTokenProvider;
    private final CustomAuthenticationEntryPoint authenticationEntryPoint;
    private final CustomAccessDeniedHandler accessDeniedHandler;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception{
        http.cors((cors -> cors.configurationSource(configurationSource())));

        http.csrf(AbstractHttpConfigurer::disable);

        http.httpBasic(AbstractHttpConfigurer::disable);

        http.sessionManagement((session) -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        http.authorizeHttpRequests((auth) -> auth
                .requestMatchers("/actuator/**").permitAll() // 모니터링 경로
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll() // Swagger 관련 경로 허용
                .requestMatchers("/api/v1/oauth/**").permitAll()
                .requestMatchers("/api/v1/users/deletion/confirm").permitAll()
                .requestMatchers("/api/v1/auth/reissue").permitAll()
                .requestMatchers("/api/v1/users/restore").permitAll()
                .requestMatchers("/api/v1/test/notifications/**").authenticated()
                .requestMatchers("/api/v1/test/**").permitAll()
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/v1/cs-notes/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/version").permitAll()
                .anyRequest().authenticated());

        http.addFilterBefore(new JwtAuthFilter(authTokenProvider, authenticationEntryPoint), UsernamePasswordAuthenticationFilter.class);

        http.exceptionHandling(exception -> exception.accessDeniedHandler(accessDeniedHandler));

        return http.build();
    }

    public CorsConfigurationSource configurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.addAllowedHeader("*");
        configuration.addAllowedMethod("*");
        configuration.setAllowedOrigins(ALLOWED_ORIGINS);
        configuration.setAllowCredentials(true);
        configuration.addExposedHeader("ACCESS_TOKEN");
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
