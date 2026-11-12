package gravit.code.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.auth.token.JwtProvider;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import jakarta.servlet.http.Cookie;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.Duration;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.REFRESH_TOKEN_EXPIRED;
import static gravit.code.global.exception.domain.CustomErrorCode.TOKEN_EMPTY;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.springframework.http.HttpHeaders.SET_COOKIE;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class AuthTokenControllerIntegrationTest {

    private static final String REISSUE_URI = "/api/v1/auth/reissue";
    private static final String LOGOUT_URI = "/api/v1/auth/logout";
    private static final String COOKIE_NAME = "refreshToken";
    private static final String REFRESH_TOKEN_KEY_PREFIX = "refreshToken:";
    private static final String CLIENT_CLAIM_KEY = "client";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AuthTokenProvider authTokenProvider;

    @Autowired
    private JwtProvider jwtProvider;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    private User user;
    private String refreshToken;

    @BeforeEach
    void setUp() {
        user = userFixture.일반_유저(1);
        RefreshToken issued = authTokenProvider.generateRefreshToken(user, LoginClient.WEB);
        refreshToken = issued.token();
    }

    private String 토큰_본문(String token) throws Exception {
        return objectMapper.writeValueAsString(Map.of("refreshToken", token));
    }

    private String 저장되지_않은_토큰() {
        return jwtProvider.generateToken(
                new Subject(user.getId().toString()),
                Map.of(CLIENT_CLAIM_KEY, LoginClient.WEB.name()),
                Duration.ofDays(1)
        );
    }

    private String 저장된_토큰() {
        return 저장된_토큰(LoginClient.WEB);
    }

    private String 저장된_토큰(LoginClient client) {
        return redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY_PREFIX + user.getId() + ":" + client.name());
    }

    @Nested
    @DisplayName("액세스 토큰을 재발급할 때")
    class Reissue {

        @Test
        void 쿠키의_리프레시_토큰으로_재발급한다() throws Exception {
            // when & then
            mockMvc.perform(post(REISSUE_URI)
                            .cookie(new Cookie(COOKIE_NAME, refreshToken)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty());
        }

        @Test
        void 쿠키가_없으면_본문의_리프레시_토큰으로_재발급한다() throws Exception {
            // when & then
            mockMvc.perform(post(REISSUE_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(토큰_본문(refreshToken)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty());
        }

        @Test
        void 쿠키와_본문이_모두_있으면_쿠키를_우선한다() throws Exception {
            // when & then
            mockMvc.perform(post(REISSUE_URI)
                            .cookie(new Cookie(COOKIE_NAME, refreshToken))
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(토큰_본문(저장되지_않은_토큰())))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty());
        }

        @Test
        void 쿠키와_본문이_모두_없으면_401을_돌려준다() throws Exception {
            // when & then
            mockMvc.perform(post(REISSUE_URI))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.error").value(TOKEN_EMPTY.getCode()));
        }

        @Test
        void 본문의_리프레시_토큰이_빈_값이면_401을_돌려준다() throws Exception {
            // when & then
            mockMvc.perform(post(REISSUE_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(토큰_본문(" ")))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.error").value(TOKEN_EMPTY.getCode()));
        }

        @Test
        void 저장된_값과_다른_리프레시_토큰이면_401을_돌려준다() throws Exception {
            // when & then
            mockMvc.perform(post(REISSUE_URI)
                            .cookie(new Cookie(COOKIE_NAME, 저장되지_않은_토큰())))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.error").value(REFRESH_TOKEN_EXPIRED.getCode()));
        }
    }

    @Nested
    @DisplayName("로그아웃할 때")
    class Logout {

        @Test
        void 쿠키의_리프레시_토큰을_무효화하고_만료_쿠키를_내려준다() throws Exception {
            // when
            MvcResult result = mockMvc.perform(post(LOGOUT_URI)
                            .cookie(new Cookie(COOKIE_NAME, refreshToken)))
                    .andExpect(status().isNoContent())
                    .andReturn();

            // then
            String setCookie = result.getResponse().getHeader(SET_COOKIE);

            assertSoftly(softly -> {
                softly.assertThat(저장된_토큰()).isNull();
                softly.assertThat(setCookie).startsWith(COOKIE_NAME + "=;");
                softly.assertThat(setCookie).contains("Max-Age=0", "Path=/api/v1/auth", "HttpOnly", "Secure");
            });
        }

        @Test
        void 쿠키가_없으면_본문의_리프레시_토큰을_무효화한다() throws Exception {
            // when
            mockMvc.perform(post(LOGOUT_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(토큰_본문(refreshToken)))
                    .andExpect(status().isNoContent());

            // then
            assertThat(저장된_토큰()).isNull();
        }

        @Test
        void 로그아웃한_리프레시_토큰으로는_재발급할_수_없다() throws Exception {
            // given
            mockMvc.perform(post(LOGOUT_URI)
                            .cookie(new Cookie(COOKIE_NAME, refreshToken)))
                    .andExpect(status().isNoContent());

            // when & then
            mockMvc.perform(post(REISSUE_URI)
                            .cookie(new Cookie(COOKIE_NAME, refreshToken)))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.error").value(REFRESH_TOKEN_EXPIRED.getCode()));
        }

        @Test
        void 토큰이_없어도_204와_만료_쿠키를_내려준다() throws Exception {
            // when
            MvcResult result = mockMvc.perform(post(LOGOUT_URI))
                    .andExpect(status().isNoContent())
                    .andReturn();

            // then
            assertThat(result.getResponse().getHeader(SET_COOKIE)).contains("Max-Age=0");
        }

        @Test
        void 위조된_토큰이어도_204와_만료_쿠키를_내려주고_저장된_토큰은_남긴다() throws Exception {
            // when
            MvcResult result = mockMvc.perform(post(LOGOUT_URI)
                            .cookie(new Cookie(COOKIE_NAME, "forged.refresh.token")))
                    .andExpect(status().isNoContent())
                    .andReturn();

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.getResponse().getHeader(SET_COOKIE)).contains("Max-Age=0");
                softly.assertThat(저장된_토큰()).isEqualTo(refreshToken);
            });
        }

        @Test
        void 저장된_값과_다른_토큰이면_저장된_토큰을_지우지_않는다() throws Exception {
            // when
            mockMvc.perform(post(LOGOUT_URI)
                            .cookie(new Cookie(COOKIE_NAME, 저장되지_않은_토큰())))
                    .andExpect(status().isNoContent());

            // then
            assertThat(저장된_토큰()).isEqualTo(refreshToken);
        }

        @Test
        void 웹에서_로그아웃해도_앱_토큰으로는_계속_재발급된다() throws Exception {
            // given
            String appRefreshToken = authTokenProvider.generateRefreshToken(user, LoginClient.ANDROID).token();

            // when
            mockMvc.perform(post(LOGOUT_URI)
                            .cookie(new Cookie(COOKIE_NAME, refreshToken)))
                    .andExpect(status().isNoContent());

            // then
            mockMvc.perform(post(REISSUE_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(토큰_본문(appRefreshToken)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isNotEmpty());

            assertSoftly(softly -> {
                softly.assertThat(저장된_토큰(LoginClient.WEB)).isNull();
                softly.assertThat(저장된_토큰(LoginClient.ANDROID)).isEqualTo(appRefreshToken);
            });
        }
    }
}
