package gravit.code.user.domain;

import gravit.code.domain.user.domain.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UserTest {

    @DisplayName("유효한 데이터로 유저를 생성할 수 있다")
    @Test
    void createUserWithAvailableData(){

        // given
        String email = "test@inu.ac.kr";
        String nickname = "test";
        String handle = "@f9s2w30";
        String profileImgUrl = "https://example.com/iamge1.jpg";

        // when
        User user = User.create(email, nickname, handle, profileImgUrl);

        // that
        assertThat(user.getEmail()).isEqualTo(email);
        assertThat(user.getNickname()).isEqualTo(nickname);
        assertThat(user.getHandle()).isEqualTo(handle);
        assertThat(user.getProfileImgUrl()).isEqualTo(profileImgUrl);
    }
}