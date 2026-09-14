package gravit.code.social.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.facade.SocialFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class SocialFeedLevelUpRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "social-feed-levelup-retry";
    public static final String FIELD_USER_ID = "userId";
    public static final String FIELD_NEW_LEVEL = "newLevel";

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
        String newLevel = fields.get(FIELD_NEW_LEVEL);

        socialFacade.publishFeed(userId, FeedEventType.LEVEL_UP, newLevel);
    }
}
