package gravit.code.option.service;

import gravit.code.option.domain.Option;
import gravit.code.option.dto.response.OptionResponse;
import gravit.code.option.repository.OptionRepository;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Transactional
class OptionQueryServiceIntegrationTest {

    @Autowired
    private OptionQueryService optionQueryService;

    @Autowired
    private OptionRepository optionRepository;

    @Nested
    @DisplayName("문제 목록의 선지를 조회할 때")
    class GetOptionsInProblem {

        @Test
        void 객관식_문제의_선지_Map을_반환한다() {
            // given
            long problemId = 1L;
            optionRepository.save(Option.create("FIFO 구조이다.", "큐는 First In First Out 구조입니다.", true, problemId));
            optionRepository.save(Option.create("LIFO 구조이다.", "이것은 스택의 특성입니다.", false, problemId));
            ProblemDetailResponse objective = new ProblemDetailResponse(problemId, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false);

            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(List.of(objective));

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result).containsKey(problemId);
                softly.assertThat(result.get(problemId)).hasSize(2);
            });
        }

        @Test
        void 여러_객관식_문제의_선지를_문제별로_그룹화하여_반환한다() {
            // given
            optionRepository.save(Option.create("FIFO 구조이다.", "큐 해설", true, 1L));
            optionRepository.save(Option.create("LIFO 구조이다.", "스택 해설", true, 2L));
            optionRepository.save(Option.create("오답 선지", "오답 해설", false, 2L));
            List<ProblemDetailResponse> problems = List.of(
                    new ProblemDetailResponse(1L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false),
                    new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "스택의 특성은?", false)
            );

            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(problems);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(1L)).hasSize(1);
                softly.assertThat(result.get(2L)).hasSize(2);
            });
        }

        @Test
        void 주관식_문제만_있으면_빈_Map을_반환한다() {
            // given
            ProblemDetailResponse subjective = new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false);

            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(List.of(subjective));

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 혼합_문제_목록에서_객관식만_선지를_반환한다() {
            // given
            optionRepository.save(Option.create("FIFO 구조이다.", "큐 해설", true, 2L));
            List<ProblemDetailResponse> problems = List.of(
                    new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false),
                    new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false)
            );

            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(problems);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result).containsKey(2L);
                softly.assertThat(result).doesNotContainKey(1L);
            });
        }

        @Test
        void 빈_문제_목록이면_빈_Map을_반환한다() {
            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(List.of());

            // then
            assertThat(result).isEmpty();
        }
    }
}
