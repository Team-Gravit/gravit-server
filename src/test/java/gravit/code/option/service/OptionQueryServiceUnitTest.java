package gravit.code.option.service;

import gravit.code.option.dto.response.OptionResponse;
import gravit.code.option.fixture.OptionFixture;
import gravit.code.option.repository.OptionRepository;
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
class OptionQueryServiceUnitTest {

    @InjectMocks
    private OptionQueryService optionQueryService;

    @Mock
    private OptionRepository optionRepository;

    @Nested
    @DisplayName("문제 목록의 선지를 조회할 때")
    class GetOptionsInProblem {

        @Test
        void 객관식_문제의_선지_Map을_반환한다() {
            // given
            ProblemDetailResponse objective = new ProblemDetailResponse(1L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false);
            OptionResponse optionResponse = OptionResponse.from(OptionFixture.정답_선택지(1L));

            when(optionRepository.findAllByProblemIdIn(List.of(1L))).thenReturn(List.of(optionResponse));

            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(List.of(objective));

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result).containsKey(1L);
                softly.assertThat(result.get(1L)).hasSize(1);
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
            verify(optionRepository, never()).findAllByProblemIdIn(any());
        }

        @Test
        void 혼합_문제_목록에서_객관식만_필터링하여_선지를_반환한다() {
            // given
            ProblemDetailResponse subjective = new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false);
            ProblemDetailResponse objective = new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false);
            OptionResponse optionResponse = OptionResponse.from(OptionFixture.정답_선택지(2L));

            when(optionRepository.findAllByProblemIdIn(List.of(2L))).thenReturn(List.of(optionResponse));

            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(List.of(subjective, objective));

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result).containsKey(2L);
                softly.assertThat(result).doesNotContainKey(1L);
            });
            verify(optionRepository).findAllByProblemIdIn(List.of(2L));
        }

        @Test
        void 여러_객관식_문제의_선지를_문제별로_그룹화하여_반환한다() {
            // given
            ProblemDetailResponse objective1 = new ProblemDetailResponse(1L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "큐의 특성은?", false);
            ProblemDetailResponse objective2 = new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 고르시오.", "스택의 특성은?", false);
            OptionResponse option1 = OptionResponse.from(OptionFixture.저장된_선택지(1L, true, 1L));
            OptionResponse option2 = OptionResponse.from(OptionFixture.저장된_선택지(2L, false, 2L));

            when(optionRepository.findAllByProblemIdIn(List.of(1L, 2L))).thenReturn(List.of(option1, option2));

            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(List.of(objective1, objective2));

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(1L)).hasSize(1);
                softly.assertThat(result.get(2L)).hasSize(1);
            });
        }

        @Test
        void 빈_문제_목록이면_빈_Map을_반환한다() {
            // when
            Map<Long, List<OptionResponse>> result = optionQueryService.getOptionsInProblem(List.of());

            // then
            assertThat(result).isEmpty();
            verify(optionRepository, never()).findAllByProblemIdIn(any());
        }
    }
}
