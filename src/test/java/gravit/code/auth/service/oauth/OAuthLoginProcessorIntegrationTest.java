package gravit.code.auth.service.oauth;

import gravit.code.auth.dto.internal.AppleLoginDto;
import gravit.code.auth.dto.oauth.AppleUserInfo;
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

import java.util.Map;

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

    private AppleLoginDto Apple_로그인(String refreshToken) {
        return AppleLoginDto.of(new AppleUserInfo(Map.of("sub", SUB, "email", EMAIL)), refreshToken);
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
                softly.assertThat(appleCredentialService.findRefreshToken(user.getId())).contains(REFRESH_TOKEN);
            });
        }

        @Test
        void 다시_로그인하면_같은_계정으로_로그인하고_보관한_토큰을_최신값으로_바꾼다() {
            // given
            User user = Apple_가입_회원();
            appleCredentialService.save(user.getId(), REFRESH_TOKEN);

            // when
            oAuthLoginProcessor.processApple(Apple_로그인(NEW_REFRESH_TOKEN));

            // then
            assertSoftly(softly -> {
                softly.assertThat(userRepository.findAll()).hasSize(1);
                softly.assertThat(appleCredentialRepository.findAll()).hasSize(1);
                softly.assertThat(appleCredentialService.findRefreshToken(user.getId())).contains(NEW_REFRESH_TOKEN);
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
}
