package gravit.code.auth.listener;

import gravit.code.auth.domain.AppleClient;
import gravit.code.auth.dto.internal.AppleStoredTokenDto;
import gravit.code.auth.infrastructure.client.OAuthHttpClientAdapter;
import gravit.code.auth.repository.AppleCredentialRepository;
import gravit.code.auth.service.oauth.apple.AppleCredentialService;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.UserDeletionService;
import gravit.code.user.service.port.MailAuthCodeStore;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.util.MultiValueMap;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_SERVER_ERROR;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class AppleTokenRevokeListenerIntegrationTest {

    private static final String REVOKE_URI = "https://appleid.apple.com/auth/revoke";
    private static final String WEB_CLIENT_ID = "test.apple.client.id";
    private static final String IOS_BUNDLE_ID = "kr.inuappcenter.gravit.test";
    private static final String REFRESH_TOKEN = "r.apple-refresh-token";
    private static final String MAIL_AUTH_CODE = "validauthcode123";
    private static final int MAIL_AUTH_CODE_EXPIRE_SECONDS = 180;

    @Autowired
    private UserDeletionService userDeletionService;

    @Autowired
    private AppleCredentialService appleCredentialService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AppleCredentialRepository appleCredentialRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private MailAuthCodeStore mailAuthCodeStore;

    @MockitoBean
    private OAuthHttpClientAdapter oAuthHttpClientAdapter;

    private void 탈퇴_확정(User user) {
        mailAuthCodeStore.save(MAIL_AUTH_CODE, user.getId(), MAIL_AUTH_CODE_EXPIRE_SECONDS);
        userDeletionService.confirmDeleteByMailAuthCode(MAIL_AUTH_CODE);
    }

    @SuppressWarnings("unchecked")
    private MultiValueMap<String, String> 보낸_철회_요청() {
        ArgumentCaptor<MultiValueMap<String, String>> captor = ArgumentCaptor.forClass(MultiValueMap.class);
        verify(oAuthHttpClientAdapter).revokeToken(eq(REVOKE_URI), captor.capture());
        return captor.getValue();
    }

    private String client_secret_페이로드(String clientSecret) {
        return new String(Base64.getUrlDecoder().decode(clientSecret.split("\\.")[1]), StandardCharsets.UTF_8);
    }

    @Nested
    @DisplayName("회원 탈퇴가 확정되면")
    class HandleUserWithdrawn {

        @Test
        void 웹에서_보관한_Apple_토큰을_Services_ID로_철회하고_지운다() {
            // given
            User user = userFixture.일반_유저(1);
            appleCredentialService.save(user.getId(), REFRESH_TOKEN, AppleClient.WEB);

            // when
            탈퇴_확정(user);

            // then
            MultiValueMap<String, String> request = 보낸_철회_요청();

            assertSoftly(softly -> {
                softly.assertThat(request.getFirst("token")).isEqualTo(REFRESH_TOKEN);
                softly.assertThat(request.getFirst("client_id")).isEqualTo(WEB_CLIENT_ID);
                softly.assertThat(client_secret_페이로드(request.getFirst("client_secret"))).contains("\"sub\":\"" + WEB_CLIENT_ID + "\"");
                softly.assertThat(appleCredentialRepository.findByUserId(user.getId())).isEmpty();
                softly.assertThat(userRepository.findById(user.getId())).isEmpty();
            });
        }

        @Test
        void iOS에서_보관한_Apple_토큰을_Bundle_ID로_철회하고_지운다() {
            // given
            User user = userFixture.일반_유저(1);
            appleCredentialService.save(user.getId(), REFRESH_TOKEN, AppleClient.IOS);

            // when
            탈퇴_확정(user);

            // then
            MultiValueMap<String, String> request = 보낸_철회_요청();

            assertSoftly(softly -> {
                softly.assertThat(request.getFirst("token")).isEqualTo(REFRESH_TOKEN);
                softly.assertThat(request.getFirst("client_id")).isEqualTo(IOS_BUNDLE_ID);
                softly.assertThat(client_secret_페이로드(request.getFirst("client_secret"))).contains("\"sub\":\"" + IOS_BUNDLE_ID + "\"");
                softly.assertThat(appleCredentialRepository.findByUserId(user.getId())).isEmpty();
                softly.assertThat(userRepository.findById(user.getId())).isEmpty();
            });
        }

        @Test
        void 철회가_실패해도_탈퇴는_확정되고_토큰은_실제_삭제_때를_위해_남긴다() {
            // given
            User user = userFixture.일반_유저(1);
            appleCredentialService.save(user.getId(), REFRESH_TOKEN, AppleClient.WEB);
            doThrow(new RestApiException(OAUTH_SERVER_ERROR)).when(oAuthHttpClientAdapter).revokeToken(any(), any());

            // when
            탈퇴_확정(user);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userRepository.findById(user.getId())).isEmpty();
                softly.assertThat(appleCredentialService.findRefreshToken(user.getId()).map(AppleStoredTokenDto::refreshToken)).contains(REFRESH_TOKEN);
            });
        }

        @Test
        void Apple_토큰이_없는_회원이면_철회를_요청하지_않는다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            탈퇴_확정(user);

            // then
            verify(oAuthHttpClientAdapter, never()).revokeToken(any(), any());
        }
    }
}
