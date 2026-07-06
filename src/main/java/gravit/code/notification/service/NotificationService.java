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

    // 단일 유저에게 서브텍스트까지 포함해 알림함 적재 (시즌 종료 임박·공지 등 subText가 있는 알림)
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

    // 전체 활성 유저 알림함에 동일 알림 적재 (공지 등 브로드캐스트)
    @Transactional
    public void notifyAllUsers(
            NotificationType type,
            String message,
            String subText,
            Long targetId
    ) {
        notificationRepository.insertForAllActiveUsers(type.name(), message, subText, targetId, LocalDateTime.now(clock));
    }

    // 유저별로 다른 메시지를 알림함에 일괄 적재 (연속학습 위기·오늘 미완료 등 개인화 문구)
    @Transactional
    public void notifyEach(
            NotificationType type,
            Map<Long, String> messageByUserId,
            String subText,
            Long targetId
    ) {
        if (messageByUserId.isEmpty()) {
            return;
        }
        List<Notification> notifications = messageByUserId.entrySet().stream()
                .map(entry -> Notification.create(entry.getKey(), type, entry.getValue(), subText, targetId))
                .toList();
        notificationRepository.saveAll(notifications);
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
