package gravit.code.notification.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.notification.support.NotificationMessageProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class InquiryAnsweredRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "inquiry-answered-retry";
    public static final String FIELD_USER_ID = "userId";
    public static final String FIELD_TITLE = "title";
    public static final String FIELD_INQUIRY_ID = "inquiryId";

    private static final int MAX_ATTEMPTS = 10;

    private final NotificationFacade notificationFacade;

    private final NotificationMessageProvider messageProvider;

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
        long userId = Long.parseLong(fields.get(FIELD_USER_ID));
        String title = fields.get(FIELD_TITLE);
        Long inquiryId = Long.valueOf(fields.get(FIELD_INQUIRY_ID));

        String message = messageProvider.inquiryAnswered(title);
        notificationFacade.notifyUser(userId, NotificationType.INQUIRY_ANSWERED, message, inquiryId);
    }
}
