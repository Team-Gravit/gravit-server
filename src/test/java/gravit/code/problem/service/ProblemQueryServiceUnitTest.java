package gravit.code.problem.service;

import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.repository.ProblemRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProblemQueryServiceUnitTest {

    @InjectMocks
    private ProblemQueryService problemQueryService;

    @Mock
    private ProblemRepository problemRepository;

    @Nested
    @DisplayName("레슨 내 문제 목록을 조회할 때")
    class GetAllProblemInLesson {

        @Test
        void 문제_목록을_반환한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            List<ProblemDetailResponse> expected = List.of(
                    new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false),
                    new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", true)
            );

            when(problemRepository.findAllProblemDetailByLessonIdAndUserId(lessonId, userId)).thenReturn(expected);

            // when
            List<ProblemDetailResponse> result = problemQueryService.getAllProblemInLesson(userId, lessonId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).id()).isEqualTo(1L);
                softly.assertThat(result.get(0).problemType()).isEqualTo(ProblemType.SUBJECTIVE);
                softly.assertThat(result.get(1).isBookmarked()).isTrue();
            });
        }

        @Test
        void 문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;

            when(problemRepository.findAllProblemDetailByLessonIdAndUserId(lessonId, userId)).thenReturn(List.of());

            // when
            List<ProblemDetailResponse> result = problemQueryService.getAllProblemInLesson(userId, lessonId);

            // then
            assertThat(result).isEmpty();
        }
    }
}
