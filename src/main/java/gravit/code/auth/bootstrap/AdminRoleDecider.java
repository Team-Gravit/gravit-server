package gravit.code.auth.bootstrap;

import gravit.code.user.domain.Role;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;


@Component
@RequiredArgsConstructor
@Slf4j
public class AdminRoleDecider {
    private final AdminBootstrapProps props;

    public Role initRole(String email) {
        if (props.enabled() && props.emails().contains(email)) {
            return Role.ADMIN;
        }
        return Role.USER;
    }

    public boolean shouldPromoteToAdmin(String email) {
        log.info("props email : {}", props.emails().get(0));
        return props.enabled() && props.emails().contains(email);
    }
}
