package gravit.code.global.interceptor;

import gravit.code.auth.domain.LoginUser;
import gravit.code.user.service.UserAccessService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Log4j2
@Component
@RequiredArgsConstructor
public class LastAccessInterceptor implements HandlerInterceptor {

    private final UserAccessService userAccessService;

    @Override
    public boolean preHandle(
            HttpServletRequest request,
            HttpServletResponse response,
            Object handler
    ) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof LoginUser loginUser) {
            try {
                userAccessService.updateLastAccessed(loginUser.getId());
            } catch (Exception e) {
                log.warn("lastAccessedAt 갱신 실패 - userId: {}", loginUser.getId(), e);
            }
        }

        return true;
    }
}
