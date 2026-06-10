package gravit.code.notification.service;

import gravit.code.notification.domain.Notification;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final Clock clock;

    @Transactional
    public void notify(
            long userId,
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationRepository.save(Notification.create(userId, type, message, targetId));
    }

    @Transactional
    public void notify(
            long userId,
            NotificationType type,
            String message
    ) {
        notify(userId, type, message, null);
    }

    // 전체 활성 유저 알림함에 동일 알림 적재 (공지 등 브로드캐스트)
    @Transactional
    public void notifyAllUsers(
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationRepository.insertForAllActiveUsers(type.name(), message, targetId, LocalDateTime.now(clock));
    }

    // 특정 유저 목록에게 동일 알림 적재 (친구 활동 등)
    @Transactional
    public void notifyUsers(
            List<Long> userIds,
            NotificationType type,
            String message
    ) {
        notifyUsers(userIds, type, message, null);
    }

    @Transactional
    public void notifyUsers(
            List<Long> userIds,
            NotificationType type,
            String message,
            Long targetId
    ) {
        if (userIds.isEmpty()) {
            return;
        }
        List<Notification> notifications = userIds.stream()
                .map(userId -> Notification.create(userId, type, message, targetId))
                .toList();
        notificationRepository.saveAll(notifications);
    }
}
