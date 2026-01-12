package gravit.code.bookmark.facade;

import gravit.code.bookmark.service.BookmarkService;
import gravit.code.global.annotation.Facade;
import gravit.code.problem.dto.response.BookmarkedProblemResponse;
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
public class BookmarkFacade {

    private final BookmarkService bookmarkService;
    private final UnitQueryService unitQueryService;
    private final ProblemQueryService problemQueryService;

    @Transactional(readOnly = true)
    public BookmarkedProblemResponse getAllBookmarkedProblemInUnit(
            long userId,
            long unitId
    ){
        UnitSummary unitSummary = unitQueryService.getUnitSummaryByUnitId(unitId);

        List<ProblemDetail> problemDetails = bookmarkService.getAllBookmarkedProblemInUnit(userId, unitId);
        List<ProblemResponse> problemResponses = problemQueryService.getAnswerOrOptionInProblems(problemDetails);

        return BookmarkedProblemResponse.of(
                unitSummary,
                problemResponses
        );
    }
}
