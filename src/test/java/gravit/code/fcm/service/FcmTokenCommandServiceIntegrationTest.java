package gravit.code.fcm.service;

import gravit.code.fcm.domain.FcmToken;
import gravit.code.fcm.dto.request.RegisterFcmTokenRequest;
import gravit.code.fcm.repository.FcmTokenRepository;
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
class FcmTokenCommandServiceIntegrationTest extends FcmServiceIntegrationTestBase {

    @Autowired
    private FcmTokenCommandService fcmTokenCommandService;

    @Autowired
    private FcmTokenRepository fcmTokenRepository;

    @Nested
    @DisplayName("FCM 토큰을 등록할 때")
    class RegisterFcmToken {

        @Test
        void 등록_내역이_없으면_새로_저장한다() {
            // given
            RegisterFcmTokenRequest request = new RegisterFcmTokenRequest("device-1", "token-1");

            // when
            fcmTokenCommandService.registerFcmToken(userId, request);

            // then
            Optional<FcmToken> saved = fcmTokenRepository.findByDeviceId("device-1");
            assertSoftly(softly -> {
                softly.assertThat(saved).isPresent();
                softly.assertThat(saved.get().getUserId()).isEqualTo(userId);
                softly.assertThat(saved.get().getToken()).isEqualTo("token-1");
            });
        }

        @Test
        void 같은_기기에서_다시_등록하면_토큰만_갱신되고_행은_하나다() {
            // given
            fcmTokenCommandService.registerFcmToken(userId, new RegisterFcmTokenRequest("device-1", "token-old"));

            // when
            fcmTokenCommandService.registerFcmToken(userId, new RegisterFcmTokenRequest("device-1", "token-new"));

            // then
            List<FcmToken> all = fcmTokenRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(all).hasSize(1);
                softly.assertThat(all.get(0).getToken()).isEqualTo("token-new");
                softly.assertThat(all.get(0).getUserId()).isEqualTo(userId);
            });
        }

        @Test
        void 다른_유저가_같은_기기로_등록하면_소유자가_이전된다() {
            // given
            fcmTokenCommandService.registerFcmToken(userId, new RegisterFcmTokenRequest("device-1", "token-a"));

            // when
            fcmTokenCommandService.registerFcmToken(otherUserId, new RegisterFcmTokenRequest("device-1", "token-b"));

            // then
            List<FcmToken> all = fcmTokenRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(all).hasSize(1);
                softly.assertThat(all.get(0).getUserId()).isEqualTo(otherUserId);
                softly.assertThat(all.get(0).getToken()).isEqualTo("token-b");
            });
        }

        @Test
        void 같은_유저가_다른_기기로_등록하면_여러_행이_저장된다() {
            // given
            fcmTokenCommandService.registerFcmToken(userId, new RegisterFcmTokenRequest("device-1", "token-1"));

            // when
            fcmTokenCommandService.registerFcmToken(userId, new RegisterFcmTokenRequest("device-2", "token-2"));

            // then
            List<FcmToken> all = fcmTokenRepository.findAll();
            assertThat(all).hasSize(2);
        }
    }
}
