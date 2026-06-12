package gravit.code.fcm.service;

import gravit.code.fcm.domain.FcmToken;
import gravit.code.fcm.dto.response.FcmTokenExistsResponse;
import gravit.code.fcm.repository.FcmTokenRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@TCSpringBootTest
class FcmTokenQueryServiceIntegrationTest extends FcmServiceIntegrationTestBase {

    @Autowired
    private FcmTokenQueryService fcmTokenQueryService;

    @Autowired
    private FcmTokenRepository fcmTokenRepository;

    @Nested
    @DisplayName("FCM 토큰 등록 여부를 확인할 때")
    class CheckFcmTokenExist {

        @Test
        void 해당_기기에_토큰이_등록되어_있으면_true를_반환한다() {
            // given
            fcmTokenRepository.save(FcmToken.create(userId, "device-1", "token-1"));

            // when
            FcmTokenExistsResponse response = fcmTokenQueryService.checkFcmTokenExist(userId, "device-1");

            // then
            assertThat(response.registered()).isTrue();
        }

        @Test
        void 등록된_토큰이_없으면_false를_반환한다() {
            // when
            FcmTokenExistsResponse response = fcmTokenQueryService.checkFcmTokenExist(userId, "device-1");

            // then
            assertThat(response.registered()).isFalse();
        }

        @Test
        void 같은_기기라도_다른_유저의_토큰이면_false를_반환한다() {
            // given
            fcmTokenRepository.save(FcmToken.create(otherUserId, "device-1", "token-1"));

            // when
            FcmTokenExistsResponse response = fcmTokenQueryService.checkFcmTokenExist(userId, "device-1");

            // then
            assertThat(response.registered()).isFalse();
        }
    }

    @Nested
    @DisplayName("userId 목록으로 토큰을 조회할 때")
    class GetTokensByUserIds {

        @Test
        void 유저별로_토큰을_묶어_반환하며_멀티_디바이스를_모두_포함한다() {
            // given
            fcmTokenRepository.save(FcmToken.create(userId, "device-1", "token-1"));
            fcmTokenRepository.save(FcmToken.create(userId, "device-2", "token-2"));
            fcmTokenRepository.save(FcmToken.create(otherUserId, "device-3", "token-3"));

            // when
            Map<Long, List<String>> result = fcmTokenQueryService.getTokensByUserIds(List.of(userId, otherUserId));

            // then
            assertThat(result.get(userId)).containsExactlyInAnyOrder("token-1", "token-2");
            assertThat(result.get(otherUserId)).containsExactly("token-3");
        }

        @Test
        void 토큰이_없는_유저는_맵에_포함되지_않는다() {
            // when
            Map<Long, List<String>> result = fcmTokenQueryService.getTokensByUserIds(List.of(userId));

            // then
            assertThat(result).doesNotContainKey(userId);
        }
    }

    @Nested
    @DisplayName("전체 토큰을 조회할 때")
    class GetAllTokens {

        @Test
        void 모든_디바이스_토큰을_반환한다() {
            // given
            fcmTokenRepository.save(FcmToken.create(userId, "device-1", "token-1"));
            fcmTokenRepository.save(FcmToken.create(otherUserId, "device-2", "token-2"));

            // when
            List<String> result = fcmTokenQueryService.getAllTokens();

            // then
            assertThat(result).containsExactlyInAnyOrder("token-1", "token-2");
        }

        @Test
        void 토큰이_없으면_빈_리스트를_반환한다() {
            // when
            List<String> result = fcmTokenQueryService.getAllTokens();

            // then
            assertThat(result).isEmpty();
        }
    }
}
