package gravit.code.answer.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

import gravit.code.answer.domain.Answer;
import gravit.code.answer.dto.response.AnswerResponse;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.support.TCSpringBootTest;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@TCSpringBootTest
class AnswerQueryServiceIntegrationTest {

    @Autowired
    private AnswerQueryService answerQueryService;

    @Autowired
    private AnswerRepository answerRepository;

    @Nested
    @DisplayName("문제 목록의 정답을 조회할 때")
    class GetAnswersInProblem {

        @Test
        void 주관식_문제의_정답_Map을_반환한다() {
            // given
            long problemId = 1L;
            answerRepository.save(Answer.create("LIFO", "스택은 Last In First Out 구조입니다.", problemId));
            ProblemDetailResponse subjective = new ProblemDetailResponse(problemId, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false);

            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(List.of(subjective));

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result).containsKey(problemId);
                softly.assertThat(result.get(problemId).contents()).contains("LIFO");
            });
        }

        @Test
        void 여러_주관식_문제의_정답을_각각_반환한다() {
            // given
            answerRepository.save(Answer.create("LIFO", "스택 해설", 1L));
            answerRepository.save(Answer.create("FIFO", "큐 해설", 2L));
            List<ProblemDetailResponse> problems = List.of(
                    new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false),
                    new ProblemDetailResponse(2L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "큐는 ___구조이다.", false)
            );

            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(problems);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(1L).contents()).contains("LIFO");
                softly.assertThat(result.get(2L).contents()).contains("FIFO");
            });
        }

        @Test
        void 객관식_문제만_있으면_빈_Map을_반환한다() {
            // given
            ProblemDetailResponse objective = new ProblemDetailResponse(1L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false);

            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(List.of(objective));

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 혼합_문제_목록에서_주관식만_정답을_반환한다() {
            // given
            answerRepository.save(Answer.create("LIFO", "스택 해설", 1L));
            List<ProblemDetailResponse> problems = List.of(
                    new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false),
                    new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false)
            );

            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(problems);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result).containsKey(1L);
                softly.assertThat(result).doesNotContainKey(2L);
            });
        }

        @Test
        void 빈_문제_목록이면_빈_Map을_반환한다() {
            // when
            Map<Long, AnswerResponse> result = answerQueryService.getAnswersInProblem(List.of());

            // then
            assertThat(result).isEmpty();
        }
    }
}
