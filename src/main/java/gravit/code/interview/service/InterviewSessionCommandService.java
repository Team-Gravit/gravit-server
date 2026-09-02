package gravit.code.interview.service;

import gravit.code.global.event.InterviewSessionGradingRequestedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.repository.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class InterviewSessionCommandService {

    private static final InterviewInputType SUPPORTED_INPUT_TYPE = InterviewInputType.TEXT;

    private final InterviewSessionRepository interviewSessionRepository;

    private final ApplicationEventPublisher publisher;

    @Transactional(readOnly = true)
    public void validateCreatable(
            long userId,
            InterviewSessionCreateRequest request
    ) {
        if (request.inputType() != SUPPORTED_INPUT_TYPE) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_INPUT_TYPE_NOT_SUPPORTED);
        }

        InterviewSession.validateModeTechStack(request.mode(), request.techStackId());

        if (interviewSessionRepository.existsByUserIdAndStatus(userId, InterviewSessionStatus.IN_PROGRESS)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_ALREADY_IN_PROGRESS);
        }
    }

    @Transactional
    public long createSession(
            long userId,
            InterviewSessionCreateRequest request
    ) {
        InterviewSession session = InterviewSession.create(
                userId,
                request.mode(),
                request.inputType(),
                request.techStackId(),
                request.level()
        );

        return interviewSessionRepository.save(session).getId();
    }

    @Transactional(readOnly = true)
    public void validateAnswerable(
            long userId,
            long sessionId,
            InterviewInputType inputType
    ) {
        InterviewSession session = getOwnedSession(userId, sessionId);

        validateInProgress(session);

        if (session.getInputType() != inputType) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH);
        }
    }

    @Transactional
    public InterviewSessionStatusResponse startGrading(
            long userId,
            long sessionId
    ) {
        InterviewSession session = getOwnedSession(userId, sessionId);

        validateInProgress(session);

        session.startGrading();

        publisher.publishEvent(new InterviewSessionGradingRequestedEvent(sessionId, userId));

        return InterviewSessionStatusResponse.create(sessionId, session.getStatus());
    }

    @Transactional
    public InterviewSessionStatusResponse abandon(
            long userId,
            long sessionId
    ) {
        InterviewSession session = getOwnedSession(userId, sessionId);

        validateInProgress(session);

        session.abandon();

        return InterviewSessionStatusResponse.create(sessionId, session.getStatus());
    }

    private InterviewSession getOwnedSession(
            long userId,
            long sessionId
    ) {
        InterviewSession session = interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND));

        if (session.getUserId() != userId) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED);
        }

        return session;
    }

    private static void validateInProgress(InterviewSession session) {
        if (session.getStatus() != InterviewSessionStatus.IN_PROGRESS) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }
    }
}
