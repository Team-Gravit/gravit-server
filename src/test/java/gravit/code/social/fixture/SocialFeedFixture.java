package gravit.code.social.fixture;

import gravit.code.social.domain.FeedEventType;
import gravit.code.social.domain.SocialFeed;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class SocialFeedFixture {

    private final SocialFeedFixtureBuilder builder;

    public SocialFeed 레벨업_피드(long actorId, int level) {
        return builder.feed()
                .actorId(actorId)
                .eventType(FeedEventType.LEVEL_UP)
                .eventValue(String.valueOf(level))
                .create();
    }

    public SocialFeed 연속학습_피드(long actorId, int days) {
        return builder.feed()
                .actorId(actorId)
                .eventType(FeedEventType.STREAK_DAYS)
                .eventValue(String.valueOf(days))
                .create();
    }

    public SocialFeed 티어승급_피드(long actorId, String tierName) {
        return builder.feed()
                .actorId(actorId)
                .eventType(FeedEventType.TIER_PROMOTION)
                .eventValue(tierName)
                .create();
    }

    public SocialFeed 행성정복_피드(long actorId, String planetName) {
        return builder.feed()
                .actorId(actorId)
                .eventType(FeedEventType.PLANET_COMPLETE)
                .eventValue(planetName)
                .create();
    }
}
