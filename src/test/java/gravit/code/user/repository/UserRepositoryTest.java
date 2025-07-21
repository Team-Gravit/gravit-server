package gravit.code.user.repository;

import gravit.code.user.domain.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@EnableJpaAuditing
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    void setUp() {
        User user = User.create(
                "test@inu.ac.kr",
                "test1",
                "@dc5xay",
                "https://test-profile-image-url/test.jpg"
        );
        userRepository.save(user);
    }

    @Test
    @DisplayName("userId를 통해 User를 조회할 수 있다.")
    void getUserByUserId(){
        // given
        Long userId = 1L;

        // when
        Optional<User> user = userRepository.findById(userId);

        // then
        assertThat(user).isPresent();
        assertThat(user.get().getId()).isEqualTo(1L);
        assertThat(user.get().getEmail()).isEqualTo("test@inu.ac.kr");
        assertThat(user.get().getHandle()).isEqualTo("@dc5xay");
        assertThat(user.get().getProfileImgUrl()).isEqualTo("https://test-profile-image-url/test.jpg");
        assertThat(user.get().getLevel()).isEqualTo(1);
        assertThat(user.get().getXp()).isZero();
        assertThat(user.get().getCreatedAt()).isNotNull();
    }

}