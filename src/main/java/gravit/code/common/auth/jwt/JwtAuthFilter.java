package gravit.code.common.auth.jwt;

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

    private final JwtProvider jwtProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String token = request.getHeader("Authorization");

        if (token != null) {
            String jwtToken = token.substring(7);

            if(!jwtProvider.isValidToken(jwtToken)){
                throw new RuntimeException();
            }

            Authentication authentication = jwtProvider.getAuthUser(jwtToken);
            SecurityContextHolder.getContext().setAuthentication(authentication);
            log.info("[doFilterInternal] 토큰 값 검증 완료");
        }

        filterChain.doFilter(request, response);
    }
}
