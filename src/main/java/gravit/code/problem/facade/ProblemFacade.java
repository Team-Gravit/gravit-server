package gravit.code.problem.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.factory.ProblemFactory;
import gravit.code.problem.service.ProblemQueryService;
import gravit.code.problem.service.ProblemSubmissionCommandService;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class ProblemFacade {

    private final ProblemQueryService problemQueryService;
    private final ProblemSubmissionCommandService problemSubmissionCommandService;

    private final WrongAnsweredNoteService wrongAnsweredNoteService;

    private final UnitQueryService unitQueryService;
    private final ProblemFactory problemFactory;

    private final TransactionTemplate transactionTemplate;

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

    public void saveProblemSubmission(
            long userId,
            ProblemSubmissionSaveRequest request
    ) {
        List<ProblemSubmissionSaveRequest> requests = List.of(request);

        problemSubmissionCommandService.validateProblemSubmissions(requests);

        transactionTemplate.executeWithoutResult(status -> {
            List<Long> wrongAnsweredProblemIds = problemSubmissionCommandService.saveProblemSubmissions(userId, requests);
            wrongAnsweredProblemIds.forEach(problemId -> wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId));
        });
    }
}
