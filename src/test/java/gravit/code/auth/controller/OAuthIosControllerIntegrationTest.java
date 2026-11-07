package gravit.code.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.auth.domain.AppleClient;
import gravit.code.auth.domain.AppleCredential;
import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.dto.oauth.app.GoogleAppUserInfo;
import gravit.code.auth.infrastructure.client.AppleIdTokenDecoder;
import gravit.code.auth.infrastructure.client.OAuthHttpClientAdapter;
import gravit.code.auth.repository.AppleCredentialRepository;
import gravit.code.auth.service.oauth.app.OAuthAppUserInfoService;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixtureBuilder;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.AUDIENCE_NOT_MATCHING;
import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_PARAMS;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_ID_TOKEN_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_SERVER_ERROR;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class OAuthIosControllerIntegrationTest {

    private static final String APPLE_LOGIN_URI = "/api/v1/oauth/ios/apple";
    private static final String TOKEN_URI = "https://appleid.apple.com/auth/token";
    private static final String ISSUER = "https://appleid.apple.com";
    private static final String WEB_CLIENT_ID = "test.apple.client.id";
    private static final String IOS_BUNDLE_ID = "kr.inuappcenter.gravit.test";
    private static final String AUTH_CODE = "c1a2b3.0.apple-auth-code";
    private static final String ID_TOKEN = "apple.id.token";
    private static final String REFRESH_TOKEN = "r.apple-refresh-token";
    private static final String SUB = "001234.abcdef.0123";
    private static final String PROVIDER_ID = "apple_" + SUB;
    private static final String EMAIL = "relay@privaterelay.appleid.com";
    private static final String ID_TOKEN_LOGIN_URI = "/api/v1/oauth/ios";
    private static final String NAVER_LOGIN_URI = "/api/v1/oauth/ios/naver";
    private static final String ANDROID_ID_TOKEN_LOGIN_URI = "/api/v1/oauth/android";
    private static final String REISSUE_URI = "/api/v1/auth/reissue";
    private static final String REFRESH_TOKEN_KEY_PREFIX = "refreshToken:";
    private static final String GOOGLE_PROVIDER_ID = "google_google-provider-id";
    private static final String NAVER_PROVIDER_ID = "naver_naver-provider-id";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AppleCredentialRepository appleCredentialRepository;

    @Autowired
    private UserFixtureBuilder userFixtureBuilder;

    @MockitoBean
    private OAuthHttpClientAdapter oAuthHttpClientAdapter;

    @MockitoBean
    private AppleIdTokenDecoder appleIdTokenDecoder;

    @MockitoBean
    private OAuthAppUserInfoService oAuthAppUserInfoService;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    private void Apple이_토큰을_발급하도록_설정한다(String audience) {
        when(oAuthHttpClientAdapter.getAccessTokenResponse(eq(TOKEN_URI), any()))
                .thenReturn(Map.of(
                        "id_token", ID_TOKEN,
                        "refresh_token", REFRESH_TOKEN,
                        "access_token", "apple-access-token"
                ));
        when(appleIdTokenDecoder.decode(ID_TOKEN)).thenReturn(Jwt.withTokenValue(ID_TOKEN)
                .header("alg", "RS256")
                .issuer(ISSUER)
                .audience(List.of(audience))
                .subject(SUB)
                .claim("email", EMAIL)
                .build());
    }

    private String 인가_코드_요청() throws Exception {
        return objectMapper.writeValueAsString(Map.of("code", AUTH_CODE));
    }

    @Nested
    @DisplayName("iOS Apple 로그인을 요청할 때")
    class AppleLogin {

        @Test
        void 인가_코드_교환에_성공하면_가입시키고_토큰을_발급하며_Apple_토큰을_IOS_client로_보관한다() throws Exception {
            // given
            Apple이_토큰을_발급하도록_설정한다(IOS_BUNDLE_ID);

            // when
            mockMvc.perform(post(APPLE_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(인가_코드_요청()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty())
                    .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                    .andExpect(jsonPath("$.isOnboarded").value(false))
                    .andExpect(jsonPath("$.role").value("USER"));

            // then
            User user = userRepository.findByProviderId(PROVIDER_ID).orElseThrow();
            Optional<AppleCredential> credential = appleCredentialRepository.findByUserId(user.getId());

            assertSoftly(softly -> {
                softly.assertThat(user.getEmail()).isEqualTo(EMAIL);
                softly.assertThat(user.getNickname()).isEqualTo("애플사용자");
                softly.assertThat(credential).isPresent();
                softly.assertThat(credential.get().getClient()).isEqualTo(AppleClient.IOS);
            });
        }

        @Test
        void 웹으로_가입한_회원이_iOS로_로그인하면_같은_계정으로_로그인한다() throws Exception {
            // given
            User existing = userFixtureBuilder.user()
                    .email(EMAIL)
                    .providerId(PROVIDER_ID)
                    .nickname("애플사용자")
                    .handle("apple1")
                    .create();
            Apple이_토큰을_발급하도록_설정한다(IOS_BUNDLE_ID);

            // when
            mockMvc.perform(post(APPLE_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(인가_코드_요청()))
                    .andExpect(status().isOk());

            // then
            assertSoftly(softly -> {
                softly.assertThat(userRepository.count()).isEqualTo(1);
                softly.assertThat(userRepository.findByProviderId(PROVIDER_ID).orElseThrow().getId()).isEqualTo(existing.getId());
            });
        }

        @Test
        void code가_없으면_Apple에_요청하지_않고_400을_돌려준다() throws Exception {
            // given
            String body = objectMapper.writeValueAsString(Map.of());

            // when & then
            mockMvc.perform(post(APPLE_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(INVALID_PARAMS.getCode()));

            verifyNoInteractions(oAuthHttpClientAdapter);
            assertThat(userRepository.count()).isZero();
        }

        @Test
        void identityToken만_보내면_code가_없어_400을_돌려준다() throws Exception {
            // given
            String body = objectMapper.writeValueAsString(Map.of(
                    "identityToken", "sdk-identity-token",
                    "authorizationCode", AUTH_CODE,
                    "nonce", "client-nonce"
            ));

            // when & then
            mockMvc.perform(post(APPLE_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(INVALID_PARAMS.getCode()));

            verifyNoInteractions(oAuthHttpClientAdapter);
            assertThat(userRepository.count()).isZero();
        }

        @Test
        void Apple이_인가_코드_교환을_거부하면_가입도_토큰_발급도_되지_않는다() throws Exception {
            // given
            when(oAuthHttpClientAdapter.getAccessTokenResponse(eq(TOKEN_URI), any()))
                    .thenThrow(new RestApiException(OAUTH_SERVER_ERROR));

            // when & then
            mockMvc.perform(post(APPLE_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(인가_코드_요청()))
                    .andExpect(status().isBadGateway())
                    .andExpect(jsonPath("$.error").value(OAUTH_SERVER_ERROR.getCode()));

            assertThat(userRepository.count()).isZero();
        }

        @Test
        void id_token의_대상이_웹_Services_ID이면_가입도_토큰_발급도_되지_않는다() throws Exception {
            // given
            Apple이_토큰을_발급하도록_설정한다(WEB_CLIENT_ID);

            // when & then
            mockMvc.perform(post(APPLE_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(인가_코드_요청()))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(AUDIENCE_NOT_MATCHING.getCode()));

            assertSoftly(softly -> {
                softly.assertThat(userRepository.count()).isZero();
                softly.assertThat(appleCredentialRepository.findAll()).isEmpty();
            });
        }
    }

    private GoogleAppUserInfo 구글_사용자_정보() {
        return new GoogleAppUserInfo(Map.of(
                "sub", "google-provider-id",
                "email", "tester@gmail.com",
                "name", "구글테스터"
        ));
    }

    private String id_token_요청() throws Exception {
        return objectMapper.writeValueAsString(Map.of("idToken", "valid-id-token"));
    }

    private String 저장된_리프레시_토큰(
            long userId,
            LoginClient client
    ) {
        return redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY_PREFIX + userId + ":" + client.name());
    }

    private String 응답의_리프레시_토큰(String responseBody) throws Exception {
        return objectMapper.readTree(responseBody).get("refreshToken").asText();
    }

    @Nested
    @DisplayName("iOS 구글, 카카오 로그인을 요청할 때")
    class IdTokenLogin {

        @Test
        void IdToken_검증을_통과하면_토큰을_발급하고_리프레시_토큰을_IOS_칸에_저장한다() throws Exception {
            // given
            when(oAuthAppUserInfoService.parseIosIdToken(eq("google"), any())).thenReturn(구글_사용자_정보());

            // when
            String responseBody = mockMvc.perform(post(ID_TOKEN_LOGIN_URI)
                            .param("provider", "google")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(id_token_요청()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty())
                    .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                    .andExpect(jsonPath("$.role").value("USER"))
                    .andReturn().getResponse().getContentAsString();

            // then
            User user = userRepository.findByProviderId(GOOGLE_PROVIDER_ID).orElseThrow();
            String issuedRefreshToken = 응답의_리프레시_토큰(responseBody);

            assertSoftly(softly -> {
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.IOS)).isEqualTo(issuedRefreshToken);
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.ANDROID)).isNull();
            });
        }

        @Test
        void iOS_검증_설정으로_IdToken을_검증하고_안드로이드_검증은_호출하지_않는다() throws Exception {
            // given
            when(oAuthAppUserInfoService.parseIosIdToken(eq("google"), any())).thenReturn(구글_사용자_정보());

            // when
            mockMvc.perform(post(ID_TOKEN_LOGIN_URI)
                            .param("provider", "google")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(id_token_요청()))
                    .andExpect(status().isOk());

            // then
            verify(oAuthAppUserInfoService).parseIosIdToken("google", "valid-id-token");
            verify(oAuthAppUserInfoService, never()).parseAndroidIdToken(any(), any());
        }

        @Test
        void IdToken_검증에_실패하면_가입도_토큰_발급도_되지_않는다() throws Exception {
            // given
            when(oAuthAppUserInfoService.parseIosIdToken(any(), any()))
                    .thenThrow(new RestApiException(OAUTH_ID_TOKEN_INVALID));

            // when & then
            mockMvc.perform(post(ID_TOKEN_LOGIN_URI)
                            .param("provider", "google")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(id_token_요청()))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(OAUTH_ID_TOKEN_INVALID.getCode()));

            assertThat(userRepository.count()).isZero();
        }

        @Test
        void 같은_사용자가_안드로이드와_iOS로_로그인하면_두_리프레시_토큰_모두로_재발급할_수_있다() throws Exception {
            // given
            when(oAuthAppUserInfoService.parseAndroidIdToken(eq("google"), any())).thenReturn(구글_사용자_정보());
            when(oAuthAppUserInfoService.parseIosIdToken(eq("google"), any())).thenReturn(구글_사용자_정보());

            String androidResponse = mockMvc.perform(post(ANDROID_ID_TOKEN_LOGIN_URI)
                            .param("provider", "google")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(id_token_요청()))
                    .andExpect(status().isOk())
                    .andReturn().getResponse().getContentAsString();

            // when
            String iosResponse = mockMvc.perform(post(ID_TOKEN_LOGIN_URI)
                            .param("provider", "google")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(id_token_요청()))
                    .andExpect(status().isOk())
                    .andReturn().getResponse().getContentAsString();

            // then
            for (String refreshToken : List.of(응답의_리프레시_토큰(androidResponse), 응답의_리프레시_토큰(iosResponse))) {
                mockMvc.perform(post(REISSUE_URI)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(Map.of("refreshToken", refreshToken))))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.accessToken").isNotEmpty());
            }
            assertThat(userRepository.count()).isEqualTo(1);
        }
    }

    @Nested
    @DisplayName("iOS 네이버 로그인을 요청할 때")
    class NaverLogin {

        @Test
        void 액세스_토큰이_제공자_검증을_통과하면_리프레시_토큰을_IOS_칸에_저장한다() throws Exception {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenReturn(Map.of(
                            "resultcode", "00",
                            "message", "success",
                            "response", Map.of(
                                    "id", "naver-provider-id",
                                    "email", "tester@naver.com",
                                    "name", "테스터"
                            )
                    ));
            String body = objectMapper.writeValueAsString(Map.of("accessToken", "valid-naver-access-token"));

            // when
            String responseBody = mockMvc.perform(post(NAVER_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty())
                    .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                    .andReturn().getResponse().getContentAsString();

            // then
            User user = userRepository.findByProviderId(NAVER_PROVIDER_ID).orElseThrow();
            String issuedRefreshToken = 응답의_리프레시_토큰(responseBody);

            assertSoftly(softly -> {
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.IOS)).isEqualTo(issuedRefreshToken);
                softly.assertThat(저장된_리프레시_토큰(user.getId(), LoginClient.ANDROID)).isNull();
            });
        }

        @Test
        void 액세스_토큰이_없으면_제공자에_요청하지_않고_400을_돌려준다() throws Exception {
            // given
            String body = objectMapper.writeValueAsString(Map.of());

            // when & then
            mockMvc.perform(post(NAVER_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(INVALID_PARAMS.getCode()));

            verifyNoInteractions(oAuthHttpClientAdapter);
            assertThat(userRepository.count()).isZero();
        }
    }
}
