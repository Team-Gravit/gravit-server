package gravit.code.security.filter;

import gravit.code.auth.domain.LoginUser;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.auth.token.JwtProvider;
import gravit.code.security.exception.CustomAuthenticationEntryPoint;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;

import java.time.Duration;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.TOKEN_EXPIRED;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class JwtAuthFilterIntegrationTest {

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String BEARER_PREFIX = "Bearer ";
    private static final String USER_ID_ATTRIBUTE = "user_id";

    private static final String PROTECTED_URI = "/api/v1/users/me";
    private static final String EXCLUDED_URI = "/api/v1/version";

    @MockitoSpyBean
    private AuthTokenProvider authTokenProvider;

    @Autowired
    private CustomAuthenticationEntryPoint authenticationEntryPoint;

    @Autowired
    private JwtProvider jwtProvider;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    private JwtAuthFilter jwtAuthFilter;

    @BeforeEach
    void setUp() {
        jwtAuthFilter = new JwtAuthFilter(authTokenProvider, authenticationEntryPoint);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Nested
    @DisplayName("유효한 토큰으로 인증할 때")
    class ValidToken {

        @Test
        void 유저를_한_번만_조회한다() throws Exception {
            // given
            User user = userFixture.일반_유저(1);
            String token = 유효한_토큰(user);

            MockHttpServletRequest request = 인증_요청(PROTECTED_URI, token);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            verify(authTokenProvider, times(1)).parseUser(token);
        }

        @Test
        void principal에_토큰_주체와_같은_LoginUser를_담는다() throws Exception {
            // given
            User user = userFixture.일반_유저(1);
            String token = 유효한_토큰(user);

            MockHttpServletRequest request = 인증_요청(PROTECTED_URI, token);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            assertSoftly(softly -> {
                softly.assertThat(authentication).isNotNull();
                softly.assertThat(authentication.getPrincipal()).isInstanceOf(LoginUser.class);

                LoginUser loginUser = (LoginUser) authentication.getPrincipal();
                softly.assertThat(loginUser.getId()).isEqualTo(user.getId());
                softly.assertThat(loginUser.getProvider()).isEqualTo(user.getProviderId());
                softly.assertThat(loginUser.getAuthorities())
                        .extracting("authority")
                        .containsExactly("ROLE_" + user.getRole().name());
            });
        }

        @Test
        void user_id_속성에_유저의_id를_담는다() throws Exception {
            // given
            User user = userFixture.일반_유저(1);
            String token = 유효한_토큰(user);

            MockHttpServletRequest request = 인증_요청(PROTECTED_URI, token);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            assertThat(request.getAttribute(USER_ID_ATTRIBUTE)).isEqualTo(user.getId());
        }

        @Test
        void 다음_필터로_요청을_넘긴다() throws Exception {
            // given
            User user = userFixture.일반_유저(1);
            String token = 유효한_토큰(user);

            MockHttpServletRequest request = 인증_요청(PROTECTED_URI, token);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            assertThat(filterChain.getRequest()).isSameAs(request);
        }
    }

    @Nested
    @DisplayName("인증에 실패할 때")
    class InvalidToken {

        @Test
        void 만료된_토큰이면_TOKEN_EXPIRED를_응답한다() throws Exception {
            // given
            User user = userFixture.일반_유저(1);
            String token = 만료된_토큰(user);

            MockHttpServletRequest request = 인증_요청(PROTECTED_URI, token);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            String body = response.getContentAsString();
            assertSoftly(softly -> {
                softly.assertThat(response.getStatus()).isEqualTo(TOKEN_EXPIRED.getHttpStatus().value());
                softly.assertThat(body).contains(TOKEN_EXPIRED.getCode());
                softly.assertThat(filterChain.getRequest()).isNull();
                softly.assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
            });
        }

        @Test
        void 존재하지_않는_유저의_토큰이면_USER_NOT_FOUND를_응답한다() throws Exception {
            // given
            String token = 토큰(9_999_999L);

            MockHttpServletRequest request = 인증_요청(PROTECTED_URI, token);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            String body = response.getContentAsString();
            assertSoftly(softly -> {
                softly.assertThat(response.getStatus()).isEqualTo(USER_NOT_FOUND.getHttpStatus().value());
                softly.assertThat(body).contains(USER_NOT_FOUND.getCode());
                softly.assertThat(filterChain.getRequest()).isNull();
                softly.assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
            });
        }

        @Test
        void 탈퇴한_유저의_토큰이면_USER_NOT_FOUND를_응답한다() throws Exception {
            // given
            User user = userFixture.일반_유저(1);
            String token = 유효한_토큰(user);
            userRepository.delete(user);

            MockHttpServletRequest request = 인증_요청(PROTECTED_URI, token);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            String body = response.getContentAsString();
            assertSoftly(softly -> {
                softly.assertThat(response.getStatus()).isEqualTo(USER_NOT_FOUND.getHttpStatus().value());
                softly.assertThat(body).contains(USER_NOT_FOUND.getCode());
                softly.assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
            });
        }
    }

    @Nested
    @DisplayName("유저를 조회하지 않는 요청일 때")
    class NoLookup {

        @Test
        void 인증_제외_경로이면_토큰이_있어도_조회하지_않는다() throws Exception {
            // given
            User user = userFixture.일반_유저(1);
            String token = 유효한_토큰(user);

            MockHttpServletRequest request = 인증_요청(EXCLUDED_URI, token);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            verify(authTokenProvider, never()).parseUser(anyString());
            assertSoftly(softly -> {
                softly.assertThat(filterChain.getRequest()).isSameAs(request);
                softly.assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
            });
        }

        @Test
        void Authorization_헤더가_없으면_조회하지_않고_통과시킨다() throws Exception {
            // given
            MockHttpServletRequest request = new MockHttpServletRequest("GET", PROTECTED_URI);
            MockHttpServletResponse response = new MockHttpServletResponse();
            MockFilterChain filterChain = new MockFilterChain();

            // when
            jwtAuthFilter.doFilter(request, response, filterChain);

            // then
            verify(authTokenProvider, never()).parseUser(anyString());
            assertSoftly(softly -> {
                softly.assertThat(filterChain.getRequest()).isSameAs(request);
                softly.assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
            });
        }
    }

    private MockHttpServletRequest 인증_요청(
            String uri,
            String token
    ) {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", uri);
        request.addHeader(AUTHORIZATION_HEADER, BEARER_PREFIX + token);
        return request;
    }

    private String 유효한_토큰(User user) {
        return 토큰(user.getId());
    }

    private String 토큰(long userId) {
        return jwtProvider.generateToken(
                new Subject(String.valueOf(userId)),
                Map.of("role", "USER"),
                Duration.ofMinutes(15)
        );
    }

    private String 만료된_토큰(User user) {
        return jwtProvider.generateToken(
                new Subject(String.valueOf(user.getId())),
                Map.of("role", "USER"),
                Duration.ofSeconds(-10)
        );
    }
}
