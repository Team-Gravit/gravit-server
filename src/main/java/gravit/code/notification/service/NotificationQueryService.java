package gravit.code.notification.service;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.notification.domain.Notification;
import gravit.code.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class NotificationQueryService {

    private static final int PAGE_SIZE = 20;

    private final NotificationRepository notificationRepository;

    @Transactional(readOnly = true)
    public SliceResponse<Notification> getNotifications(
            long userId,
            int page
    ) {
        int safePage = Math.max(0, page);
        Pageable pageable = PageRequest.of(safePage, PAGE_SIZE);
        Slice<Notification> result = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return SliceResponse.of(result);
    }
}
