package gravit.code.notification.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class FollowedRetryTarget implements RetrySweepTarget {

    private static final int MAX_ATTEMPTS = 10;

    private final UserService userService;
    private final NotificationMessageProvider messageProvider;
    private final NotificationFacade notificationFacade;

    @Override
    public String queueKey() {
        return "followed-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        long followerId = Long.parseLong(fields.get("followerId"));
        long followeeId = Long.parseLong(fields.get("followeeId"));

        String nickname = userService.getUser(followerId).getNickname();
        String message = messageProvider.followReceived(nickname);
        notificationFacade.notifyUserInApp(followeeId, NotificationType.FOLLOW, message, followerId);
    }
}
