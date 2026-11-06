package gravit.code.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.infrastructure.client.AppleIdTokenDecoder;
import gravit.code.auth.infrastructure.client.OAuthHttpClientAdapter;
import gravit.code.auth.service.oauth.OAuthStateService;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.util.MultiValueMap;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;
import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_PARAMS;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_STATE_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.http.HttpHeaders.ORIGIN;
import static org.springframework.http.HttpHeaders.SET_COOKIE;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class OAuthControllerIntegrationTest {

    private static final String PROD_ORIGIN = "https://gravit.inuappcenter.kr";
    private static final String DEV_HOST = "https://dev.gravit.inuappcenter.kr";
    private static final String STATE_KEY_PREFIX = "oauthState:";
    private static final String REFRESH_TOKEN_KEY_PREFIX = "refreshToken:";
    private static final String COOKIE_NAME = "refreshToken";

    private static final String GOOGLE_TOKEN_URI = "https://oauth2.googleapis.com/token";
    private static final String GOOGLE_USER_INFO_URI = "https://www.googleapis.com/oauth2/v3/userinfo";
    private static final String GOOGLE_ACCESS_TOKEN = "google-access-token";
    private static final String GOOGLE_SUB = "1029384756";
    private static final String GOOGLE_EMAIL = "learner@gmail.com";

    private static final String APPLE_TOKEN_URI = "https://appleid.apple.com/auth/token";
    private static final String APPLE_ISSUER = "https://appleid.apple.com";
    private static final String APPLE_WEB_CLIENT_ID = "test.apple.client.id";
    private static final String APPLE_ID_TOKEN = "apple.id.token";
    private static final String APPLE_SUB = "001234.abcdef.0123";

    private static final String AUTH_CODE = "auth-code";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private OAuthStateService oAuthStateService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @MockitoBean
    private OAuthHttpClientAdapter oAuthHttpClientAdapter;

    @MockitoBean
    private AppleIdTokenDecoder appleIdTokenDecoder;

    private void 구글이_사용자_정보를_돌려주도록_설정한다() {
        when(oAuthHttpClientAdapter.getAccessTokenResponse(eq(GOOGLE_TOKEN_URI), any()))
                .thenReturn(Map.of("access_token", GOOGLE_ACCESS_TOKEN));
        when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(GOOGLE_USER_INFO_URI, GOOGLE_ACCESS_TOKEN))
                .thenReturn(Map.of(
                        "sub", GOOGLE_SUB,
                        "email", GOOGLE_EMAIL,
                        "name", "구글학습자"
                ));
    }

    private void Apple이_토큰을_발급하도록_설정한다() {
        when(oAuthHttpClientAdapter.getAccessTokenResponse(eq(APPLE_TOKEN_URI), any()))
                .thenReturn(Map.of(
                        "id_token", APPLE_ID_TOKEN,
                        "refresh_token", "r.apple-refresh-token"
                ));
        when(appleIdTokenDecoder.decode(APPLE_ID_TOKEN)).thenReturn(Jwt.withTokenValue(APPLE_ID_TOKEN)
                .header("alg", "RS256")
                .issuer(APPLE_ISSUER)
                .audience(List.of(APPLE_WEB_CLIENT_ID))
                .subject(APPLE_SUB)
                .claim("email", "relay@privaterelay.appleid.com")
                .build());
    }

    private String 로그인_요청(String state) throws Exception {
        return objectMapper.writeValueAsString(Map.of("code", AUTH_CODE, "state", state));
    }

    @SuppressWarnings("unchecked")
    private MultiValueMap<String, String> 보낸_토큰_요청(String tokenUri) {
        ArgumentCaptor<MultiValueMap<String, String>> captor = ArgumentCaptor.forClass(MultiValueMap.class);
        verify(oAuthHttpClientAdapter).getAccessTokenResponse(eq(tokenUri), captor.capture());
        return captor.getValue();
    }

    private String 저장된_리프레시_토큰(String providerId) {
        User user = userRepository.findByProviderId(providerId).orElseThrow();
        return redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY_PREFIX + user.getId() + ":" + LoginClient.WEB.name());
    }

    @Nested
    @DisplayName("로그인 URL을 만들 때")
    class AuthorizeUrl {

        @Test
        void Origin으로_redirect_uri를_정하고_발급한_state를_URL과_응답에_함께_담는다() throws Exception {
            // when
            MvcResult result = mockMvc.perform(get("/api/v1/oauth/login-url/google")
                            .header(ORIGIN, PROD_ORIGIN))
                    .andExpect(status().isOk())
                    .andReturn();

            // then
            String state = objectMapper.readTree(result.getResponse().getContentAsString()).get("state").asText();
            String loginUrl = objectMapper.readTree(result.getResponse().getContentAsString()).get("loginUrl").asText();
            UriComponents uri = UriComponentsBuilder.fromUriString(loginUrl).build();

            assertSoftly(softly -> {
                softly.assertThat(loginUrl).startsWith("https://accounts.google.com/o/oauth2/v2/auth");
                softly.assertThat(uri.getQueryParams().getFirst("redirect_uri")).isEqualTo(PROD_ORIGIN + "/login/oauth2/code/google");
                softly.assertThat(uri.getQueryParams().getFirst("state")).isEqualTo(state);
                softly.assertThat(redisTemplate.opsForValue().get(STATE_KEY_PREFIX + state)).isEqualTo("google");
            });
        }

        @Test
        void Origin이_없으면_dest로_redirect_uri를_정한다() throws Exception {
            // when
            MvcResult result = mockMvc.perform(get("/api/v1/oauth/login-url/kakao")
                            .param("dest", "dev"))
                    .andExpect(status().isOk())
                    .andReturn();

            // then
            String loginUrl = objectMapper.readTree(result.getResponse().getContentAsString()).get("loginUrl").asText();
            UriComponents uri = UriComponentsBuilder.fromUriString(loginUrl).build();

            assertThat(uri.getQueryParams().getFirst("redirect_uri")).isEqualTo(DEV_HOST + "/login/oauth2/code/kakao");
        }

        @Test
        void apple이면_웹_Services_ID와_form_post로_Apple_인가_URL을_만든다() throws Exception {
            // when
            MvcResult result = mockMvc.perform(get("/api/v1/oauth/login-url/apple")
                            .header(ORIGIN, PROD_ORIGIN))
                    .andExpect(status().isOk())
                    .andReturn();

            // then
            String state = objectMapper.readTree(result.getResponse().getContentAsString()).get("state").asText();
            String loginUrl = objectMapper.readTree(result.getResponse().getContentAsString()).get("loginUrl").asText();
            MultiValueMap<String, String> params = UriComponentsBuilder.fromUriString(loginUrl).build().getQueryParams();

            assertSoftly(softly -> {
                softly.assertThat(loginUrl).startsWith("https://appleid.apple.com/auth/authorize");
                softly.assertThat(params.getFirst("client_id")).isEqualTo(APPLE_WEB_CLIENT_ID);
                softly.assertThat(params.getFirst("redirect_uri")).isEqualTo(PROD_ORIGIN + "/login/oauth2/code/apple");
                softly.assertThat(params.getFirst("response_type")).isEqualTo("code");
                softly.assertThat(params.getFirst("scope")).isEqualTo("email");
                softly.assertThat(params.getFirst("response_mode")).isEqualTo("form_post");
                softly.assertThat(params.getFirst("state")).isEqualTo(state);
                softly.assertThat(redisTemplate.opsForValue().get(STATE_KEY_PREFIX + state)).isEqualTo("apple");
            });
        }

        @Test
        void Origin과_dest가_모두_없으면_400을_돌려준다() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/oauth/login-url/google"))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(DEST_NOT_VALID.getCode()));
        }
    }

    @Nested
    @DisplayName("웹 소셜 로그인을 요청할 때")
    class OauthLogin {

        @Test
        void 성공하면_리프레시_토큰을_HttpOnly_쿠키로만_내려준다() throws Exception {
            // given
            구글이_사용자_정보를_돌려주도록_설정한다();
            String state = oAuthStateService.issue("google");

            // when
            MvcResult result = mockMvc.perform(post("/api/v1/oauth/google")
                            .header(ORIGIN, PROD_ORIGIN)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(로그인_요청(state)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty())
                    .andExpect(jsonPath("$.isOnboarded").value(false))
                    .andExpect(jsonPath("$.role").value("USER"))
                    .andExpect(jsonPath("$.refreshToken").doesNotExist())
                    .andReturn();

            // then
            String setCookie = result.getResponse().getHeader(SET_COOKIE);
            String storedRefreshToken = 저장된_리프레시_토큰("google_" + GOOGLE_SUB);

            assertSoftly(softly -> {
                softly.assertThat(setCookie).startsWith(COOKIE_NAME + "=" + storedRefreshToken + ";");
                softly.assertThat(setCookie).contains("Path=/api/v1/auth", "HttpOnly", "Secure", "SameSite=Lax", "Max-Age=1209600");
                softly.assertThat(setCookie).doesNotContain("Domain=");
            });
        }

        @Test
        void Origin으로_정한_redirect_uri로_제공자에_토큰을_요청한다() throws Exception {
            // given
            구글이_사용자_정보를_돌려주도록_설정한다();
            String state = oAuthStateService.issue("google");

            // when
            mockMvc.perform(post("/api/v1/oauth/google")
                            .header(ORIGIN, PROD_ORIGIN)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(로그인_요청(state)))
                    .andExpect(status().isOk());

            // then
            assertThat(보낸_토큰_요청(GOOGLE_TOKEN_URI).getFirst("redirect_uri"))
                    .isEqualTo(PROD_ORIGIN + "/login/oauth2/code/google");
        }

        @Test
        void state가_없으면_제공자에_요청하지_않고_400을_돌려준다() throws Exception {
            // given
            String body = objectMapper.writeValueAsString(Map.of("code", AUTH_CODE));

            // when & then
            mockMvc.perform(post("/api/v1/oauth/google")
                            .header(ORIGIN, PROD_ORIGIN)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(INVALID_PARAMS.getCode()));

            verifyNoInteractions(oAuthHttpClientAdapter);
        }

        @Test
        void 서버가_발급하지_않은_state면_제공자에_요청하지_않고_가입시키지_않는다() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/oauth/google")
                            .header(ORIGIN, PROD_ORIGIN)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(로그인_요청("not-issued-state")))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(OAUTH_STATE_INVALID.getCode()));

            verifyNoInteractions(oAuthHttpClientAdapter);
            assertThat(userRepository.count()).isZero();
        }

        @Test
        void 이미_쓴_state로_다시_요청하면_400을_돌려준다() throws Exception {
            // given
            구글이_사용자_정보를_돌려주도록_설정한다();
            String state = oAuthStateService.issue("google");
            mockMvc.perform(post("/api/v1/oauth/google")
                            .header(ORIGIN, PROD_ORIGIN)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(로그인_요청(state)))
                    .andExpect(status().isOk());

            // when & then
            mockMvc.perform(post("/api/v1/oauth/google")
                            .header(ORIGIN, PROD_ORIGIN)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(로그인_요청(state)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(OAUTH_STATE_INVALID.getCode()));
        }
    }

    @Nested
    @DisplayName("웹 Apple 로그인을 요청할 때")
    class AppleLogin {

        @Test
        void 성공하면_리프레시_토큰을_HttpOnly_쿠키로만_내려준다() throws Exception {
            // given
            Apple이_토큰을_발급하도록_설정한다();
            String state = oAuthStateService.issue("apple");

            // when
            MvcResult result = mockMvc.perform(post("/api/v1/oauth/apple")
                            .header(ORIGIN, PROD_ORIGIN)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(로그인_요청(state)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty())
                    .andExpect(jsonPath("$.refreshToken").doesNotExist())
                    .andReturn();

            // then
            String setCookie = result.getResponse().getHeader(SET_COOKIE);
            String storedRefreshToken = 저장된_리프레시_토큰("apple_" + APPLE_SUB);

            assertSoftly(softly -> {
                softly.assertThat(setCookie).startsWith(COOKIE_NAME + "=" + storedRefreshToken + ";");
                softly.assertThat(setCookie).contains("Path=/api/v1/auth", "HttpOnly", "Secure", "SameSite=Lax");
                softly.assertThat(보낸_토큰_요청(APPLE_TOKEN_URI).getFirst("redirect_uri"))
                        .isEqualTo(PROD_ORIGIN + "/login/oauth2/code/apple");
            });
        }

        @Test
        void 구글용으로_발급한_state면_Apple에_요청하지_않고_400을_돌려준다() throws Exception {
            // given
            String googleState = oAuthStateService.issue("google");

            // when & then
            mockMvc.perform(post("/api/v1/oauth/apple")
                            .header(ORIGIN, PROD_ORIGIN)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(로그인_요청(googleState)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(OAUTH_STATE_INVALID.getCode()));

            verifyNoInteractions(oAuthHttpClientAdapter);
        }
    }
}
