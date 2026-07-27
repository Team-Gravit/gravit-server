package gravit.code.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.auth.dto.oauth.android.GoogleAndroidUserInfo;
import gravit.code.auth.infrastructure.client.OAuthHttpClientAdapter;
import gravit.code.auth.service.oauth.android.OAuthAndroidUserInfoService;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixtureBuilder;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_ACCESS_TOKEN_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_ID_TOKEN_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class OAuthAndroidControllerIntegrationTest {

    private static final String NAVER_LOGIN_URI = "/api/v1/oauth/android/naver";
    private static final String ID_TOKEN_LOGIN_URI = "/api/v1/oauth/android";
    private static final String NAVER_PROVIDER_ID = "naver_naver-provider-id";
    private static final String WHITELISTED_EMAIL = "test@test.com";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixtureBuilder userFixtureBuilder;

    @MockitoBean
    private OAuthHttpClientAdapter oAuthHttpClientAdapter;

    @MockitoBean
    private OAuthAndroidUserInfoService oAuthAndroidUserInfoService;

    @Nested
    @DisplayName("안드로이드 네이버 로그인을 요청할 때")
    class OAuthNaverLogin {

        @Test
        @DisplayName("액세스 토큰이 제공자 검증을 통과하면 토큰이 발급된다")
        void 네이버_액세스_토큰으로_로그인에_성공한다() throws Exception {
            // given
            제공자가_사용자_정보를_반환하도록_설정한다();
            String body = objectMapper.writeValueAsString(Map.of("accessToken", "valid-naver-access-token"));

            // when & then
            mockMvc.perform(post(NAVER_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty())
                    .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                    .andExpect(jsonPath("$.isOnboarded").value(false))
                    .andExpect(jsonPath("$.role").value("USER"));

            assertThat(userRepository.findByProviderId(NAVER_PROVIDER_ID)).isPresent();
        }

        @Test
        @DisplayName("사용자 정보를 직접 담아 보내면 액세스 토큰이 없어 400이 반환된다")
        void 사용자_정보를_직접_보내면_로그인에_실패한다() throws Exception {
            // given
            제공자가_사용자_정보를_반환하도록_설정한다();
            String body = objectMapper.writeValueAsString(Map.of(
                    "email", "attacker@naver.com",
                    "providerId", "naver-provider-id",
                    "nickname", "공격자"
            ));

            // when & then
            mockMvc.perform(post(NAVER_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isBadRequest());

            assertThat(userRepository.findByProviderId(NAVER_PROVIDER_ID)).isEmpty();
        }

        @Test
        @DisplayName("제공자가 액세스 토큰을 거부하면 회원가입도 토큰 발급도 되지 않는다")
        void 제공자_검증에_실패하면_토큰이_발급되지_않는다() throws Exception {
            // given
            when(oAuthHttpClientAdapter.getUserInfoWithAccessToken(any(), any()))
                    .thenThrow(new RestApiException(OAUTH_ACCESS_TOKEN_INVALID));
            String body = objectMapper.writeValueAsString(Map.of("accessToken", "forged-access-token"));

            // when & then
            mockMvc.perform(post(NAVER_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(OAUTH_ACCESS_TOKEN_INVALID.getCode()));

            assertThat(userRepository.findByProviderId(NAVER_PROVIDER_ID)).isEmpty();
        }

        @Test
        @DisplayName("요청 바디에 어드민 화이트리스트 이메일을 넣어도 제공자가 준 이메일로 판정되어 USER 로 가입된다")
        void 요청_바디의_이메일로는_어드민이_되지_않는다() throws Exception {
            // given
            제공자가_사용자_정보를_반환하도록_설정한다();
            String body = objectMapper.writeValueAsString(Map.of(
                    "accessToken", "valid-naver-access-token",
                    "email", WHITELISTED_EMAIL
            ));

            // when
            mockMvc.perform(post(NAVER_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.role").value("USER"));

            // then
            User created = userRepository.findByProviderId(NAVER_PROVIDER_ID).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(created.getRole()).isEqualTo(Role.USER);
                softly.assertThat(created.getEmail()).isEqualTo("tester@naver.com");
            });
        }

        @Test
        @DisplayName("이미 가입한 사용자가 다시 로그인하면 계정이 새로 생성되지 않는다")
        void 이미_가입한_사용자는_중복_생성되지_않는다() throws Exception {
            // given
            User existing = userFixtureBuilder.user()
                    .email("existing@naver.com")
                    .providerId(NAVER_PROVIDER_ID)
                    .nickname("기존유저")
                    .handle("existing_handle")
                    .create();
            제공자가_사용자_정보를_반환하도록_설정한다();
            String body = objectMapper.writeValueAsString(Map.of("accessToken", "valid-naver-access-token"));

            // when
            mockMvc.perform(post(NAVER_LOGIN_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isOk());

            // then
            assertSoftly(softly -> {
                softly.assertThat(userRepository.count()).isEqualTo(1);
                softly.assertThat(userRepository.findByProviderId(NAVER_PROVIDER_ID).orElseThrow().getId())
                        .isEqualTo(existing.getId());
            });
        }

        private void 제공자가_사용자_정보를_반환하도록_설정한다() {
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
        }
    }

    @Nested
    @DisplayName("안드로이드 구글, 카카오 로그인을 요청할 때")
    class OAuthIdTokenLogin {

        @Test
        @DisplayName("IdToken 검증을 통과하면 토큰이 발급된다")
        void 구글_id_token_으로_로그인에_성공한다() throws Exception {
            // given
            when(oAuthAndroidUserInfoService.parseIdToken(eq("google"), any()))
                    .thenReturn(new GoogleAndroidUserInfo(Map.of(
                            "sub", "google-provider-id",
                            "email", "tester@gmail.com",
                            "name", "구글테스터"
                    )));
            String body = objectMapper.writeValueAsString(Map.of("idToken", "valid-id-token"));

            // when & then
            mockMvc.perform(post(ID_TOKEN_LOGIN_URI)
                            .param("provider", "google")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty())
                    .andExpect(jsonPath("$.role").value("USER"));

            assertThat(userRepository.findByProviderId("google_google-provider-id")).isPresent();
        }

        @Test
        @DisplayName("IdToken 검증에 실패하면 회원가입도 토큰 발급도 되지 않는다")
        void id_token_검증에_실패하면_로그인에_실패한다() throws Exception {
            // given
            when(oAuthAndroidUserInfoService.parseIdToken(any(), any()))
                    .thenThrow(new RestApiException(OAUTH_ID_TOKEN_INVALID));
            String body = objectMapper.writeValueAsString(Map.of("idToken", "forged-id-token"));

            // when & then
            mockMvc.perform(post(ID_TOKEN_LOGIN_URI)
                            .param("provider", "google")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(OAUTH_ID_TOKEN_INVALID.getCode()));

            assertThat(userRepository.count()).isZero();
        }
    }
}
