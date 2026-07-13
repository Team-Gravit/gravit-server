package gravit.code.notification.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class NoticeCreatedRetryTarget implements RetrySweepTarget {

    private static final int MAX_ATTEMPTS = 10;

    private final NotificationService notificationService;

    @Override
    public String queueKey() {
        return "notice-created-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        String headline = fields.get("headline");
        String title = fields.get("title");
        Long noticeId = Long.valueOf(fields.get("noticeId"));

        notificationService.notifyAllUsers(NotificationType.NOTICE, headline, title, noticeId);
    }
}
