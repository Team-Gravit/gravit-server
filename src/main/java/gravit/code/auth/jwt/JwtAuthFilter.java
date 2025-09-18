package gravit.code.auth.jwt;

import gravit.code.auth.jwt.exception.CustomAuthenticationEntryPoint;
import gravit.code.auth.jwt.exception.CustomAuthenticationException;
import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final AuthTokenProvider authTokenProvider;
    private final CustomAuthenticationEntryPoint authenticationEntryPoint;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getServletPath();
        return request.getMethod().equalsIgnoreCase("OPTIONS")
                || path.startsWith("/swagger-ui")
                || path.startsWith("/v3/api-docs")
                || path.startsWith("/swagger-resources")
                || path.startsWith("/webjars")
                || path.startsWith("/api/v1/oauth")
                || path.startsWith("/api/v1/oauth/android")
                || path.startsWith("/api/v1/auth/refresh");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        try{
            String token = request.getHeader("Authorization");

            if (checkTokenNotNullAndBearer(token)) {
                String jwtToken = token.substring(7);

                authTokenProvider.validateToken(jwtToken);
                Authentication authentication = authTokenProvider.getAuthUser(jwtToken);
                SecurityContextHolder.getContext().setAuthentication(authentication);
                log.info("[doFilterInternal] 토큰 값 검증 완료");
            }

            filterChain.doFilter(request, response);
        } catch (RestApiException e) {
            ErrorCode errorCode = e.getErrorCode();
            authenticationEntryPoint.commence(request, response, new CustomAuthenticationException(errorCode));
        }
    }

    private boolean checkTokenNotNullAndBearer(String token) {
        return token != null && token.startsWith("Bearer ");
    }
}
