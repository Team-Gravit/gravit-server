package gravit.code.interview.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.dto.internal.InterviewSessionQuestionDto;
import gravit.code.interview.dto.response.InterviewSessionQuestionResponse;
import gravit.code.interview.dto.response.InterviewSessionQuestionsResponse;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewSessionQueryService {

    private final InterviewSessionRepository interviewSessionRepository;
    private final InterviewAnswerRepository interviewAnswerRepository;

    @Transactional(readOnly = true)
    public InterviewSessionStatusResponse getStatus(
            long userId,
            long sessionId
    ) {
        InterviewSession session = findSession(sessionId);

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED);
        }

        return InterviewSessionStatusResponse.of(session.getId(), session.getStatus());
    }

    @Transactional(readOnly = true)
    public InterviewSessionQuestionsResponse getQuestions(
            long userId,
            long sessionId
    ) {
        InterviewSession session = findSession(sessionId);

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED);
        }

        List<InterviewSessionQuestionDto> questions = interviewAnswerRepository.findQuestionsBySessionId(sessionId);

        return InterviewSessionQuestionsResponse.of(
                sessionId,
                questions.stream()
                        .map(InterviewSessionQuestionResponse::from)
                        .toList()
        );
    }

    @Transactional(readOnly = true)
    public InterviewSession getGradingSession(long sessionId) {
        InterviewSession session = findSession(sessionId);

        if (!session.isGrading()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_GRADING);
        }

        return session;
    }

    private InterviewSession findSession(long sessionId) {
        return interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND));
    }
}
