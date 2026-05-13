package gravit.code.wrongAnsweredNote.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.problem.factory.ProblemFactory;
import gravit.code.unit.dto.response.UnitSummaryResponse;
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
    private final ProblemFactory problemFactory;

    @Transactional(readOnly = true)
    public WrongAnsweredProblemsResponse getAllWrongAnsweredProblemInUnit(
            long userId,
            long unitId
    ) {
        UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByUnitId(unitId);

        List<ProblemDetailResponse> problemDetailResponses = wrongAnsweredNoteService.getAllWrongAnsweredProblemInUnit(userId, unitId);

        List<ProblemResponse> problemResponses = problemFactory.create(problemDetailResponses);

        return WrongAnsweredProblemsResponse.of(
                unitSummaryResponse,
                problemResponses
        );
    }
}
