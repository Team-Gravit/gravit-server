package gravit.code.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.auth.domain.AppleClient;
import gravit.code.auth.domain.AppleCredential;
import gravit.code.auth.infrastructure.client.AppleIdTokenDecoder;
import gravit.code.auth.infrastructure.client.OAuthHttpClientAdapter;
import gravit.code.auth.repository.AppleCredentialRepository;
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
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.AUDIENCE_NOT_MATCHING;
import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_PARAMS;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_SERVER_ERROR;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
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
}
