package gravit.code.admin.controller;

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
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_PARAMS;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class AdminDashboardControllerIntegrationTest {

    private static final String DAILY_URI = "/api/v1/admin/dashboard/active-users/daily";
    private static final String MONTHLY_URI = "/api/v1/admin/dashboard/active-users/monthly";
    private static final long ADMIN_ID = 1L;

    @Autowired
    private MockMvc mockMvc;

    private RequestPostProcessor 관리자_인증() {
        LoginUser admin = new LoginUser(
                ADMIN_ID,
                "test",
                null,
                List.of(new SimpleGrantedAuthority("ROLE_ADMIN"))
        );
        return authentication(new UsernamePasswordAuthenticationToken(admin, null, admin.getAuthorities()));
    }

    @Nested
    @DisplayName("일별 활성 유저 추이를 요청할 때")
    class GetDailyActiveUsers {

        @Test
        void days를_생략하면_기본값_30일로_조회한다() throws Exception {
            // when & then
            mockMvc.perform(get(DAILY_URI).with(관리자_인증()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.points.length()").value(30));
        }

        @Test
        void days가_1보다_작으면_400을_반환한다() throws Exception {
            // when & then
            mockMvc.perform(get(DAILY_URI).param("days", "0").with(관리자_인증()))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(INVALID_PARAMS.getCode()));
        }

        @Test
        void days가_365를_넘으면_400을_반환한다() throws Exception {
            // when & then
            mockMvc.perform(get(DAILY_URI).param("days", "366").with(관리자_인증()))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(INVALID_PARAMS.getCode()));
        }

        @Test
        void days_경계값_1과_365는_허용한다() throws Exception {
            // when & then
            mockMvc.perform(get(DAILY_URI).param("days", "1").with(관리자_인증()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.points.length()").value(1));

            mockMvc.perform(get(DAILY_URI).param("days", "365").with(관리자_인증()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.points.length()").value(365));
        }
    }

    @Nested
    @DisplayName("월별 활성 유저 추이를 요청할 때")
    class GetMonthlyActiveUsers {

        @Test
        void months를_생략하면_기본값_12개월로_조회한다() throws Exception {
            // when & then
            mockMvc.perform(get(MONTHLY_URI).with(관리자_인증()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.points.length()").value(12));
        }

        @Test
        void months가_1보다_작으면_400을_반환한다() throws Exception {
            // when & then
            mockMvc.perform(get(MONTHLY_URI).param("months", "0").with(관리자_인증()))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(INVALID_PARAMS.getCode()));
        }

        @Test
        void months가_36을_넘으면_400을_반환한다() throws Exception {
            // when & then
            mockMvc.perform(get(MONTHLY_URI).param("months", "37").with(관리자_인증()))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(INVALID_PARAMS.getCode()));
        }

        @Test
        void months_경계값_1과_36은_허용한다() throws Exception {
            // when & then
            mockMvc.perform(get(MONTHLY_URI).param("months", "1").with(관리자_인증()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.points.length()").value(1));

            mockMvc.perform(get(MONTHLY_URI).param("months", "36").with(관리자_인증()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.points.length()").value(36));
        }
    }
}
