package gravit.code.interview.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.repository.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class InterviewSessionQueryService {

    private final InterviewSessionRepository interviewSessionRepository;

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
