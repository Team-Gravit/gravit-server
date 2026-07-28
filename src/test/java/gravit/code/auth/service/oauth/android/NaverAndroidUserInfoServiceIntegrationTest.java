package gravit.code.auth.service.oauth.android;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.infrastructure.client.OAuthHttpClientAdapter;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_ACCESS_TOKEN_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_USER_INFO_INVALID;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@TCSpringBootTest
class NaverAndroidUserInfoServiceIntegrationTest {

    private static final String NAVER_USER_INFO_URI = "https://openapi.naver.com/v1/nid/me";
    private static final String VALID_ACCESS_TOKEN = "valid-naver-access-token";

    @Autowired
    private NaverAndroidUserInfoService naverAndroidUserInfoService;

    @MockitoBean
    private OAuthHttpClientAdapter oAuthHttpClientAdapter;

    @Nested
    @DisplayName("네이버 액세스 토큰으로 사용자 정보를 조회할 때")
    class GetUserInfo {

        @Test
        @DisplayName("제공자가 반환한 사용자 정보가 OAuthUserInfo 로 매핑된다")
        void 유효한_액세스_토큰으로_네이버_사용자_정보를_조회한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(eq(NAVER_USER_INFO_URI), eq(VALID_ACCESS_TOKEN)))
                    .thenReturn(Map.of(
                            "resultcode", "00",
                            "message", "success",
                            "response", Map.of(
                                    "id", "naver-provider-id",
                                    "email", "tester@naver.com",
                                    "name", "테스터"
                            )
                    ));

            // when
            OAuthUserInfo userInfo = naverAndroidUserInfoService.getUserInfo(VALID_ACCESS_TOKEN);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("naver");
                softly.assertThat(userInfo.getProviderId()).isEqualTo("naver-provider-id");
                softly.assertThat(userInfo.getEmail()).isEqualTo("tester@naver.com");
                softly.assertThat(userInfo.getName()).isEqualTo("테스터");
            });
        }

        @ParameterizedTest
        @NullSource
        @ValueSource(strings = {"", "   "})
        @DisplayName("액세스 토큰이 없으면 OAUTH_ACCESS_TOKEN_INVALID 예외가 발생한다")
        void 액세스_토큰이_비어있으면_예외가_발생한다(String accessToken) {
            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo(accessToken))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_ACCESS_TOKEN_INVALID);
        }

        @Test
        @DisplayName("제공자가 실패 resultcode 를 반환하면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 제공자가_실패_결과를_반환하면_예외가_발생한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenReturn(Map.of(
                            "resultcode", "024",
                            "message", "Authentication failed"
                    ));

            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo(VALID_ACCESS_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("resultcode 자체가 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 결과_코드가_없으면_예외가_발생한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenReturn(Map.of("message", "unknown"));

            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo(VALID_ACCESS_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("성공 resultcode 여도 response 가 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 사용자_정보_본문이_없으면_예외가_발생한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenReturn(Map.of(
                            "resultcode", "00",
                            "message", "success"
                    ));

            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo(VALID_ACCESS_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("response 가 객체가 아니면 캐스팅 예외 대신 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 사용자_정보_본문이_객체가_아니면_예외가_발생한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenReturn(Map.of(
                            "resultcode", "00",
                            "response", "not-an-object"
                    ));

            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo(VALID_ACCESS_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("response 에 id 가 없으면 NPE 대신 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 사용자_식별자가_없으면_예외가_발생한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenReturn(Map.of(
                            "resultcode", "00",
                            "response", Map.of(
                                    "email", "tester@naver.com",
                                    "name", "테스터"
                            )
                    ));

            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo(VALID_ACCESS_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("동의 항목 미동의로 response 에 email 이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 이메일이_없으면_예외가_발생한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenReturn(Map.of(
                            "resultcode", "00",
                            "response", Map.of(
                                    "id", "naver-provider-id",
                                    "name", "테스터"
                            )
                    ));

            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo(VALID_ACCESS_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("동의 항목 미동의로 response 에 name 이 없으면 OAUTH_USER_INFO_INVALID 예외가 발생한다")
        void 이름이_없으면_예외가_발생한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenReturn(Map.of(
                            "resultcode", "00",
                            "response", Map.of(
                                    "id", "naver-provider-id",
                                    "email", "tester@naver.com"
                            )
                    ));

            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo(VALID_ACCESS_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }

        @Test
        @DisplayName("제공자가 액세스 토큰을 거부하면 예외가 그대로 전파된다")
        void 제공자가_액세스_토큰을_거부하면_예외가_발생한다() {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenThrow(new RestApiException(OAUTH_ACCESS_TOKEN_INVALID));

            // when & then
            assertThatThrownBy(() -> naverAndroidUserInfoService.getUserInfo("expired-access-token"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_ACCESS_TOKEN_INVALID);
        }
    }
}
