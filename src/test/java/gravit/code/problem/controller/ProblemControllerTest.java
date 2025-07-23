package gravit.code.problem.controller;

import gravit.code.domain.problem.controller.ProblemController;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.domain.lesson.dto.response.LessonResponse;
import gravit.code.domain.problem.domain.ProblemType;
import gravit.code.domain.problem.service.ProblemService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ProblemController.class)
class ProblemControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ProblemService problemService;

    @Test
    @WithMockUser
    @DisplayName("유효한 lessonId로 레슨 문제 조회할 수 있다.")
    void getProblemWithValidLessonId() throws Exception {
        // given
        Long lessonId = 1L;
        List<LessonResponse> expectedResponse = Arrays.asList(
                LessonResponse.create(1L, ProblemType.FILL_BLANK, "문제1", "선택지1", "정답1"),
                LessonResponse.create(2L, ProblemType.FILL_BLANK, "문제2", "-", "정답2"),
                LessonResponse.create(3L, ProblemType.SELECT_DESCRIPTION, "문제3", "선택지3", "정답3"),
                LessonResponse.create(4L, ProblemType.FILL_BLANK, "문제4", "-", "정답4")
                );
        when(problemService.getLesson(lessonId)).thenReturn(expectedResponse);

        // when & then
        mockMvc.perform(get("/api/v1/problems/{lessonId}",  lessonId).contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser
    @DisplayName("유효하지 않은 lessonId로 문제를 조회하면 예외를 반환한다.")
    void getProblemWithInvalidLessonId() throws Exception {
        // given
        Long lessonId = 999L;

        when(problemService.getLesson(lessonId))
                .thenThrow(new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));

        // when & then
        mockMvc.perform(get("/api/v1/problems/{lessonId}", lessonId)
                .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().is4xxClientError());
    }

}