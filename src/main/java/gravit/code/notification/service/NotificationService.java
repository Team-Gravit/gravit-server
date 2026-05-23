package gravit.code.notification.service;

import gravit.code.notification.domain.Notification;
import gravit.code.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;

    @Transactional
    public void notify(
            long userId,
            String message
    ) {
        notificationRepository.save(Notification.create(userId, message));
    }
}
