package gravit.code.auth.service.oauth.apple;

import gravit.code.auth.dto.internal.AppleLoginDto;
import gravit.code.auth.infrastructure.client.AppleIdTokenDecoder;
import gravit.code.auth.infrastructure.client.OAuthHttpClientAdapter;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.util.MultiValueMap;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.AUDIENCE_IS_EMPTY;
import static gravit.code.global.exception.domain.CustomErrorCode.AUDIENCE_NOT_MATCHING;
import static gravit.code.global.exception.domain.CustomErrorCode.AUTH_CODE_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;
import static gravit.code.global.exception.domain.CustomErrorCode.ISSUER_NOT_MATCHING;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_ID_TOKEN_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_USER_INFO_INVALID;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@TCSpringBootTest
class AppleOAuthServiceIntegrationTest {

    private static final String ISSUER = "https://appleid.apple.com";
    private static final String TOKEN_URI = "https://appleid.apple.com/auth/token";
    private static final String REVOKE_URI = "https://appleid.apple.com/auth/revoke";
    private static final String CLIENT_ID = "test.apple.client.id";
    private static final String AUTH_CODE = "c1a2b3.0.apple-auth-code";
    private static final String DEST = "dev";
    private static final String DEV_REDIRECT_URI = "https://dev.gravit.inuappcenter.kr/login/oauth2/code/apple";
    private static final String ID_TOKEN = "apple.id.token";
    private static final String REFRESH_TOKEN = "r.apple-refresh-token";
    private static final String SUB = "001234.abcdef.0123";
    private static final String EMAIL = "relay@privaterelay.appleid.com";

    @Autowired
    private AppleOAuthService appleOAuthService;

    @MockitoBean
    private OAuthHttpClientAdapter oAuthHttpClientAdapter;

    @MockitoBean
    private AppleIdTokenDecoder appleIdTokenDecoder;

    private void 토큰_응답(Map<String, Object> response) {
        when(oAuthHttpClientAdapter.getAccessTokenResponse(eq(TOKEN_URI), any())).thenReturn(response);
    }

    private Map<String, Object> 정상_토큰_응답() {
        return Map.of(
                "id_token", ID_TOKEN,
                "refresh_token", REFRESH_TOKEN,
                "access_token", "apple-access-token"
        );
    }

    private Jwt.Builder 정상_id_토큰() {
        return Jwt.withTokenValue(ID_TOKEN)
                .header("alg", "RS256")
                .issuer(ISSUER)
                .audience(List.of(CLIENT_ID))
                .subject(SUB)
                .claim("email", EMAIL);
    }

    @SuppressWarnings("unchecked")
    private MultiValueMap<String, String> 보낸_토큰_요청() {
        ArgumentCaptor<MultiValueMap<String, String>> captor = ArgumentCaptor.forClass(MultiValueMap.class);
        verify(oAuthHttpClientAdapter).getAccessTokenResponse(eq(TOKEN_URI), captor.capture());
        return captor.getValue();
    }

    @Nested
    @DisplayName("인가 코드로 Apple 사용자 정보를 가져올 때")
    class GetUserInfo {

        @Test
        void id_token의_sub와_email로_사용자_정보를_만들고_refresh_token을_함께_돌려준다() {
            // given
            토큰_응답(정상_토큰_응답());
            when(appleIdTokenDecoder.decode(ID_TOKEN)).thenReturn(정상_id_토큰().build());

            // when
            AppleLoginDto result = appleOAuthService.getUserInfo(AUTH_CODE, DEST);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.userInfo().getProvider()).isEqualTo("apple");
                softly.assertThat(result.userInfo().getProviderId()).isEqualTo(SUB);
                softly.assertThat(result.userInfo().getEmail()).isEqualTo(EMAIL);
                softly.assertThat(result.userInfo().getName()).isEqualTo("애플사용자");
                softly.assertThat(result.refreshToken()).isEqualTo(REFRESH_TOKEN);
            });
        }

        @Test
        void dest에_맞는_redirect_uri와_서명한_client_secret으로_토큰을_요청한다() {
            // given
            토큰_응답(정상_토큰_응답());
            when(appleIdTokenDecoder.decode(ID_TOKEN)).thenReturn(정상_id_토큰().build());

            // when
            appleOAuthService.getUserInfo(AUTH_CODE, DEST);

            // then
            MultiValueMap<String, String> request = 보낸_토큰_요청();

            assertSoftly(softly -> {
                softly.assertThat(request.getFirst("grant_type")).isEqualTo("authorization_code");
                softly.assertThat(request.getFirst("client_id")).isEqualTo(CLIENT_ID);
                softly.assertThat(request.getFirst("redirect_uri")).isEqualTo(DEV_REDIRECT_URI);
                softly.assertThat(request.getFirst("code")).isEqualTo(AUTH_CODE);
                softly.assertThat(request.getFirst("client_secret")).matches("[\\w-]+\\.[\\w-]+\\.[\\w-]+");
            });
        }

        @Test
        void refresh_token이_없는_응답이면_refresh_token을_비워_돌려준다() {
            // given
            Map<String, Object> response = new HashMap<>(정상_토큰_응답());
            response.remove("refresh_token");
            토큰_응답(response);
            when(appleIdTokenDecoder.decode(ID_TOKEN)).thenReturn(정상_id_토큰().build());

            // when
            AppleLoginDto result = appleOAuthService.getUserInfo(AUTH_CODE, DEST);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.userInfo().getProviderId()).isEqualTo(SUB);
                softly.assertThat(result.refreshToken()).isNull();
            });
        }

        @Test
        void 인가_코드가_비어_있으면_Apple에_요청하지_않고_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> appleOAuthService.getUserInfo(" ", DEST))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(AUTH_CODE_INVALID);

            verifyNoInteractions(oAuthHttpClientAdapter);
        }

        @Test
        void 등록되지_않은_dest이면_Apple에_요청하지_않고_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> appleOAuthService.getUserInfo(AUTH_CODE, "unknown"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(DEST_NOT_VALID);

            verifyNoInteractions(oAuthHttpClientAdapter);
        }

        @Test
        void 토큰_응답에_id_token이_없으면_예외를_던진다() {
            // given
            토큰_응답(Map.of("refresh_token", REFRESH_TOKEN));

            // when & then
            assertThatThrownBy(() -> appleOAuthService.getUserInfo(AUTH_CODE, DEST))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_ID_TOKEN_INVALID);
        }

        @Test
        void id_token의_발급자가_Apple이_아니면_예외를_던진다() {
            // given
            토큰_응답(정상_토큰_응답());
            when(appleIdTokenDecoder.decode(ID_TOKEN)).thenReturn(정상_id_토큰().issuer("https://evil.example.com").build());

            // when & then
            assertThatThrownBy(() -> appleOAuthService.getUserInfo(AUTH_CODE, DEST))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(ISSUER_NOT_MATCHING);
        }

        @Test
        void id_token에_대상이_없으면_예외를_던진다() {
            // given
            토큰_응답(정상_토큰_응답());
            Jwt idToken = 정상_id_토큰().claims(claims -> claims.remove("aud")).build();
            when(appleIdTokenDecoder.decode(ID_TOKEN)).thenReturn(idToken);

            // when & then
            assertThatThrownBy(() -> appleOAuthService.getUserInfo(AUTH_CODE, DEST))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(AUDIENCE_IS_EMPTY);
        }

        @Test
        void id_token의_대상이_Gravit이_아니면_예외를_던진다() {
            // given
            토큰_응답(정상_토큰_응답());
            when(appleIdTokenDecoder.decode(ID_TOKEN)).thenReturn(정상_id_토큰().audience(List.of("other.client.id")).build());

            // when & then
            assertThatThrownBy(() -> appleOAuthService.getUserInfo(AUTH_CODE, DEST))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(AUDIENCE_NOT_MATCHING);
        }

        @Test
        void id_token에_이메일이_없으면_예외를_던진다() {
            // given
            토큰_응답(정상_토큰_응답());
            Jwt idToken = 정상_id_토큰().claims(claims -> claims.remove("email")).build();
            when(appleIdTokenDecoder.decode(ID_TOKEN)).thenReturn(idToken);

            // when & then
            assertThatThrownBy(() -> appleOAuthService.getUserInfo(AUTH_CODE, DEST))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_USER_INFO_INVALID);
        }
    }

    @Nested
    @DisplayName("Apple 토큰 철회를 요청할 때")
    class RevokeRefreshToken {

        @Test
        void refresh_token과_서명한_client_secret으로_철회를_요청한다() {
            // when
            appleOAuthService.revokeRefreshToken(REFRESH_TOKEN);

            // then
            @SuppressWarnings("unchecked")
            ArgumentCaptor<MultiValueMap<String, String>> captor = ArgumentCaptor.forClass(MultiValueMap.class);
            verify(oAuthHttpClientAdapter).revokeToken(eq(REVOKE_URI), captor.capture());
            MultiValueMap<String, String> request = captor.getValue();

            assertSoftly(softly -> {
                softly.assertThat(request.getFirst("client_id")).isEqualTo(CLIENT_ID);
                softly.assertThat(request.getFirst("token")).isEqualTo(REFRESH_TOKEN);
                softly.assertThat(request.getFirst("token_type_hint")).isEqualTo("refresh_token");
                softly.assertThat(request.getFirst("client_secret")).matches("[\\w-]+\\.[\\w-]+\\.[\\w-]+");
            });
        }
    }
}
