package gravit.code.problem.service;

import gravit.code.domain.problem.service.ProblemService;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.domain.lesson.dto.response.LessonResponse;
import gravit.code.domain.problem.domain.ProblemType;
import gravit.code.domain.problem.domain.ProblemRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProblemServiceTest {

    @Mock
    private ProblemRepository problemRepository;

    @InjectMocks
    private ProblemService problemService;

    @Test
    @DisplayName("lessonId를 통해 Problem을 조회할 수 있다.")
    void getLessonProblemsByExistLessonId(){
        // given
        Long lessonId = 1L;
        List<LessonResponse> expectedResponse = List.of(
                new LessonResponse(1L, ProblemType.FILL_BLANK, "문제1", "-", "정답1"),
                new LessonResponse(2L, ProblemType.SELECT_DESCRIPTION, "문제2", "선택지", "정답2")
        );

        when(problemRepository.findByLessonId(lessonId)).thenReturn(expectedResponse);

        // when
        List<LessonResponse> actualResponse = problemService.getLesson(lessonId);

        // then
        assertThat(actualResponse).hasSize(expectedResponse.size());
        assertThat(actualResponse).isEqualTo(expectedResponse);
    }

    @Test
    @DisplayName("조회 결과가 빈 리스트인 경우(존재하지 않는 lessonId로 조회한 경우) 예외를 반환한다.")
    void getLessonProblemByNonExistLessonId(){
        // given
        Long lessonId = 100000L;
        when(problemRepository.findByLessonId(lessonId)).thenReturn(List.of());

        // when & then
        assertThatThrownBy(() -> problemService.getLesson(lessonId))
                .isInstanceOf(RestApiException.class)
                .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
    }
}