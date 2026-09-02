package gravit.code.interview.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.dto.request.InterviewAnswerSubmitRequest;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.response.InterviewAnswerSubmitResponse;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.service.InterviewAnswerCommandService;
import gravit.code.interview.service.InterviewSessionCommandService;
import gravit.code.interviewQuestion.dto.internal.SelectedInterviewQuestion;
import gravit.code.interviewQuestion.service.InterviewCategoryQueryService;
import gravit.code.interviewQuestion.service.InterviewQuestionSelectionService;
import gravit.code.interviewTechStack.service.InterviewTechStackQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class InterviewSessionFacade {

    private static final InterviewInputType SUBMIT_INPUT_TYPE = InterviewInputType.TEXT;

    private final InterviewSessionCommandService interviewSessionCommandService;
    private final InterviewAnswerCommandService interviewAnswerCommandService;

    private final InterviewCategoryQueryService interviewCategoryQueryService;
    private final InterviewQuestionSelectionService interviewQuestionSelectionService;

    private final InterviewTechStackQueryService interviewTechStackQueryService;

    private final TransactionTemplate transactionTemplate;

    public InterviewSessionCreateResponse createSession(
            long userId,
            InterviewSessionCreateRequest request
    ) {
        interviewSessionCommandService.validateCreatable(userId, request);

        List<Long> categoryIds = resolveCategoryIds(request);
        boolean coverAllCategories = request.mode() == InterviewMode.JOB_SPECIFIC;

        List<SelectedInterviewQuestion> questions = interviewQuestionSelectionService.selectQuestions(
                categoryIds,
                request.level(),
                coverAllCategories
        );

        return transactionTemplate.execute(status -> {
            long sessionId = interviewSessionCommandService.createSession(userId, request);

            List<Long> answerIds = interviewAnswerCommandService.createPendingAnswers(
                    sessionId,
                    questions.stream().map(SelectedInterviewQuestion::questionId).toList()
            );

            return InterviewSessionCreateResponse.create(sessionId, answerIds, questions);
        });
    }

    public InterviewAnswerSubmitResponse submitAnswer(
            long userId,
            long sessionId,
            int displayOrder,
            InterviewAnswerSubmitRequest request
    ) {
        interviewSessionCommandService.validateAnswerable(userId, sessionId, SUBMIT_INPUT_TYPE);

        return interviewAnswerCommandService.submit(sessionId, displayOrder, request.content());
    }

    private List<Long> resolveCategoryIds(InterviewSessionCreateRequest request) {
        if (request.mode() == InterviewMode.COMMON_CS) {
            return interviewCategoryQueryService.getCategoryIds(InterviewMode.COMMON_CS);
        }

        return interviewTechStackQueryService.getCategoryIdsByTechStack(request.techStackId());
    }
}
