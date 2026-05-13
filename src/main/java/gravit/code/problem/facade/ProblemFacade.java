package gravit.code.problem.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.factory.ProblemFactory;
import gravit.code.problem.service.ProblemQueryService;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class ProblemFacade {

    private final ProblemQueryService problemQueryService;

    private final UnitQueryService unitQueryService;
    private final ProblemFactory problemFactory;

    @Transactional(readOnly = true)
    public LessonResponse getAllProblemInLesson(
            long userId,
            long lessonId
    ){
        UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByLessonId(lessonId);

        List<ProblemDetailResponse> problemDetailResponses = problemQueryService.getAllProblemInLesson(userId, lessonId);

        List<ProblemResponse> problemResponses = problemFactory.create(problemDetailResponses);

        return LessonResponse.of(
                unitSummaryResponse,
                problemResponses
        );
    }
}
