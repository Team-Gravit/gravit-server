package gravit.code.social.fixture;

import gravit.code.social.domain.UserFeed;
import gravit.code.social.repository.UserFeedRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class UserFeedFixture {

    private final UserFeedRepository userFeedRepository;

    public UserFeed 기본_유저피드(
            long userId,
            long feedId
    ) {
        return userFeedRepository.save(UserFeed.create(userId, feedId));
    }
}
