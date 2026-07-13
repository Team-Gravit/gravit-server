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

    private static final int MAX_ATTEMPTS = 10;

    private final SocialFacade socialFacade;

    @Override
    public String queueKey() {
        return "social-feed-streak-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        long userId = Long.parseLong(fields.get("userId"));
        String days = fields.get("days");

        socialFacade.publishFeed(userId, FeedEventType.STREAK_DAYS, days);
    }
}
