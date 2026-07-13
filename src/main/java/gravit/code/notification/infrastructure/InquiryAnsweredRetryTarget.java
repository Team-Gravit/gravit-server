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

    private static final int MAX_ATTEMPTS = 10;

    private final NotificationMessageProvider messageProvider;
    private final NotificationFacade notificationFacade;

    @Override
    public String queueKey() {
        return "inquiry-answered-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        long userId = Long.parseLong(fields.get("userId"));
        String title = fields.get("title");
        Long inquiryId = Long.valueOf(fields.get("inquiryId"));

        String message = messageProvider.inquiryAnswered(title);
        notificationFacade.notifyUser(userId, NotificationType.INQUIRY_ANSWERED, message, inquiryId);
    }
}
