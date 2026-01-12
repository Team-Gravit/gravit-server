package gravit.code.problem.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.dto.response.ProblemDetail;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.service.ProblemQueryService;
import gravit.code.unit.dto.response.UnitSummary;
import gravit.code.unit.service.UnitQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class ProblemFacade {

    private final ProblemQueryService problemQueryService;

    private final UnitQueryService unitQueryService;

    @Transactional(readOnly = true)
    public LessonResponse getAllProblemInLesson(
            long userId,
            long lessonId
    ){
        UnitSummary unitSummary = unitQueryService.getUnitSummaryByLessonId(lessonId);

        List<ProblemDetail> problems = problemQueryService.getAllProblemInLesson(userId, lessonId);
        List<ProblemResponse> problemResponses = problemQueryService.getAnswerOrOptionInProblems(problems);

        return LessonResponse.of(
                unitSummary,
                problemResponses
        );
    }

}
