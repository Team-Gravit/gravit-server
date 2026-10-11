package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.dto.response.InterviewTranscriptionResponse;
import gravit.code.interview.dto.response.InterviewTranscriptionsResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class InterviewTranscriptionQueryService {

    private final InterviewSessionRepository interviewSessionRepository;
    private final InterviewAnswerRepository interviewAnswerRepository;

    @Transactional(readOnly = true)
    public InterviewTranscriptionsResponse getTranscriptions(
            long userId,
            long sessionId
    ) {
        InterviewSession session = interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(INTERVIEW_SESSION_NOT_FOUND));

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(INTERVIEW_SESSION_ACCESS_DENIED);
        }
        if (session.isTextInput()) {
            throw new RestApiException(INTERVIEW_INPUT_TYPE_MISMATCH);
        }

        List<InterviewTranscriptionResponse> transcriptions = interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(sessionId).stream()
                .map(InterviewTranscriptionResponse::from)
                .toList();

        return InterviewTranscriptionsResponse.of(sessionId, transcriptions);
    }
}
