package gravit.code.auth.service.oauth.app;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.AUDIENCE_IS_EMPTY;
import static gravit.code.global.exception.domain.CustomErrorCode.AUDIENCE_NOT_MATCHING;
import static gravit.code.global.exception.domain.CustomErrorCode.FAIL_DECODE_ID_TOKEN_TO_JWT;
import static gravit.code.global.exception.domain.CustomErrorCode.ISSUER_NOT_MATCHING;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_ID_TOKEN_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.Mockito.when;

@TCSpringBootTest
class OAuthAppUserInfoServiceIntegrationTest {

    private static final String ID_TOKEN = "app.id.token";
    private static final String GOOGLE_ISSUER = "https://accounts.google.com";
    private static final String KAKAO_ISSUER = "https://kauth.kakao.com";
    private static final String ANDROID_GOOGLE_CLIENT_ID = "test-android-google-client-id";
    private static final String IOS_GOOGLE_CLIENT_ID = "test-ios-google-client-id";
    private static final String ANDROID_KAKAO_CLIENT_ID = "test-android-kakao-client-id";
    private static final String IOS_KAKAO_CLIENT_ID = "test-ios-kakao-client-id";
    private static final String SUB = "provider-sub";
    private static final String EMAIL = "tester@gmail.com";

    @Autowired
    private OAuthAppUserInfoService oAuthAppUserInfoService;

    @MockitoBean(name = "google")
    private JwtDecoder googleJwtDecoder;

    @MockitoBean(name = "kakao")
    private JwtDecoder kakaoJwtDecoder;

    private void 구글이_IdToken을_해석하도록_설정한다(
            String issuer,
            List<String> audiences
    ) {
        when(googleJwtDecoder.decode(ID_TOKEN)).thenReturn(Jwt.withTokenValue(ID_TOKEN)
                .header("alg", "RS256")
                .issuer(issuer)
                .audience(audiences)
                .subject(SUB)
                .claim("email", EMAIL)
                .claim("name", "구글테스터")
                .build());
    }

    private void 카카오가_IdToken을_해석하도록_설정한다(String audience) {
        when(kakaoJwtDecoder.decode(ID_TOKEN)).thenReturn(Jwt.withTokenValue(ID_TOKEN)
                .header("alg", "RS256")
                .issuer(KAKAO_ISSUER)
                .audience(List.of(audience))
                .subject(SUB)
                .claim("email", EMAIL)
                .claim("nickname", "카카오테스터")
                .build());
    }

    @Nested
    @DisplayName("iOS IdToken을 해석할 때")
    class ParseIosIdToken {

        @Test
        void 구글_IdToken의_대상이_iOS_client_id이면_사용자_정보를_돌려준다() {
            // given
            구글이_IdToken을_해석하도록_설정한다(GOOGLE_ISSUER, List.of(IOS_GOOGLE_CLIENT_ID));

            // when
            OAuthUserInfo userInfo = oAuthAppUserInfoService.parseIosIdToken("google", ID_TOKEN);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("google");
                softly.assertThat(userInfo.getProviderId()).isEqualTo(SUB);
                softly.assertThat(userInfo.getEmail()).isEqualTo(EMAIL);
            });
        }

        @Test
        void 카카오_IdToken의_대상이_iOS_client_id이면_사용자_정보를_돌려준다() {
            // given
            카카오가_IdToken을_해석하도록_설정한다(IOS_KAKAO_CLIENT_ID);

            // when
            OAuthUserInfo userInfo = oAuthAppUserInfoService.parseIosIdToken("kakao", ID_TOKEN);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("kakao");
                softly.assertThat(userInfo.getProviderId()).isEqualTo(SUB);
                softly.assertThat(userInfo.getName()).isEqualTo("카카오테스터");
            });
        }

        @Test
        void IdToken의_대상이_안드로이드_client_id이면_예외를_던진다() {
            // given
            구글이_IdToken을_해석하도록_설정한다(GOOGLE_ISSUER, List.of(ANDROID_GOOGLE_CLIENT_ID));

            // when & then
            assertThatThrownBy(() -> oAuthAppUserInfoService.parseIosIdToken("google", ID_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(AUDIENCE_NOT_MATCHING);
        }

        @Test
        void 카카오_IdToken의_대상이_안드로이드_client_id이면_예외를_던진다() {
            // given
            카카오가_IdToken을_해석하도록_설정한다(ANDROID_KAKAO_CLIENT_ID);

            // when & then
            assertThatThrownBy(() -> oAuthAppUserInfoService.parseIosIdToken("kakao", ID_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(AUDIENCE_NOT_MATCHING);
        }

        @Test
        void 발급자가_다르면_예외를_던진다() {
            // given
            구글이_IdToken을_해석하도록_설정한다("https://evil.example.com", List.of(IOS_GOOGLE_CLIENT_ID));

            // when & then
            assertThatThrownBy(() -> oAuthAppUserInfoService.parseIosIdToken("google", ID_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(ISSUER_NOT_MATCHING);
        }

        @Test
        void 대상이_비어_있으면_예외를_던진다() {
            // given
            구글이_IdToken을_해석하도록_설정한다(GOOGLE_ISSUER, List.of());

            // when & then
            assertThatThrownBy(() -> oAuthAppUserInfoService.parseIosIdToken("google", ID_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(AUDIENCE_IS_EMPTY);
        }

        @Test
        void IdToken을_디코딩하지_못하면_예외를_던진다() {
            // given
            when(googleJwtDecoder.decode(ID_TOKEN)).thenThrow(new JwtException("invalid signature"));

            // when & then
            assertThatThrownBy(() -> oAuthAppUserInfoService.parseIosIdToken("google", ID_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(FAIL_DECODE_ID_TOKEN_TO_JWT);
        }

        @Test
        void IdToken_방식을_지원하지_않는_제공자면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> oAuthAppUserInfoService.parseIosIdToken("naver", ID_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROVIDER_INVALID);
        }

        @Test
        void IdToken이_비어_있으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> oAuthAppUserInfoService.parseIosIdToken("google", ""))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_ID_TOKEN_INVALID);
        }
    }

    @Nested
    @DisplayName("안드로이드 IdToken을 해석할 때")
    class ParseAndroidIdToken {

        @Test
        void 구글_IdToken의_대상이_안드로이드_client_id이면_사용자_정보를_돌려준다() {
            // given
            구글이_IdToken을_해석하도록_설정한다(GOOGLE_ISSUER, List.of(ANDROID_GOOGLE_CLIENT_ID));

            // when
            OAuthUserInfo userInfo = oAuthAppUserInfoService.parseAndroidIdToken("google", ID_TOKEN);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userInfo.getProvider()).isEqualTo("google");
                softly.assertThat(userInfo.getProviderId()).isEqualTo(SUB);
            });
        }

        @Test
        void IdToken의_대상이_iOS_client_id이면_예외를_던진다() {
            // given
            구글이_IdToken을_해석하도록_설정한다(GOOGLE_ISSUER, List.of(IOS_GOOGLE_CLIENT_ID));

            // when & then
            assertThatThrownBy(() -> oAuthAppUserInfoService.parseAndroidIdToken("google", ID_TOKEN))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(AUDIENCE_NOT_MATCHING);
        }
    }
}
