package gravit.code.auth.strategy;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_USER_INFO_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class OAuthResponseFactoryIntegrationTest {

    @Autowired
    private OAuthResponseFactory oAuthResponseFactory;

    @Nested
    @DisplayName("네이버 사용자 정보를 생성할 때")
    class CreateNaverUserInfo {

        @Test
        @DisplayName("response 안의 필수 값이 모두 있으면 OAuthUserInfo 로 매핑된다")
        void 필수_값이_모두_있으면_매핑에_성공한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "resultcode", "00",
                    "response", Map.of(
                            "id", "naver-provider-id",
                            "email", "tester@naver.com",
                            "name", "테스터"
                    )
            );

            // when
            OAuthUserInfo userInfo = oAuthResponseFactory.createOAuthUserInfo("naver", attributes);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("naver");
                softly.assertThat(userInfo.getProviderId()).isEqualTo("naver-provider-id");
                softly.assertThat(userInfo.getEmail()).isEqualTo("tester@naver.com");
                softly.assertThat(userInfo.getName()).isEqualTo("테스터");
            });
        }

        @Test
        @DisplayName("id 가 없으면 NPE 대신 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void id_가_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "response", Map.of(
                            "email", "tester@naver.com",
                            "name", "테스터"
                    )
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("naver", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("email 이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void email_이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "response", Map.of(
                            "id", "naver-provider-id",
                            "name", "테스터"
                    )
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("naver", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("name 이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void name_이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "response", Map.of(
                            "id", "naver-provider-id",
                            "email", "tester@naver.com"
                    )
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("naver", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("response 자체가 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void response_가_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of("resultcode", "00");

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("naver", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("필수 값이 공백 문자열이면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 필수_값이_공백이면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "response", Map.of(
                            "id", "naver-provider-id",
                            "email", "   ",
                            "name", "테스터"
                    )
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("naver", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }
    }

    @Nested
    @DisplayName("구글 사용자 정보를 생성할 때")
    class CreateGoogleUserInfo {

        @Test
        @DisplayName("필수 값이 모두 있으면 OAuthUserInfo 로 매핑된다")
        void 필수_값이_모두_있으면_매핑에_성공한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "sub", "google-provider-id",
                    "email", "tester@gmail.com",
                    "name", "테스터"
            );

            // when
            OAuthUserInfo userInfo = oAuthResponseFactory.createOAuthUserInfo("google", attributes);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("google");
                softly.assertThat(userInfo.getProviderId()).isEqualTo("google-provider-id");
                softly.assertThat(userInfo.getEmail()).isEqualTo("tester@gmail.com");
                softly.assertThat(userInfo.getName()).isEqualTo("테스터");
            });
        }

        @Test
        @DisplayName("sub 가 없으면 NPE 대신 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void sub_가_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "email", "tester@gmail.com",
                    "name", "테스터"
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("google", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("email 이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void email_이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "sub", "google-provider-id",
                    "name", "테스터"
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("google", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }
    }

    @Nested
    @DisplayName("카카오 사용자 정보를 생성할 때")
    class CreateKakaoUserInfo {

        @Test
        @DisplayName("필수 값이 모두 있으면 OAuthUserInfo 로 매핑된다")
        void 필수_값이_모두_있으면_매핑에_성공한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "id", 1234567890L,
                    "kakao_account", Map.of("email", "tester@kakao.com"),
                    "properties", Map.of("nickname", "테스터")
            );

            // when
            OAuthUserInfo userInfo = oAuthResponseFactory.createOAuthUserInfo("kakao", attributes);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("kakao");
                softly.assertThat(userInfo.getProviderId()).isEqualTo("1234567890");
                softly.assertThat(userInfo.getEmail()).isEqualTo("tester@kakao.com");
                softly.assertThat(userInfo.getName()).isEqualTo("테스터");
            });
        }

        @Test
        @DisplayName("kakao_account 자체가 없으면 NPE 대신 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void kakao_account_가_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "id", 1234567890L,
                    "properties", Map.of("nickname", "테스터")
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("kakao", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("email 동의를 하지 않아 kakao_account 에 email 이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void email_이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "id", 1234567890L,
                    "kakao_account", Map.of("has_email", false),
                    "properties", Map.of("nickname", "테스터")
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("kakao", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("kakao_account 가 객체가 아니면 캐스팅 예외 대신 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void kakao_account_가_객체가_아니면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "id", 1234567890L,
                    "kakao_account", "not-an-object",
                    "properties", Map.of("nickname", "테스터")
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("kakao", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("properties 에 nickname 이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void nickname_이_없으면_예외가_발생한다() {
            // given
            Map<String, Object> attributes = Map.of(
                    "id", 1234567890L,
                    "kakao_account", Map.of("email", "tester@kakao.com"),
                    "properties", Map.of()
            );

            // when & then
            assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("kakao", attributes))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }
    }

    @Test
    @DisplayName("지원하지 않는 provider 면 PROVIDER_INVALID 예외가 발생한다")
    void 지원하지_않는_provider_면_예외가_발생한다() {
        // given
        Map<String, Object> attributes = Map.of("id", "1");

        // when & then
        assertThatThrownBy(() -> oAuthResponseFactory.createOAuthUserInfo("samsung", attributes))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(PROVIDER_INVALID);
    }
}
