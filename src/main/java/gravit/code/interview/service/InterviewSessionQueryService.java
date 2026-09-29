package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.dto.internal.InterviewSessionQuestionDto;
import gravit.code.interview.dto.response.InterviewSessionQuestionResponse;
import gravit.code.interview.dto.response.InterviewSessionQuestionsResponse;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.infrastructure.InterviewAudioStorage;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_GRADING;

@Service
@RequiredArgsConstructor
public class InterviewSessionQueryService {

    private final InterviewSessionRepository interviewSessionRepository;
    private final InterviewAnswerRepository interviewAnswerRepository;

    private final InterviewAudioStorage interviewAudioStorage;

    @Transactional(readOnly = true)
    public InterviewSessionStatusResponse getStatus(
            long userId,
            long sessionId
    ) {
        InterviewSession session = findSession(sessionId);

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(INTERVIEW_SESSION_ACCESS_DENIED);
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
            throw new RestApiException(INTERVIEW_SESSION_ACCESS_DENIED);
        }

        List<InterviewSessionQuestionDto> questions = interviewAnswerRepository.findQuestionsBySessionId(sessionId);

        List<InterviewSessionQuestionResponse> responses = questions.stream()
                .map(question -> InterviewSessionQuestionResponse.of(question, issueAudioUrl(question.audioKey())))
                .toList();

        return InterviewSessionQuestionsResponse.of(sessionId, responses);
    }

    @Transactional(readOnly = true)
    public InterviewSession getGradingSession(long sessionId) {
        InterviewSession session = findSession(sessionId);

        if (!session.isGrading()) {
            throw new RestApiException(INTERVIEW_SESSION_NOT_GRADING);
        }

        return session;
    }

    private String issueAudioUrl(String audioKey) {
        if (audioKey == null) {
            return null;
        }

        return interviewAudioStorage.presignDownload(audioKey);
    }

    private InterviewSession findSession(long sessionId) {
        return interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(INTERVIEW_SESSION_NOT_FOUND));
    }
}
