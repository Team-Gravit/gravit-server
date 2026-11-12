package gravit.code.auth.listener;

import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.auth.service.port.RefreshTokenStore;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.UserDeletionService;
import gravit.code.user.service.port.MailAuthCodeStore;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.QueryTimeoutException;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.doThrow;

@TCSpringBootTest
class RefreshTokenRevokeListenerIntegrationTest {

    private static final String REFRESH_TOKEN_KEY_PREFIX = "refreshToken:";
    private static final String MAIL_AUTH_CODE = "validauthcode123";
    private static final int MAIL_AUTH_CODE_EXPIRE_SECONDS = 180;

    @Autowired
    private UserDeletionService userDeletionService;

    @Autowired
    private AuthTokenProvider authTokenProvider;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private MailAuthCodeStore mailAuthCodeStore;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @MockitoSpyBean
    private RefreshTokenStore refreshTokenStore;

    private void 탈퇴_확정(User user) {
        mailAuthCodeStore.save(MAIL_AUTH_CODE, user.getId(), MAIL_AUTH_CODE_EXPIRE_SECONDS);
        userDeletionService.confirmDeleteByMailAuthCode(MAIL_AUTH_CODE);
    }

    private void 모든_기기로_로그인(User user) {
        for (LoginClient client : LoginClient.values()) {
            authTokenProvider.generateRefreshToken(user, client);
        }
    }

    private String 저장된_리프레시_토큰(
            long userId,
            LoginClient client
    ) {
        return redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY_PREFIX + userId + ":" + client.name());
    }

    @Nested
    @DisplayName("회원 탈퇴가 확정되면")
    class HandleUserWithdrawn {

        @Test
        void 그_회원의_모든_기기_종류_리프레시_토큰을_지운다() {
            // given
            User user = userFixture.일반_유저(1);
            모든_기기로_로그인(user);

            // when
            탈퇴_확정(user);

            // then
            assertSoftly(softly -> {
                for (LoginClient client : LoginClient.values()) {
                    softly.assertThat(저장된_리프레시_토큰(user.getId(), client)).isNull();
                }
            });
        }

        @Test
        void 다른_회원의_리프레시_토큰은_남긴다() {
            // given
            User user = userFixture.일반_유저(1);
            User otherUser = userFixture.일반_유저(2);
            모든_기기로_로그인(user);
            String otherToken = authTokenProvider.generateRefreshToken(otherUser, LoginClient.WEB).token();

            // when
            탈퇴_확정(user);

            // then
            assertThat(저장된_리프레시_토큰(otherUser.getId(), LoginClient.WEB)).isEqualTo(otherToken);
        }

        @Test
        void 리프레시_토큰_삭제가_실패해도_탈퇴는_확정된다() {
            // given
            User user = userFixture.일반_유저(1);
            모든_기기로_로그인(user);
            doThrow(new QueryTimeoutException("redis timeout")).when(refreshTokenStore).deleteAll(anyLong());

            // when
            탈퇴_확정(user);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userRepository.findById(user.getId())).isEmpty();
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.WEB)).isNotNull();
            });
        }
    }
}
