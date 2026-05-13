package gravit.code.problem.facade;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.factory.ProblemFactory;
import gravit.code.problem.service.ProblemQueryService;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
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
class ProblemFacadeUnitTest {

    @InjectMocks
    private ProblemFacade problemFacade;

    @Mock
    private ProblemQueryService problemQueryService;

    @Mock
    private UnitQueryService unitQueryService;

    @Mock
    private ProblemFactory problemFactory;

    @Nested
    @DisplayName("레슨의 문제 목록을 조회할 때")
    class GetAllProblemInLesson {

        @Test
        void 유닛_정보와_문제_목록을_반환한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            UnitSummaryResponse unitSummaryResponse = new UnitSummaryResponse(1L, "연결리스트", "배열과 연결리스트를 학습합니다.");
            List<ProblemDetailResponse> problemDetailResponses = List.of(
                    new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false),
                    new ProblemDetailResponse(2L, ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", true)
            );
            List<ProblemResponse> problemResponses = List.of(
                    ProblemResponse.createSubjectiveProblem(problemDetailResponses.get(0), null),
                    ProblemResponse.createObjectiveProblem(problemDetailResponses.get(1), List.of())
            );

            when(unitQueryService.getUnitSummaryByLessonId(lessonId)).thenReturn(unitSummaryResponse);
            when(problemQueryService.getAllProblemInLesson(userId, lessonId)).thenReturn(problemDetailResponses);
            when(problemFactory.create(problemDetailResponses)).thenReturn(problemResponses);

            // when
            LessonResponse result = problemFacade.getAllProblemInLesson(userId, lessonId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("연결리스트");
                softly.assertThat(result.problems()).hasSize(2);
                softly.assertThat(result.totalProblems()).isEqualTo(2);
            });
        }

        @Test
        void 문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            UnitSummaryResponse unitSummaryResponse = new UnitSummaryResponse(1L, "연결리스트", "배열과 연결리스트를 학습합니다.");

            when(unitQueryService.getUnitSummaryByLessonId(lessonId)).thenReturn(unitSummaryResponse);
            when(problemQueryService.getAllProblemInLesson(userId, lessonId)).thenReturn(List.of());
            when(problemFactory.create(List.of())).thenReturn(List.of());

            // when
            LessonResponse result = problemFacade.getAllProblemInLesson(userId, lessonId);

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
            long lessonId = 999L;

            when(unitQueryService.getUnitSummaryByLessonId(lessonId))
                    .thenThrow(new RestApiException(UNIT_NOT_FOUND));

            // when & then
            assertThatThrownBy(() -> problemFacade.getAllProblemInLesson(userId, lessonId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }
}
