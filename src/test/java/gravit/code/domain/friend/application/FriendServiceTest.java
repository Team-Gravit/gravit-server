package gravit.code.domain.friend.application;

import gravit.code.domain.friend.application.dto.response.FriendResponse;
import gravit.code.domain.friend.domain.FriendRepository;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Slf4j
class FriendServiceTest {

    @Autowired
    private FriendService friendService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FriendRepository friendRepository;

    @Test
    void 상호_팔로우_가능한지_검증() {
        // given
        User user1 = User.create("user1@example.com", "provider 1", "User1", "@user1", 1, LocalDateTime.now());
        userRepository.save(user1);
        User user2 = User.create("user2@example.com", "provider 2", "User2", "@user2", 2, LocalDateTime.now());
        userRepository.save(user2);

        // when
        FriendResponse response2 = friendService.following(user1.getId(), user2.getId()); // user2 -> user1
        FriendResponse response1 = friendService.following(user2.getId(), user1.getId()); // user1 -> user2


        // then
        assertThat(response1.followerId()).isEqualTo(user1.getId());
        assertThat(response1.followeeId()).isEqualTo(user2.getId());

        assertThat(response2.followerId()).isEqualTo(user2.getId());
        assertThat(response2.followeeId()).isEqualTo(user1.getId());

        // 추가 검증
        assertThat(friendRepository.existsByFollowerIdAndFolloweeId(user1.getId(), user2.getId())).isTrue();
        assertThat(friendRepository.existsByFollowerIdAndFolloweeId(user2.getId(), user1.getId())).isTrue();

    }

    @Test
    void unFollowing() {
    }
}