package gravit.code.social.fixture;

import gravit.code.friend.repository.FriendRepository;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.domain.SocialFeed;
import gravit.code.social.domain.UserFeed;
import gravit.code.social.repository.UserFeedRepository;
import gravit.code.social.service.SocialFeedService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

import java.util.List;

@TestComponent
@RequiredArgsConstructor
public class SocialFeedFixtureBuilder {

    private final SocialFeedService socialFeedService;
    private final UserFeedRepository userFeedRepository;
    private final FriendRepository friendRepository;

    private long actorId = 1L;
    private FeedEventType eventType = FeedEventType.LEVEL_UP;
    private String eventValue = "1";

    public SocialFeedFixtureBuilder feed() {
        return new SocialFeedFixtureBuilder(socialFeedService, userFeedRepository, friendRepository);
    }

    public SocialFeedFixtureBuilder actorId(long actorId) { this.actorId = actorId; return this; }
    public SocialFeedFixtureBuilder eventType(FeedEventType eventType) { this.eventType = eventType; return this; }
    public SocialFeedFixtureBuilder eventValue(String eventValue) { this.eventValue = eventValue; return this; }

    public SocialFeed create() {
        SocialFeed feed = socialFeedService.createFeed(actorId, eventType, eventValue);
        List<Long> followerIds = friendRepository.findFollowerIdsByFolloweeId(actorId);
        if (!followerIds.isEmpty()) {
            userFeedRepository.saveAll(
                    followerIds.stream()
                            .map(followerId -> UserFeed.create(followerId, feed.getId()))
                            .toList()
            );
        }
        return feed;
    }
}
