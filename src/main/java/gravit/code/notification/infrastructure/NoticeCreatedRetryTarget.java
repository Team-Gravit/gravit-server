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

    public static final String QUEUE_KEY = "notice-created-retry";
    public static final String FIELD_HEADLINE = "headline";
    public static final String FIELD_TITLE = "title";
    public static final String FIELD_NOTICE_ID = "noticeId";

    private static final int MAX_ATTEMPTS = 10;

    private final NotificationService notificationService;

    @Override
    public String queueKey() {
        return QUEUE_KEY;
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        String headline = fields.get(FIELD_HEADLINE);
        String title = fields.get(FIELD_TITLE);
        Long noticeId = Long.valueOf(fields.get(FIELD_NOTICE_ID));

        notificationService.notifyAllUsers(NotificationType.NOTICE, headline, title, noticeId);
    }
}
