package gravit.code.auth.service.oauth;

import gravit.code.auth.domain.AppleClient;
import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.dto.internal.AppleLoginDto;
import gravit.code.auth.dto.internal.AppleStoredTokenDto;
import gravit.code.auth.dto.oauth.AppleUserInfo;
import gravit.code.auth.dto.oauth.GoogleUserInfo;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.repository.AppleCredentialRepository;
import gravit.code.auth.service.oauth.apple.AppleCredentialService;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.exception.AccountSoftDeletedException;
import gravit.code.user.fixture.UserFixtureBuilder;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;

import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class OAuthLoginProcessorIntegrationTest {

    private static final String SUB = "001234.abcdef.0123";
    private static final String PROVIDER_ID = "apple_" + SUB;
    private static final String EMAIL = "relay@privaterelay.appleid.com";
    private static final String REFRESH_TOKEN = "r.apple-refresh-token";
    private static final String NEW_REFRESH_TOKEN = "r.apple-refresh-token-new";
    private static final String GOOGLE_PROVIDER_ID = "google_1029384756";
    private static final String REFRESH_TOKEN_KEY_PREFIX = "refreshToken:";

    @Autowired
    private OAuthLoginProcessor oAuthLoginProcessor;

    @Autowired
    private AppleCredentialService appleCredentialService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AppleCredentialRepository appleCredentialRepository;

    @Autowired
    private UserFixtureBuilder userFixtureBuilder;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    private String 저장된_리프레시_토큰(
            long userId,
            LoginClient client
    ) {
        return redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY_PREFIX + userId + ":" + client.name());
    }

    private AppleLoginDto Apple_로그인(String refreshToken) {
        return Apple_로그인(refreshToken, AppleClient.WEB);
    }

    private AppleLoginDto Apple_로그인(
            String refreshToken,
            AppleClient client
    ) {
        return AppleLoginDto.of(new AppleUserInfo(Map.of("sub", SUB, "email", EMAIL)), refreshToken, client);
    }

    private User Apple_가입_회원() {
        return userFixtureBuilder.user()
                .email(EMAIL)
                .providerId(PROVIDER_ID)
                .nickname(AppleUserInfo.DEFAULT_NAME)
                .handle("apple1")
                .create();
    }

    @Nested
    @DisplayName("Apple 로그인을 처리할 때")
    class ProcessApple {

        @Test
        void 처음_로그인하면_가입시키고_Apple_토큰을_보관한다() {
            // when
            LoginResponse response = oAuthLoginProcessor.processApple(Apple_로그인(REFRESH_TOKEN));

            // then
            User user = userRepository.findByProviderId(PROVIDER_ID).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(response.accessToken()).isNotBlank();
                softly.assertThat(response.refreshToken()).isNotBlank();
                softly.assertThat(response.isOnboarded()).isFalse();
                softly.assertThat(user.getEmail()).isEqualTo(EMAIL);
                softly.assertThat(user.getNickname()).isEqualTo("애플사용자");
                softly.assertThat(appleCredentialService.findRefreshToken(user.getId()).map(AppleStoredTokenDto::refreshToken)).contains(REFRESH_TOKEN);
            });
        }

        @Test
        void 다시_로그인하면_같은_계정으로_로그인하고_보관한_토큰을_최신값으로_바꾼다() {
            // given
            User user = Apple_가입_회원();
            appleCredentialService.save(user.getId(), REFRESH_TOKEN, AppleClient.WEB);

            // when
            oAuthLoginProcessor.processApple(Apple_로그인(NEW_REFRESH_TOKEN));

            // then
            assertSoftly(softly -> {
                softly.assertThat(userRepository.findAll()).hasSize(1);
                softly.assertThat(appleCredentialRepository.findAll()).hasSize(1);
                softly.assertThat(appleCredentialService.findRefreshToken(user.getId()).map(AppleStoredTokenDto::refreshToken)).contains(NEW_REFRESH_TOKEN);
            });
        }

        @Test
        void iOS로_처음_로그인하면_가입시키고_토큰을_IOS_client로_보관한다() {
            // when
            LoginResponse response = oAuthLoginProcessor.processApple(Apple_로그인(REFRESH_TOKEN, AppleClient.IOS));

            // then
            User user = userRepository.findByProviderId(PROVIDER_ID).orElseThrow();
            Optional<AppleStoredTokenDto> stored = appleCredentialService.findRefreshToken(user.getId());

            assertSoftly(softly -> {
                softly.assertThat(response.accessToken()).isNotBlank();
                softly.assertThat(user.getNickname()).isEqualTo("애플사용자");
                softly.assertThat(stored.map(AppleStoredTokenDto::refreshToken)).contains(REFRESH_TOKEN);
                softly.assertThat(stored.map(AppleStoredTokenDto::client)).contains(AppleClient.IOS);
            });
        }

        @Test
        void 웹으로_가입한_회원이_iOS로_로그인하면_같은_계정으로_로그인하고_보관_토큰과_client를_IOS로_바꾼다() {
            // given
            User user = Apple_가입_회원();
            appleCredentialService.save(user.getId(), REFRESH_TOKEN, AppleClient.WEB);

            // when
            oAuthLoginProcessor.processApple(Apple_로그인(NEW_REFRESH_TOKEN, AppleClient.IOS));

            // then
            Optional<AppleStoredTokenDto> stored = appleCredentialService.findRefreshToken(user.getId());

            assertSoftly(softly -> {
                softly.assertThat(userRepository.findAll()).hasSize(1);
                softly.assertThat(appleCredentialRepository.findAll()).hasSize(1);
                softly.assertThat(stored.map(AppleStoredTokenDto::refreshToken)).contains(NEW_REFRESH_TOKEN);
                softly.assertThat(stored.map(AppleStoredTokenDto::client)).contains(AppleClient.IOS);
            });
        }

        @Test
        void refresh_token이_없으면_로그인은_되고_토큰은_보관하지_않는다() {
            // when
            LoginResponse response = oAuthLoginProcessor.processApple(Apple_로그인(null));

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.accessToken()).isNotBlank();
                softly.assertThat(userRepository.findByProviderId(PROVIDER_ID)).isPresent();
                softly.assertThat(appleCredentialRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 탈퇴_상태_계정이면_로그인을_막고_토큰을_보관하지_않는다() {
            // given
            User user = Apple_가입_회원();
            userRepository.deleteById(user.getId());

            // when & then
            assertThatThrownBy(() -> oAuthLoginProcessor.processApple(Apple_로그인(REFRESH_TOKEN)))
                    .isInstanceOf(AccountSoftDeletedException.class);

            assertThat(appleCredentialRepository.findByUserId(user.getId())).isEmpty();
        }
    }

    @Nested
    @DisplayName("리프레시 토큰을 발급할 때")
    class IssueRefreshToken {

        @Test
        void Apple_웹_로그인이면_WEB_칸에만_저장한다() {
            // when
            LoginResponse response = oAuthLoginProcessor.processApple(Apple_로그인(REFRESH_TOKEN, AppleClient.WEB));

            // then
            User user = userRepository.findByProviderId(PROVIDER_ID).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.WEB)).isEqualTo(response.refreshToken());
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.IOS)).isNull();
            });
        }

        @Test
        void Apple_iOS_로그인이면_IOS_칸에만_저장한다() {
            // when
            LoginResponse response = oAuthLoginProcessor.processApple(Apple_로그인(REFRESH_TOKEN, AppleClient.IOS));

            // then
            User user = userRepository.findByProviderId(PROVIDER_ID).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.IOS)).isEqualTo(response.refreshToken());
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.WEB)).isNull();
            });
        }

        @Test
        void 소셜_로그인은_넘겨받은_기기_종류_칸에만_저장한다() {
            // given
            GoogleUserInfo userInfo = new GoogleUserInfo(Map.of(
                    "sub", "1029384756",
                    "email", "learner@gmail.com",
                    "name", "구글학습자"
            ));

            // when
            LoginResponse response = oAuthLoginProcessor.process(userInfo, LoginClient.ANDROID);

            // then
            User user = userRepository.findByProviderId(GOOGLE_PROVIDER_ID).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.ANDROID)).isEqualTo(response.refreshToken());
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.WEB)).isNull();
            });
        }
    }
}
