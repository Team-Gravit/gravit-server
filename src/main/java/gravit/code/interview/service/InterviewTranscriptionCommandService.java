package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.dto.event.InterviewTranscriptionRequestedEvent;
import gravit.code.interview.dto.request.InterviewTranscriptionRequest;
import gravit.code.interview.infrastructure.InterviewAudioStorage;
import gravit.code.interview.policy.InterviewAudioKeyPolicy;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_ANSWER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_EMPTY;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_NOT_UPLOADED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_IN_PROGRESS;

@Service
@RequiredArgsConstructor
public class InterviewTranscriptionCommandService {

    private final InterviewSessionRepository interviewSessionRepository;
    private final InterviewAnswerRepository interviewAnswerRepository;

    private final InterviewAudioKeyPolicy interviewAudioKeyPolicy;
    private final InterviewAudioStorage interviewAudioStorage;

    private final ApplicationEventPublisher publisher;
    private final Clock clock;

    @Transactional
    public void request(
            long userId,
            long sessionId,
            InterviewTranscriptionRequest request
    ) {
        InterviewSession session = interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(INTERVIEW_SESSION_NOT_FOUND));

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(INTERVIEW_SESSION_ACCESS_DENIED);
        }
        if (session.isTextInput()) {
            throw new RestApiException(INTERVIEW_INPUT_TYPE_MISMATCH);
        }
        if (!session.isInProgress()) {
            throw new RestApiException(INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }

        String audioKey = request.audioKey();
        interviewAudioKeyPolicy.validate(sessionId, request.displayOrder(), audioKey);

        long audioContentLength = interviewAudioStorage.findContentLength(audioKey)
                .orElseThrow(() -> new RestApiException(INTERVIEW_AUDIO_NOT_UPLOADED));

        if (audioContentLength == 0) {
            throw new RestApiException(INTERVIEW_AUDIO_EMPTY);
        }

        InterviewAnswer answer = interviewAnswerRepository.findBySessionIdAndDisplayOrder(sessionId, request.displayOrder())
                .orElseThrow(() -> new RestApiException(INTERVIEW_ANSWER_NOT_FOUND));

        answer.requestTranscription(audioKey, LocalDateTime.now(clock));

        publisher.publishEvent(InterviewTranscriptionRequestedEvent.of(answer.getId(), audioKey));
    }

    @Transactional
    public void complete(
            long answerId,
            String transcript
    ) {
        findAnswer(answerId).completeTranscription(transcript);
    }

    @Transactional
    public void fail(long answerId) {
        findAnswer(answerId).failTranscription();
    }

    private InterviewAnswer findAnswer(long answerId) {
        return interviewAnswerRepository.findById(answerId)
                .orElseThrow(() -> new RestApiException(INTERVIEW_ANSWER_NOT_FOUND));
    }
}
