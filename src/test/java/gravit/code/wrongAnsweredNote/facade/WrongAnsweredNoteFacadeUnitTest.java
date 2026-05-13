package gravit.code.wrongAnsweredNote.facade;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.problem.factory.ProblemFactory;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class WrongAnsweredNoteFacadeUnitTest {

    @InjectMocks
    private WrongAnsweredNoteFacade wrongAnsweredNoteFacade;

    @Mock
    private WrongAnsweredNoteService wrongAnsweredNoteService;

    @Mock
    private UnitQueryService unitQueryService;

    @Mock
    private ProblemFactory problemFactory;

    @Nested
    @DisplayName("유닛 내 오답 문제 목록을 조회할 때")
    class GetAllWrongAnsweredProblemInUnit {

        @Test
        void 유닛_정보와_오답_문제_목록을_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;
            UnitSummaryResponse unitSummaryResponse = new UnitSummaryResponse(unitId, "스택/큐", "스택과 큐 개념");
            List<ProblemDetailResponse> problemDetailResponses = List.of(
                    new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false)
            );
            List<ProblemResponse> problemResponses = List.of(
                    ProblemResponse.createSubjectiveProblem(problemDetailResponses.get(0), null)
            );

            when(unitQueryService.getUnitSummaryByUnitId(unitId)).thenReturn(unitSummaryResponse);
            when(wrongAnsweredNoteService.getAllWrongAnsweredProblemInUnit(userId, unitId)).thenReturn(problemDetailResponses);
            when(problemFactory.create(problemDetailResponses)).thenReturn(problemResponses);

            // when
            WrongAnsweredProblemsResponse result = wrongAnsweredNoteFacade.getAllWrongAnsweredProblemInUnit(userId, unitId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("스택/큐");
                softly.assertThat(result.problems()).hasSize(1);
                softly.assertThat(result.totalProblems()).isEqualTo(1);
            });
        }

        @Test
        void 오답_문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;
            UnitSummaryResponse unitSummaryResponse = new UnitSummaryResponse(unitId, "스택/큐", "스택과 큐 개념");

            when(unitQueryService.getUnitSummaryByUnitId(unitId)).thenReturn(unitSummaryResponse);
            when(wrongAnsweredNoteService.getAllWrongAnsweredProblemInUnit(userId, unitId)).thenReturn(List.of());
            when(problemFactory.create(List.of())).thenReturn(List.of());

            // when
            WrongAnsweredProblemsResponse result = wrongAnsweredNoteFacade.getAllWrongAnsweredProblemInUnit(userId, unitId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.problems()).isEmpty();
                softly.assertThat(result.totalProblems()).isEqualTo(0);
            });
        }

        @Test
        void 유닛이_존재하지_않으면_예외가_발생한다() {
            // given
            long userId = 1L;
            long unitId = 999L;

            when(unitQueryService.getUnitSummaryByUnitId(unitId))
                    .thenThrow(new RestApiException(UNIT_NOT_FOUND));

            // when & then
            assertThatThrownBy(() -> wrongAnsweredNoteFacade.getAllWrongAnsweredProblemInUnit(userId, unitId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }
}
