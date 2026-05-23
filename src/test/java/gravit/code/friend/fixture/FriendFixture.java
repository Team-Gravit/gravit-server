package gravit.code.friend.fixture;

import gravit.code.friend.domain.Friend;
import gravit.code.friend.repository.FriendRepository;
import gravit.code.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class FriendFixture {

    private final FriendRepository friendRepository;

    public Friend 팔로우(User follower, User followee) {
        return friendRepository.save(Friend.create(follower.getId(), followee.getId()));
    }
}
