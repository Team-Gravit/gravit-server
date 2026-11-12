package gravit.code.notification.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.service.NotificationService;
import gravit.code.notification.support.NotificationPushSender;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class NotificationFacade {

    private final NotificationService notificationService;

    private final NotificationPushSender notificationPushSender;

    public void notifyUserInApp(
            long userId,
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationService.notify(userId, type, message, targetId);
    }

    public void notifyUsersInApp(
            List<Long> userIds,
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationService.notifyUsers(userIds, type, message, targetId);
    }

    public void notifyUser(
            long userId,
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationService.notify(userId, type, message, targetId);
        notificationPushSender.pushToUser(userId, type.toPushData(targetId), message);
    }
}
