package gravit.code.interviewTechStack.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.repository.InterviewTechStackRepository;
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

import static gravit.code.interviewTechStack.fixture.InterviewTechStackFixture.기술스택;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class InterviewTechStackControllerIntegrationTest {

    private static final String TECH_STACKS_URI = "/api/v1/interview-tech-stacks";
    private static final long USER_ID = 1L;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private InterviewTechStackRepository interviewTechStackRepository;

    @Nested
    @DisplayName("기술 스택 목록을 요청할 때")
    class GetTechStacks {

        @Test
        void 노출_순서대로_내려준다() throws Exception {
            // given
            interviewTechStackRepository.save(기술스택(InterviewJobRole.BACKEND, "SPRING", "Spring", 2));
            interviewTechStackRepository.save(기술스택(InterviewJobRole.BACKEND, "NODE", "Node.js", 1));

            // when & then
            mockMvc.perform(get(TECH_STACKS_URI)
                            .param("jobRole", "BACKEND")
                            .with(로그인_사용자()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.length()").value(2))
                    .andExpect(jsonPath("$[0].code").value("NODE"))
                    .andExpect(jsonPath("$[1].code").value("SPRING"))
                    .andExpect(jsonPath("$[0].displayName").value("Node.js"));
        }

        @Test
        void 인증이_없으면_거절한다() throws Exception {
            // when & then
            mockMvc.perform(get(TECH_STACKS_URI).param("jobRole", "BACKEND"))
                    .andExpect(status().isForbidden());
        }
    }

    private RequestPostProcessor 로그인_사용자() {
        LoginUser loginUser = new LoginUser(
                USER_ID,
                "test",
                null,
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );

        return authentication(new UsernamePasswordAuthenticationToken(
                loginUser,
                null,
                loginUser.getAuthorities()
        ));
    }
}
