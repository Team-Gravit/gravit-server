package gravit.code.interview.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.auth.domain.LoginUser;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewLevel;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.dto.request.InterviewAnswerSubmitRequest;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.facade.InterviewSessionFacade;
import gravit.code.interviewQuestion.repository.InterviewCategoryRepository;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.util.List;

import static gravit.code.interview.fixture.InterviewSessionFixture.공통CS_생성요청;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.공통CS_카테고리;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.난이도별_질문;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class InterviewSessionControllerIntegrationTest {

    private static final String SESSIONS_URI = "/api/v1/interview-sessions";
    private static final long USER_ID = 1L;
    private static final long NOT_EXIST_SESSION_ID = 999L;
    private static final int FIRST_ORDER = 1;
    private static final int QUESTION_COUNT = 5;
    private static final String ANSWER_CONTENT = "인덱스는 조회 성능을 높이기 위한 자료구조입니다.";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private InterviewSessionFacade interviewSessionFacade;

    @Autowired
    private InterviewCategoryRepository interviewCategoryRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Nested
    @DisplayName("세션 생성을 요청할 때")
    class CreateSession {

        @Test
        void 생성에_성공하면_201과_질문_다섯_개를_내려준다() throws Exception {
            // given
            공통CS_질문을_채운다();

            // when & then
            mockMvc.perform(post(SESSIONS_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(공통CS_생성요청()))
                            .with(로그인_사용자()))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.sessionId").isNumber())
                    .andExpect(jsonPath("$.questions.length()").value(QUESTION_COUNT))
                    .andExpect(jsonPath("$.questions[0].displayOrder").value(1))
                    .andExpect(jsonPath("$.questions[0].content").isNotEmpty());
        }

        @Test
        void 음성_입력을_요청하면_400을_내려준다() throws Exception {
            // given
            공통CS_질문을_채운다();
            InterviewSessionCreateRequest request = new InterviewSessionCreateRequest(
                    InterviewMode.COMMON_CS,
                    InterviewInputType.VOICE,
                    InterviewLevel.MEDIUM,
                    null
            );

            // when & then
            mockMvc.perform(post(SESSIONS_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request))
                            .with(로그인_사용자()))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value("INTERVIEW_4013"));
        }

        @Test
        void 필수값이_비면_400을_내려준다() throws Exception {
            // given
            InterviewSessionCreateRequest request = new InterviewSessionCreateRequest(
                    null,
                    InterviewInputType.TEXT,
                    InterviewLevel.MEDIUM,
                    null
            );

            // when & then
            mockMvc.perform(post(SESSIONS_URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request))
                            .with(로그인_사용자()))
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("답변 제출을 요청할 때")
    class SubmitAnswer {

        @Test
        void 제출에_성공하면_200과_응답_완료_상태를_내려준다() throws Exception {
            // given
            long sessionId = 세션을_만든다();

            // when & then
            mockMvc.perform(patch(SESSIONS_URI + "/{sessionId}/answers/{displayOrder}", sessionId, FIRST_ORDER)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(new InterviewAnswerSubmitRequest(ANSWER_CONTENT)))
                            .with(로그인_사용자()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.answerId").isNumber())
                    .andExpect(jsonPath("$.status").value("ANSWERED"));
        }

        @Test
        void 존재하지_않는_세션이면_404를_내려준다() throws Exception {
            // when & then
            mockMvc.perform(patch(SESSIONS_URI + "/{sessionId}/answers/{displayOrder}", NOT_EXIST_SESSION_ID, FIRST_ORDER)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(new InterviewAnswerSubmitRequest(ANSWER_CONTENT)))
                            .with(로그인_사용자()))
                    .andExpect(status().isNotFound())
                    .andExpect(jsonPath("$.error").value("INTERVIEW_4003"));
        }
    }

    @Nested
    @DisplayName("세션 종료를 요청할 때")
    class CompleteSession {

        @Test
        void 종료에_성공하면_202와_채점_중_상태를_내려준다() throws Exception {
            // given
            long sessionId = 세션을_만든다();

            // when & then
            mockMvc.perform(patch(SESSIONS_URI + "/{sessionId}/complete", sessionId)
                            .with(로그인_사용자()))
                    .andExpect(status().isAccepted())
                    .andExpect(jsonPath("$.sessionId").value(sessionId))
                    .andExpect(jsonPath("$.status").value("GRADING"));
        }

        @Test
        void 이미_끝난_세션이면_409를_내려준다() throws Exception {
            // given
            long sessionId = 세션을_만든다();
            mockMvc.perform(patch(SESSIONS_URI + "/{sessionId}/complete", sessionId).with(로그인_사용자()));

            // when & then
            mockMvc.perform(patch(SESSIONS_URI + "/{sessionId}/complete", sessionId)
                            .with(로그인_사용자()))
                    .andExpect(status().isConflict())
                    .andExpect(jsonPath("$.error").value("INTERVIEW_4005"));
        }
    }

    @Nested
    @DisplayName("세션 중단을 요청할 때")
    class AbandonSession {

        @Test
        void 중단에_성공하면_200과_중단_상태를_내려준다() throws Exception {
            // given
            long sessionId = 세션을_만든다();

            // when & then
            mockMvc.perform(patch(SESSIONS_URI + "/{sessionId}/abandon", sessionId)
                            .with(로그인_사용자()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.sessionId").value(sessionId))
                    .andExpect(jsonPath("$.status").value("ABANDONED"));
        }
    }

    private void 공통CS_질문을_채운다() {
        long categoryId = interviewCategoryRepository.save(공통CS_카테고리("운영체제")).getId();
        interviewQuestionRepository.saveAll(난이도별_질문(categoryId, 5));
    }

    private long 세션을_만든다() {
        공통CS_질문을_채운다();

        InterviewSessionCreateResponse response = interviewSessionFacade.createSession(USER_ID, 공통CS_생성요청());

        return response.sessionId();
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
