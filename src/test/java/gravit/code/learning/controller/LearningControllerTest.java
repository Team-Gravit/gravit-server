package gravit.code.learning.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.problem.dto.request.ProblemResult;
import gravit.code.user.dto.response.UserLevelResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(LearningController.class)
class LearningControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private LearningFacade learningFacade;

    @Test
    @WithMockUser
    @DisplayName("유효한 RequestBody로 문제 풀이 결과를 저장할 수 있다.")
    void saveLearningResultWithValidRequestBody() throws Exception {
        //given
        Long userId = 1L;
        Long chapterId = 1L;
        Long unitId = 2L;
        Long lessonId = 3L;
        List<ProblemResult>  problemResults = List.of(
            new ProblemResult(1L, true, 0L),
            new ProblemResult(2L, true, 0L),
            new ProblemResult(3L, false, 3L),
            new ProblemResult(4L, true, 0L),
            new ProblemResult(5L, true, 0L),
            new ProblemResult(6L, true, 0L),
            new ProblemResult(7L, false, 1L),
            new ProblemResult(8L, true, 0L),
            new ProblemResult(9L, true, 0L),
            new ProblemResult(10L, true, 0L)
        );
        LearningResultSaveRequest request = new LearningResultSaveRequest(
                chapterId, unitId, lessonId, problemResults
        );
        UserLevelResponse expectedResponse = new UserLevelResponse(1, 20);

        when(learningFacade.saveLearningProgress(userId, request)).thenReturn(expectedResponse);

        //when&then
        mockMvc.perform(post("/api/v1/learning/results/{userId}", userId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(csrf()))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.level").value(1))
                .andExpect(jsonPath("$.xp").value(20));
    }

    @Test
    @WithMockUser
    @DisplayName("유효하지 않은 RequestBody로 문제 풀이 결과를 저장하면 예외를 반환한다.")
    void saveLearningResultWithInvalidRequestBody1() throws Exception {
        //given
        Long userId = 1L;
        Long chapterId = null;
        Long unitId = null;
        Long lessonId = null;
        List<ProblemResult>  problemResults = List.of(
                new ProblemResult(1L, true, 0L),
                new ProblemResult(2L, true, 0L),
                new ProblemResult(3L, false, 3L),
                new ProblemResult(4L, true, 0L),
                new ProblemResult(5L, true, 0L),
                new ProblemResult(6L, true, 0L),
                new ProblemResult(7L, false, 1L),
                new ProblemResult(8L, true, 0L),
                new ProblemResult(9L, true, 0L),
                new ProblemResult(10L, true, 0L)
        );
        LearningResultSaveRequest request = new LearningResultSaveRequest(
                chapterId, unitId, lessonId, problemResults
        );
        UserLevelResponse expectedResponse = new UserLevelResponse(1, 20);

        when(learningFacade.saveLearningProgress(userId, request)).thenReturn(expectedResponse);

        //when&then
        mockMvc.perform(post("/api/v1/learning/results/{userId}", userId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(csrf()))
                .andDo(print())
                .andExpect(status().is4xxClientError());
    }

    @Test
    @WithMockUser
    @DisplayName("유효하지 않은 RequestBody로 문제 풀이 결과를 저장하면 예외를 반환한다.")
    void saveLearningResultWithInvalidRequestBody2() throws Exception {
        //given
        Long userId = 1L;
        Long chapterId = 1L;
        Long unitId = 1L;
        Long lessonId = 1L;
        List<ProblemResult>  problemResults = List.of(
                new ProblemResult(null, true, 0L),
                new ProblemResult(2L, null, 0L),
                new ProblemResult(3L, false, null),
                new ProblemResult(4L, null, 0L),
                new ProblemResult(5L, true, 0L),
                new ProblemResult(6L, true, 0L),
                new ProblemResult(7L, false, 1L),
                new ProblemResult(8L, true, 0L),
                new ProblemResult(9L, true, 0L),
                new ProblemResult(10L, true, 0L)
        );
        LearningResultSaveRequest request = new LearningResultSaveRequest(
                chapterId, unitId, lessonId, problemResults
        );
        UserLevelResponse expectedResponse = new UserLevelResponse(1, 20);

        when(learningFacade.saveLearningProgress(userId, request)).thenReturn(expectedResponse);

        //when&then
        mockMvc.perform(post("/api/v1/learning/results/{userId}", userId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(csrf()))
                .andDo(print())
                .andExpect(status().is4xxClientError());
    }
}