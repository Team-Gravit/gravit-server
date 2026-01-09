package gravit.code.wrongAnsweredNote.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.problem.dto.response.ProblemDetail;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.problem.service.ProblemQueryService;
import gravit.code.unit.dto.response.UnitSummary;
import gravit.code.unit.service.UnitQueryService;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class WrongAnsweredNoteFacade {

    private final WrongAnsweredNoteService wrongAnsweredNoteService;

    private final UnitQueryService unitQueryService;
    private final ProblemQueryService problemQueryService;

    @Transactional(readOnly = true)
    public WrongAnsweredProblemsResponse getAllWrongAnsweredProblemInUnit(
            long userId,
            long unitId
    ) {
        UnitSummary unitSummary = unitQueryService.getUnitSummaryByUnitId(unitId);

        List<ProblemDetail> problemDetails = wrongAnsweredNoteService.findWrongAnsweredProblemDetailByUnitIdAndUserId(userId, unitId);
        List<ProblemResponse> problemResponses = problemQueryService.getAnswerOrOptionInProblems(problemDetails);

        return WrongAnsweredProblemsResponse.of(
                unitSummary,
                problemResponses
        );
    }
}
