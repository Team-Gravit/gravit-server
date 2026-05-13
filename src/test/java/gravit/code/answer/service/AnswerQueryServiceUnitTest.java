package gravit.code.answer.service;

import gravit.code.answer.domain.Answer;
import gravit.code.answer.dto.response.AnswerResponse;
import gravit.code.answer.fixture.AnswerFixture;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AnswerQueryServiceUnitTest {

    @InjectMocks
    private AnswerQueryService answerQueryService;

    @Mock
    private AnswerRepository answerRepository;

    @Nested
    @DisplayName("문제 목록의 정답을 조회할 때")
    class GetAnswersInProblem {

        @Test
        void 주관식_문제의_정답_Map을_반환한다() {
            // given
            ProblemDetailResponse subjective = new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false);
            Answer answer = AnswerFixture.기본_정답(1L);

            when(answerRepository.findByProblemIdIn(List.of(1L))).thenReturn(List.of(answer));

            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(List.of(subjective));

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result).containsKey(1L);
            });
        }

        @Test
        void 객관식_문제만_있으면_빈_Map을_반환한다() {
            // given
            ProblemDetailResponse objective = new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false);

            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(List.of(objective));

            // then
            assertThat(result).isEmpty();
            verify(answerRepository, never()).findByProblemIdIn(any());
        }

        @Test
        void 혼합_문제_목록에서_주관식만_필터링하여_정답을_반환한다() {
            // given
            ProblemDetailResponse subjective = new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false);
            ProblemDetailResponse objective = new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false);
            Answer answer = AnswerFixture.기본_정답(1L);

            when(answerRepository.findByProblemIdIn(List.of(1L))).thenReturn(List.of(answer));

            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(List.of(subjective, objective));

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result).containsKey(1L);
                softly.assertThat(result).doesNotContainKey(2L);
            });
            verify(answerRepository).findByProblemIdIn(List.of(1L));
        }

        @Test
        void 빈_문제_목록이면_빈_Map을_반환한다() {
            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(List.of());

            // then
            assertThat(result).isEmpty();
            verify(answerRepository, never()).findByProblemIdIn(any());
        }
    }
}
