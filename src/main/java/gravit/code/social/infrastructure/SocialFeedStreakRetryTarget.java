package gravit.code.social.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.facade.SocialFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class SocialFeedStreakRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "social-feed-streak-retry";
    public static final String FIELD_USER_ID = "userId";
    public static final String FIELD_DAYS = "days";

    private static final int MAX_ATTEMPTS = 10;

    private final SocialFacade socialFacade;

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
        String days = fields.get(FIELD_DAYS);

        socialFacade.publishFeed(userId, FeedEventType.STREAK_DAYS, days);
    }
}
