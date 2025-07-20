package gravit.code.auth.jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.auth.oauth.LoginUser;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Log4j2
@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        try{
            String token = findToken(request);
            if (!verifyToken(request, token)) {
                filterChain.doFilter(request, response);
                return;
            }

            User user = getUser(token);
            setSecuritySession(user);
            filterChain.doFilter(request, response);

        }catch (Exception e){
            e.printStackTrace();
        }
    }

    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getRequestURI();
        return path.startsWith("/swagger-ui/") || path.startsWith("/v3/api-docs") || path.startsWith("/swagger-resources/");
    }

    private static void setSecuritySession(User user){
        LoginUser loginUser = new LoginUser(user.getId(), user.getProviderId(),null);
        log.info("LoginUserId: {}", loginUser.getId());
        Authentication authToken = new UsernamePasswordAuthenticationToken(loginUser,null, null);
        SecurityContextHolder.getContext().setAuthentication(authToken);
    }

    private User getUser(String token){
        Long userId = jwtProvider.getUserId(token);
        User user = userRepository.findById(userId).orElseThrow(()-> new RuntimeException());

        log.info("getUser nickname = {} ", user.getNickname());
        return user;
    }

    private boolean verifyToken(HttpServletRequest request,String token) {
        Boolean isValid = (Boolean) request.getAttribute("isTokenValid");
        if(isValid != null) return isValid;

        if (token == null || jwtProvider.validateToken(token)) {
            log.debug("token null");
            request.setAttribute("isTokenValid",false);
            return false;
        }

        request.setAttribute("isTokenValid", true);
        return true;
    }

    private static String findToken(HttpServletRequest request){
        String token = null;
        Cookie[] cookies = request.getCookies();
        for(Cookie cookie : cookies){
            if(cookie.getName().equals("Authorization")){
                token = cookie.getValue();
            }
        }
        return token;
    }
}
