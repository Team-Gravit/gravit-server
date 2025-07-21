package gravit.code.user.service;

import gravit.code.common.exception.domain.CustomErrorCode;
import gravit.code.common.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void setUp() {
    }

    @Test
    @DisplayName("userId를 통해 레벨과 경험치를 업데이트할 수 있다.")
    void updateUserLevelAndXpByUserId(){
        // given
        Long userId = 1L;
        User user = User.create(
                "test@inu.ac.kr",
                "test1",
                "@dc5xay",
                "https://test-profile-image-url/test.jpg"
        );

        when(userRepository.findById(userId)).thenReturn(Optional.ofNullable(user));

        // when
        UserLevelResponse response =  userService.updateUserLevel(userId);

        // then
        assertThat(response.level()).isEqualTo(1);
        assertThat(response.xp()).isEqualTo(20);
    }

    @Test
    @DisplayName("userId를 통해 유저 조회에 실패한 경우 예외를 반환한다.")
    void updateUserLevelAndXpByNonExistUserId(){
        //given
        Long userId = 100L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> userService.updateUserLevel(userId))
                .isInstanceOf(RestApiException.class)
                .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
    }
}