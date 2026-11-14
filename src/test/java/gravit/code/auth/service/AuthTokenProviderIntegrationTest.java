package gravit.code.auth.service;

import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.domain.LoginUser;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.service.port.RefreshTokenStore;
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
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.core.Authentication;

import java.time.Duration;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.TOKEN_USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AuthTokenProviderIntegrationTest {

    private static final String CLIENT_CLAIM_KEY = "client";
    private static final String LEGACY_REFRESH_TOKEN_KEY_PREFIX = "refreshToken:";

    @Autowired
    private AuthTokenProvider authTokenProvider;

    @Autowired
    private JwtProvider jwtProvider;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private RefreshTokenStore refreshTokenStore;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

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
                    .isEqualTo(TOKEN_USER_NOT_FOUND);
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
                    .isEqualTo(TOKEN_USER_NOT_FOUND);
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

    @Nested
    @DisplayName("리프레시 토큰을 기기 종류별로 관리할 때")
    class RefreshTokenPerClient {

        @Test
        void 웹과_안드로이드로_각각_발급하면_두_토큰_모두_유효하다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            String webToken = authTokenProvider.generateRefreshToken(user, LoginClient.WEB).token();
            String androidToken = authTokenProvider.generateRefreshToken(user, LoginClient.ANDROID).token();

            // then
            assertSoftly(softly -> {
                softly.assertThat(authTokenProvider.isValidRefreshToken(webToken)).isTrue();
                softly.assertThat(authTokenProvider.isValidRefreshToken(androidToken)).isTrue();
            });
        }

        @Test
        void 같은_기기_종류로_다시_발급하면_이전_토큰은_무효가_된다() {
            // given
            User user = userFixture.일반_유저(1);
            String previousWebToken = 클라이언트_토큰(user.getId(), LoginClient.WEB.name(), Duration.ofDays(1));
            refreshTokenStore.save(user.getId(), LoginClient.WEB, previousWebToken, Duration.ofDays(1));

            // when
            String newWebToken = authTokenProvider.generateRefreshToken(user, LoginClient.WEB).token();

            // then
            assertSoftly(softly -> {
                softly.assertThat(authTokenProvider.isValidRefreshToken(previousWebToken)).isFalse();
                softly.assertThat(authTokenProvider.isValidRefreshToken(newWebToken)).isTrue();
            });
        }

        @Test
        void 웹_토큰을_삭제해도_안드로이드_토큰은_유효하다() {
            // given
            User user = userFixture.일반_유저(1);
            String webToken = authTokenProvider.generateRefreshToken(user, LoginClient.WEB).token();
            String androidToken = authTokenProvider.generateRefreshToken(user, LoginClient.ANDROID).token();

            // when
            authTokenProvider.deleteRefreshToken(webToken);

            // then
            assertSoftly(softly -> {
                softly.assertThat(authTokenProvider.isValidRefreshToken(webToken)).isFalse();
                softly.assertThat(authTokenProvider.isValidRefreshToken(androidToken)).isTrue();
            });
        }

        @Test
        void 전체_삭제하면_모든_기기_종류의_토큰이_무효가_된다() {
            // given
            User user = userFixture.일반_유저(1);
            String webToken = authTokenProvider.generateRefreshToken(user, LoginClient.WEB).token();
            String androidToken = authTokenProvider.generateRefreshToken(user, LoginClient.ANDROID).token();
            String iosToken = authTokenProvider.generateRefreshToken(user, LoginClient.IOS).token();

            // when
            authTokenProvider.deleteAllRefreshTokens(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(authTokenProvider.isValidRefreshToken(webToken)).isFalse();
                softly.assertThat(authTokenProvider.isValidRefreshToken(androidToken)).isFalse();
                softly.assertThat(authTokenProvider.isValidRefreshToken(iosToken)).isFalse();
            });
        }

        @Test
        void 전체_삭제는_다른_사용자의_토큰을_건드리지_않는다() {
            // given
            User user = userFixture.일반_유저(1);
            User otherUser = userFixture.일반_유저(2);
            authTokenProvider.generateRefreshToken(user, LoginClient.WEB);
            String otherToken = authTokenProvider.generateRefreshToken(otherUser, LoginClient.WEB).token();

            // when
            authTokenProvider.deleteAllRefreshTokens(user.getId());

            // then
            assertThat(authTokenProvider.isValidRefreshToken(otherToken)).isTrue();
        }

        @Test
        void 기기_종류_클레임이_없는_배포_전_토큰은_기존_키에_저장되어_있어도_유효하지_않다() {
            // given
            User user = userFixture.일반_유저(1);
            String legacyToken = jwtProvider.generateToken(new Subject(String.valueOf(user.getId())), Duration.ofDays(14));
            redisTemplate.opsForValue().set(LEGACY_REFRESH_TOKEN_KEY_PREFIX + user.getId(), legacyToken);

            // when & then
            assertThat(authTokenProvider.isValidRefreshToken(legacyToken)).isFalse();
        }

        @Test
        void 알_수_없는_기기_종류_클레임이면_유효하지_않다() {
            // given
            User user = userFixture.일반_유저(1);
            String unknownClientToken = 클라이언트_토큰(user.getId(), "DESKTOP", Duration.ofDays(1));

            // when & then
            assertThat(authTokenProvider.isValidRefreshToken(unknownClientToken)).isFalse();
        }

        @Test
        void 기기_종류_클레임이_없는_토큰으로_로그아웃하면_아무_칸도_지우지_않는다() {
            // given
            User user = userFixture.일반_유저(1);
            String webToken = authTokenProvider.generateRefreshToken(user, LoginClient.WEB).token();
            String legacyToken = jwtProvider.generateToken(new Subject(String.valueOf(user.getId())), Duration.ofDays(14));

            // when
            authTokenProvider.deleteRefreshToken(legacyToken);

            // then
            assertThat(authTokenProvider.isValidRefreshToken(webToken)).isTrue();
        }
    }

    private String 클라이언트_토큰(
            long userId,
            String client,
            Duration expireTime
    ) {
        return jwtProvider.generateToken(
                new Subject(String.valueOf(userId)),
                Map.of(CLIENT_CLAIM_KEY, client),
                expireTime
        );
    }

    private String 토큰(long userId) {
        return jwtProvider.generateToken(
                new Subject(String.valueOf(userId)),
                Map.of("role", "USER"),
                Duration.ofMinutes(15)
        );
    }
}
