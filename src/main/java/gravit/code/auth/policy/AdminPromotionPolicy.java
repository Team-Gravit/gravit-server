package gravit.code.auth.policy;

import gravit.code.user.domain.Role;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;


@Component
@RequiredArgsConstructor
@Slf4j
public class AdminPromotionPolicy {
    private final AdminWhitelistProps props;

    public Role initRole(String email) {
        if (props.enabled() && props.emails().contains(email)) {
            return Role.ADMIN;
        }
        return Role.USER;
    }

    public boolean shouldPromoteToAdmin(String email) {
        return props.enabled() && props.emails().contains(email);
    }
}
