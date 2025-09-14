package gravit.code.user.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class UserTest {

    @DisplayName("유효한 데이터로 유저를 생성할 수 있다")
    @Test
    void createUserWithAvailableData(){

        // given
        String email = "test@inu.ac.kr";
        String providerId = "google 123456789";
        String nickname = "test";
        String handle = "@f9s2w30";
        int profileImgNumber = 3;
        LocalDateTime createdAt = LocalDateTime.now();

        // when
        User user = User.create(email, providerId, nickname, handle, profileImgNumber, createdAt);

        // then
        assertThat(user.getEmail()).isEqualTo(email);
        assertThat(user.getProviderId()).isEqualTo(providerId);
        assertThat(user.getNickname()).isEqualTo(nickname);
        assertThat(user.getHandle()).isEqualTo(handle);
        assertThat(user.getProfileImgNumber()).isEqualTo(profileImgNumber);
        assertThat(user.getCreatedAt()).isEqualTo(createdAt);
        assertThat(user.getLevel().getLevel()).isEqualTo(1);
        assertThat(user.getLevel().getXp()).isEqualTo(0);
        assertThat(user.isOnboarded()).isFalse();
    }
}