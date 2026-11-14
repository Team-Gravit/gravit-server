package gravit.code.security.config;

import gravit.code.auth.domain.LoginUser;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.TOKEN_EMPTY;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class SecurityConfigIntegrationTest {

    private static final String AUTHORIZATION_HEADER = "Authorization";

    private static final String PROTECTED_URI = "/api/v1/users";
    private static final String ADMIN_URI = "/api/v1/admin/dashboard/summary";
    private static final String PERMIT_ALL_URI = "/api/v1/version";

    private static final long USER_ID = 1L;

    @Autowired
    private MockMvc mockMvc;

    @Nested
    @DisplayName("토큰 없이 인증이 필요한 API를 호출할 때")
    class MissingToken {

        @Test
        void Authorization_헤더가_없으면_401과_TOKEN_EMPTY를_응답한다() throws Exception {
            // when & then
            mockMvc.perform(get(PROTECTED_URI))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.error").value(TOKEN_EMPTY.getCode()));
        }

        @Test
        void Bearer_형식이_아닌_헤더이면_401과_TOKEN_EMPTY를_응답한다() throws Exception {
            // when & then
            mockMvc.perform(get(PROTECTED_URI).header(AUTHORIZATION_HEADER, "abc"))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.error").value(TOKEN_EMPTY.getCode()));
        }

        @Test
        void 인증이_필요_없는_경로는_인증_실패로_응답하지_않는다() throws Exception {
            // when
            MvcResult result = mockMvc.perform(get(PERMIT_ALL_URI)).andReturn();

            // then
            int status = result.getResponse().getStatus();
            assertSoftly(softly -> {
                softly.assertThat(status).isNotEqualTo(TOKEN_EMPTY.getHttpStatus().value());
                softly.assertThat(status).isNotEqualTo(ACCESS_DENIED.getHttpStatus().value());
            });
        }
    }

    @Nested
    @DisplayName("권한이 없는 사용자가 호출할 때")
    class NoPermission {

        @Test
        void 일반_사용자가_관리자_API를_호출하면_403과_ACCESS_DENIED를_응답한다() throws Exception {
            // when & then
            mockMvc.perform(get(ADMIN_URI).with(일반_사용자_인증()))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.error").value(ACCESS_DENIED.getCode()));
        }
    }

    private RequestPostProcessor 일반_사용자_인증() {
        LoginUser user = new LoginUser(
                USER_ID,
                "test",
                null,
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        return authentication(new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities()));
    }
}
