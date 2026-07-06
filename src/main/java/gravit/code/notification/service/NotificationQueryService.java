package gravit.code.notification.service;

import gravit.code.notification.domain.Notification;
import gravit.code.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationQueryService {

    // 알림함 노출 정책: 최근 30일 이내, 최신 30건
    private static final int MAX_SIZE = 30;
    private static final int RETENTION_DAYS = 30;
    private static final Pageable LATEST_30 = PageRequest.of(0, MAX_SIZE);

    private final NotificationRepository notificationRepository;
    private final Clock clock;

    @Transactional(readOnly = true)
    public List<Notification> getNotifications(long userId) {
        LocalDateTime threshold = LocalDateTime.now(clock).minusDays(RETENTION_DAYS);
        return notificationRepository.findRecent(userId, threshold, LATEST_30);
    }
}
