package gravit.code.friend.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatNoException;

class FriendTest {

    @DisplayName("유효한 데이터로 친구를 생성할 수 있다")
    @Test
    void createFriendWithAvailableDate(){
        assertThatNoException().isThrownBy(() ->
                Friend.create(1L,2L));
    }
}