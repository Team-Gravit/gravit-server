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

    // 인앱 알림함에만 적재 (푸시 미발송) — 3.9 팔로우 / 3.10 축하하기 / 3.11 친구 활동
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

    // 특정 유저에게 인앱 알림 저장 + FCM 푸시 발송 (인앱 + 푸시 모두 쓰는 알림용)
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
