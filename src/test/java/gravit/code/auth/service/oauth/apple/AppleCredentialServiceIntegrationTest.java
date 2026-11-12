package gravit.code.auth.service.oauth.apple;

import gravit.code.auth.domain.AppleClient;
import gravit.code.auth.domain.AppleCredential;
import gravit.code.auth.dto.internal.AppleStoredTokenDto;
import gravit.code.auth.repository.AppleCredentialRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AppleCredentialServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final String REFRESH_TOKEN = "r.apple-refresh-token";
    private static final String NEW_REFRESH_TOKEN = "r.apple-refresh-token-new";

    @Autowired
    private AppleCredentialService appleCredentialService;

    @Autowired
    private AppleCredentialRepository appleCredentialRepository;

    @Nested
    @DisplayName("Apple 토큰을 보관할 때")
    class Save {

        @Test
        void 원문이_아닌_암호문으로_저장한다() {
            // when
            appleCredentialService.save(USER_ID, REFRESH_TOKEN, AppleClient.WEB);

            // then
            Optional<AppleCredential> saved = appleCredentialRepository.findByUserId(USER_ID);

            assertSoftly(softly -> {
                softly.assertThat(saved).isPresent();
                softly.assertThat(saved.get().getRefreshToken()).isNotEqualTo(REFRESH_TOKEN);
            });
        }

        @Test
        void 발급한_client를_함께_저장한다() {
            // when
            appleCredentialService.save(USER_ID, REFRESH_TOKEN, AppleClient.IOS);

            // then
            Optional<AppleCredential> saved = appleCredentialRepository.findByUserId(USER_ID);

            assertSoftly(softly -> {
                softly.assertThat(saved).isPresent();
                softly.assertThat(saved.get().getClient()).isEqualTo(AppleClient.IOS);
            });
        }

        @Test
        void 이미_보관한_회원이면_새_토큰으로_덮어쓴다() {
            // given
            appleCredentialService.save(USER_ID, REFRESH_TOKEN, AppleClient.WEB);

            // when
            appleCredentialService.save(USER_ID, NEW_REFRESH_TOKEN, AppleClient.WEB);

            // then
            List<AppleCredential> credentials = appleCredentialRepository.findAll();

            assertSoftly(softly -> {
                softly.assertThat(credentials).hasSize(1);
                softly.assertThat(appleCredentialService.findRefreshToken(USER_ID).map(AppleStoredTokenDto::refreshToken)).contains(NEW_REFRESH_TOKEN);
            });
        }

        @Test
        void 웹에서_보관한_회원이_iOS로_로그인하면_토큰과_client를_IOS로_덮어쓴다() {
            // given
            appleCredentialService.save(USER_ID, REFRESH_TOKEN, AppleClient.WEB);

            // when
            appleCredentialService.save(USER_ID, NEW_REFRESH_TOKEN, AppleClient.IOS);

            // then
            Optional<AppleStoredTokenDto> stored = appleCredentialService.findRefreshToken(USER_ID);

            assertSoftly(softly -> {
                softly.assertThat(appleCredentialRepository.findAll()).hasSize(1);
                softly.assertThat(stored.map(AppleStoredTokenDto::refreshToken)).contains(NEW_REFRESH_TOKEN);
                softly.assertThat(stored.map(AppleStoredTokenDto::client)).contains(AppleClient.IOS);
            });
        }
    }

    @Nested
    @DisplayName("보관한 Apple 토큰을 조회할 때")
    class FindRefreshToken {

        @Test
        void 복호화한_원문과_발급한_client를_돌려준다() {
            // given
            appleCredentialService.save(USER_ID, REFRESH_TOKEN, AppleClient.IOS);

            // when
            Optional<AppleStoredTokenDto> result = appleCredentialService.findRefreshToken(USER_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.map(AppleStoredTokenDto::refreshToken)).contains(REFRESH_TOKEN);
                softly.assertThat(result.map(AppleStoredTokenDto::client)).contains(AppleClient.IOS);
            });
        }

        @Test
        void 보관한_토큰이_없으면_빈_값을_돌려준다() {
            // when
            Optional<AppleStoredTokenDto> result = appleCredentialService.findRefreshToken(USER_ID);

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("보관한 Apple 토큰을 지울 때")
    class DeleteByUserId {

        @Test
        void 해당_회원의_토큰만_지운다() {
            // given
            appleCredentialService.save(USER_ID, REFRESH_TOKEN, AppleClient.WEB);
            appleCredentialService.save(OTHER_USER_ID, REFRESH_TOKEN, AppleClient.WEB);

            // when
            appleCredentialService.deleteByUserId(USER_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(appleCredentialRepository.findByUserId(USER_ID)).isEmpty();
                softly.assertThat(appleCredentialRepository.findByUserId(OTHER_USER_ID)).isPresent();
            });
        }
    }
}
