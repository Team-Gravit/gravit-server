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
import java.util.Map;

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
            String message,
            String subText,
            Long targetId
    ) {
        notificationRepository.save(Notification.create(userId, type, message, subText, targetId));
    }

    @Transactional
    public void notifyAllUsers(
            NotificationType type,
            String message,
            String subText,
            Long targetId
    ) {
        notificationRepository.insertForAllActiveUsers(type.name(), message, subText, targetId, LocalDateTime.now(clock));
    }

    @Transactional
    public void notifyEach(
            NotificationType type,
            Map<Long, String> userIdToMessage,
            String subText,
            Long targetId
    ) {
        if (userIdToMessage.isEmpty()) {
            return;
        }
        List<Notification> notifications = userIdToMessage.entrySet().stream()
                .map(entry -> Notification.create(entry.getKey(), type, entry.getValue(), subText, targetId))
                .toList();
        notificationRepository.saveAll(notifications);
    }

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
