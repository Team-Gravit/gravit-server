package gravit.code.security.filter;

import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.security.exception.CustomAuthenticationEntryPoint;
import gravit.code.security.exception.CustomAuthenticationException;
import io.netty.handler.codec.http.HttpMethod;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private static final List<HttpEndpoint> EXCLUDE_ENDPOINTS = List.of(
            /* swagger */
            HttpEndpoint.prefix("/swagger-ui", HttpMethod.GET),
            HttpEndpoint.prefix("/v3/api-docs", HttpMethod.GET),

            /* oauth signup & reissue */
            HttpEndpoint.prefix("/api/v1/oauth", HttpMethod.GET, HttpMethod.POST),
            HttpEndpoint.exact("/api/v1/auth/reissue", HttpMethod.POST),

            /* test */
            HttpEndpoint.prefix("/api/v1/test", HttpMethod.POST),

            /* delete account */
            HttpEndpoint.exact("/api/v1/users/deletion/confirm", HttpMethod.DELETE)

    );

    private final AuthTokenProvider authTokenProvider;
    private final CustomAuthenticationEntryPoint authenticationEntryPoint;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
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

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        String method = request.getMethod();
        return EXCLUDE_ENDPOINTS.stream()
                .anyMatch(endpoint -> endpoint.isMatchedWith(requestURI, method));
    }

    private enum MatchType {
        EXACT,
        PREFIX
    }

    private record HttpEndpoint(
            String pattern,
            List<HttpMethod> methods,
            MatchType type
    ){
        static HttpEndpoint exact(String path, HttpMethod... methods){
            return new HttpEndpoint(path, List.of(methods), MatchType.EXACT);
        }

        static HttpEndpoint prefix(String prefix, HttpMethod... methods){
            return new HttpEndpoint(prefix, List.of(methods), MatchType.PREFIX);
        }

        boolean isMatchedWith(String uri, String method){
            if(methods.stream().noneMatch(m -> m.name().equalsIgnoreCase(method))){
                return false;
            }
            return switch(type){
                case EXACT -> uri.equals(pattern);
                case PREFIX -> uri.startsWith(pattern);
            };
        }
    }
}
