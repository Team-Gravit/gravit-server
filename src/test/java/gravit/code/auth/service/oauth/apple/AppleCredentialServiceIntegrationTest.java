package gravit.code.auth.service.oauth.apple;

import gravit.code.auth.domain.AppleCredential;
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
            appleCredentialService.save(USER_ID, REFRESH_TOKEN);

            // then
            Optional<AppleCredential> saved = appleCredentialRepository.findByUserId(USER_ID);

            assertSoftly(softly -> {
                softly.assertThat(saved).isPresent();
                softly.assertThat(saved.get().getRefreshToken()).isNotEqualTo(REFRESH_TOKEN);
            });
        }

        @Test
        void 이미_보관한_회원이면_새_토큰으로_덮어쓴다() {
            // given
            appleCredentialService.save(USER_ID, REFRESH_TOKEN);

            // when
            appleCredentialService.save(USER_ID, NEW_REFRESH_TOKEN);

            // then
            List<AppleCredential> credentials = appleCredentialRepository.findAll();

            assertSoftly(softly -> {
                softly.assertThat(credentials).hasSize(1);
                softly.assertThat(appleCredentialService.findRefreshToken(USER_ID)).contains(NEW_REFRESH_TOKEN);
            });
        }
    }

    @Nested
    @DisplayName("보관한 Apple 토큰을 조회할 때")
    class FindRefreshToken {

        @Test
        void 복호화한_원문을_돌려준다() {
            // given
            appleCredentialService.save(USER_ID, REFRESH_TOKEN);

            // when
            Optional<String> result = appleCredentialService.findRefreshToken(USER_ID);

            // then
            assertThat(result).contains(REFRESH_TOKEN);
        }

        @Test
        void 보관한_토큰이_없으면_빈_값을_돌려준다() {
            // when
            Optional<String> result = appleCredentialService.findRefreshToken(USER_ID);

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
            appleCredentialService.save(USER_ID, REFRESH_TOKEN);
            appleCredentialService.save(OTHER_USER_ID, REFRESH_TOKEN);

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
