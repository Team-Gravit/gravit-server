package gravit.code.test.user;

import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class TestUserCheatCreateControllerIntegrationTest {

    private static final String LOGIN_URI = "/api/v1/test/users/login";
    private static final long UNKNOWN_USER_ID = 999_999L;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Nested
    @DisplayName("userId로 로그인 토큰을 요청할 때")
    class Login {

        @Test
        void 존재하는_유저면_토큰을_발급한다() throws Exception {
            // given
            User user = userRepository.save(User.create("login@test.com", "login-provider", "로그인유저", "login01", 1, Role.USER));

            // when & then
            mockMvc.perform(post(LOGIN_URI).param("userId", String.valueOf(user.getId())))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty())
                    .andExpect(jsonPath("$.refreshToken").isNotEmpty());
        }

        @Test
        void 존재하지_않는_유저면_404를_반환한다() throws Exception {
            // when & then
            mockMvc.perform(post(LOGIN_URI).param("userId", String.valueOf(UNKNOWN_USER_ID)))
                    .andExpect(status().isNotFound())
                    .andExpect(jsonPath("$.error").value(USER_NOT_FOUND.getCode()));
        }
    }
}
