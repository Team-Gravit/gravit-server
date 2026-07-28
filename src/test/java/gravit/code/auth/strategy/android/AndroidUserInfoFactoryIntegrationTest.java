package gravit.code.auth.strategy.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_USER_INFO_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AndroidUserInfoFactoryIntegrationTest {

    @Nested
    @DisplayName("구글 idToken 클레임으로 사용자 정보를 생성할 때")
    class FromGoogleClaims {

        @Test
        @DisplayName("필수 클레임이 모두 있으면 OAuthUserInfo 로 매핑된다")
        void 필수_클레임이_모두_있으면_매핑에_성공한다() {
            // given
            Map<String, Object> claims = Map.of(
                    "sub", "google-provider-id",
                    "email", "tester@gmail.com",
                    "name", "테스터"
            );

            // when
            OAuthUserInfo userInfo = AndroidUserInfoFactory.fromClaims("google", claims);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("google");
                softly.assertThat(userInfo.getProviderId()).isEqualTo("google-provider-id");
                softly.assertThat(userInfo.getEmail()).isEqualTo("tester@gmail.com");
                softly.assertThat(userInfo.getName()).isEqualTo("테스터");
            });
        }

        @Test
        @DisplayName("sub 클레임이 없으면 providerId 오염 대신 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void sub_클레임이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> claims = Map.of(
                    "email", "tester@gmail.com",
                    "name", "테스터"
            );

            // when & then
            assertThatThrownBy(() -> AndroidUserInfoFactory.fromClaims("google", claims))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("email 클레임이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void email_클레임이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> claims = Map.of(
                    "sub", "google-provider-id",
                    "name", "테스터"
            );

            // when & then
            assertThatThrownBy(() -> AndroidUserInfoFactory.fromClaims("google", claims))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }
    }

    @Nested
    @DisplayName("카카오 idToken 클레임으로 사용자 정보를 생성할 때")
    class FromKakaoClaims {

        @Test
        @DisplayName("필수 클레임이 모두 있으면 OAuthUserInfo 로 매핑된다")
        void 필수_클레임이_모두_있으면_매핑에_성공한다() {
            // given
            Map<String, Object> claims = Map.of(
                    "sub", "kakao-provider-id",
                    "email", "tester@kakao.com",
                    "nickname", "테스터"
            );

            // when
            OAuthUserInfo userInfo = AndroidUserInfoFactory.fromClaims("kakao", claims);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("kakao");
                softly.assertThat(userInfo.getProviderId()).isEqualTo("kakao-provider-id");
                softly.assertThat(userInfo.getEmail()).isEqualTo("tester@kakao.com");
                softly.assertThat(userInfo.getName()).isEqualTo("테스터");
            });
        }

        @Test
        @DisplayName("email 동의를 하지 않아 email 클레임이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void email_클레임이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> claims = Map.of(
                    "sub", "kakao-provider-id",
                    "nickname", "테스터"
            );

            // when & then
            assertThatThrownBy(() -> AndroidUserInfoFactory.fromClaims("kakao", claims))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("nickname 클레임이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void nickname_클레임이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> claims = Map.of(
                    "sub", "kakao-provider-id",
                    "email", "tester@kakao.com"
            );

            // when & then
            assertThatThrownBy(() -> AndroidUserInfoFactory.fromClaims("kakao", claims))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("필수 클레임이 공백 문자열이면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 필수_클레임이_공백이면_예외가_발생한다() {
            // given
            Map<String, Object> claims = Map.of(
                    "sub", "   ",
                    "email", "tester@kakao.com",
                    "nickname", "테스터"
            );

            // when & then
            assertThatThrownBy(() -> AndroidUserInfoFactory.fromClaims("kakao", claims))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }
    }

    @Test
    @DisplayName("지원하지 않는 provider 면 PROVIDER_INVALID 예외가 발생한다")
    void 지원하지_않는_provider_면_예외가_발생한다() {
        // given
        Map<String, Object> claims = Map.of("sub", "1");

        // when & then
        assertThatThrownBy(() -> AndroidUserInfoFactory.fromClaims("samsung", claims))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(PROVIDER_INVALID);
    }
}
