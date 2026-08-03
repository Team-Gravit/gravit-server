package gravit.code.auth.service;

import gravit.code.auth.domain.LoginUser;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.token.JwtProvider;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;

import java.time.Duration;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AuthTokenProviderIntegrationTest {

    @Autowired
    private AuthTokenProvider authTokenProvider;

    @Autowired
    private JwtProvider jwtProvider;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Nested
    @DisplayName("토큰에서 유저를 조회할 때")
    class ParseUser {

        @Test
        void 토큰_주체에_해당하는_유저를_반환한다() {
            // given
            User user = userFixture.일반_유저(1);
            String token = 토큰(user.getId());

            // when
            User parsed = authTokenProvider.parseUser(token);

            // then
            assertSoftly(softly -> {
                softly.assertThat(parsed.getId()).isEqualTo(user.getId());
                softly.assertThat(parsed.getProviderId()).isEqualTo(user.getProviderId());
            });
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            String token = 토큰(9_999_999L);

            // when & then
            assertThatThrownBy(() -> authTokenProvider.parseUser(token))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 탈퇴한_유저이면_예외를_던진다() {
            // given
            User user = userFixture.일반_유저(1);
            String token = 토큰(user.getId());
            userRepository.delete(user);

            // when & then
            assertThatThrownBy(() -> authTokenProvider.parseUser(token))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("유저로 인증 객체를 만들 때")
    class GetAuthUser {

        @Test
        void principal로_LoginUser를_담는다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            Authentication authentication = authTokenProvider.getAuthUser(user);

            // then
            assertSoftly(softly -> {
                softly.assertThat(authentication.getPrincipal()).isInstanceOf(LoginUser.class);

                LoginUser loginUser = (LoginUser) authentication.getPrincipal();
                softly.assertThat(loginUser.getId()).isEqualTo(user.getId());
                softly.assertThat(loginUser.getProvider()).isEqualTo(user.getProviderId());
                softly.assertThat(loginUser.getAuthorities())
                        .extracting("authority")
                        .containsExactly("ROLE_" + user.getRole().name());
            });
        }

        @Test
        void 조회한_유저와_같은_id로_인증_객체를_만든다() {
            // given
            User user = userFixture.일반_유저(1);
            String token = 토큰(user.getId());

            // when
            User parsed = authTokenProvider.parseUser(token);
            Authentication authentication = authTokenProvider.getAuthUser(parsed);

            // then
            LoginUser loginUser = (LoginUser) authentication.getPrincipal();
            assertThat(loginUser.getId()).isEqualTo(user.getId());
        }
    }

    private String 토큰(long userId) {
        return jwtProvider.generateToken(
                new Subject(String.valueOf(userId)),
                Map.of("role", "USER"),
                Duration.ofMinutes(15)
        );
    }
}
