package gravit.code.domain.user.domain;

import gravit.code.domain.user.infrastructure.UserJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.test.annotation.DirtiesContext;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@EnableJpaAuditing
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class UserRepositoryTest {

    @Autowired
    private UserJpaRepository userRepository;

    @BeforeEach
    void setUp() {
        User user = User.create(
                "test@inu.ac.kr",
                "google 123456789",
                "test1",
                "@dc5xay",
                1,
                LocalDateTime.now()
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
        assertThat(user.get().getProviderId()).isEqualTo("google 123456789");
        assertThat(user.get().getNickname()).isEqualTo("test1");
        assertThat(user.get().getHandle()).isEqualTo("@dc5xay");
        assertThat(user.get().getProfileImgNumber()).isEqualTo(1);
        assertThat(user.get().getLevel()).isEqualTo(1);
        assertThat(user.get().getXp()).isZero();
        assertThat(user.get().isOnboarded()).isFalse();
        assertThat(user.get().getCreatedAt()).isNotNull();
    }

    @Test
    @DisplayName("유효한 userId를 통해 메인페이지를 구성하는 유저 정보를 조회할 수 있다.")
    void getUserMainPageInfoByValidUserId(){
        //given
        Long userId = 1L;

        //when
        Optional<User> user = userRepository.findById(userId);

        //then
        assertThat(user).isPresent();
        assertThat(user.get().getId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("유효하지 않은 userId를 통해 메인페이지를 구성하는 유저 정보를 조회하면 Optional.empty()를 반환한다.")
    void getUserMainPageInfoByInvalidUserId(){
        //given
        Long userId = 2L;

        //when
        Optional<User> user = userRepository.findById(userId);

        //then
        assertThat(user).isNotPresent();
    }

}