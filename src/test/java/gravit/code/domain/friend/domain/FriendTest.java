package gravit.code.domain.friend.domain;

import gravit.code.domain.friend.domain.Friend;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class FriendTest {

    @DisplayName("유효한 데이터로 친구를 생성할 수 있다")
    @Test
    void createFriendWithAvailableDate(){

        // given
        Long followingId = 1L;
        Long followerId = 2L;

        // when
        Friend friend = Friend.create(followingId, followerId);

        // then
        assertThat(friend.getFollowingId()).isEqualTo(followingId);
        assertThat(friend.getFollowerId()).isEqualTo(followerId);
    }
}