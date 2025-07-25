package gravit.code.common.auth;

import gravit.code.auth.oauth.LoginUser;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.test.context.support.WithSecurityContextFactory;

public class WithMockLoginUserSecurityContextFactory implements WithSecurityContextFactory<WithMockLoginUser> {

    @Override
    public SecurityContext createSecurityContext(WithMockLoginUser user) {
        LoginUser loginUser = new LoginUser(
                user.userId(),
                user.provider(),
                null
        );

        Authentication authentication = new UsernamePasswordAuthenticationToken(
                loginUser,
                null,
                loginUser.getAuthorities()
        );

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(authentication);
        return context;
    }
}
