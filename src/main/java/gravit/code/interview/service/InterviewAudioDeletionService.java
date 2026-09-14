package gravit.code.interview.service;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.infrastructure.InterviewAudioStorage;
import gravit.code.interview.policy.InterviewAudioKeyPolicy;
import gravit.code.interview.repository.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class InterviewAudioDeletionService {

    private static final String RETRY_QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";

    private final InterviewSessionRepository interviewSessionRepository;

    private final InterviewAudioKeyPolicy interviewAudioKeyPolicy;
    private final InterviewAudioStorage interviewAudioStorage;

    private final RetryEventPublisher retryEventPublisher;

    @Transactional(readOnly = true)
    public List<Long> getVoiceSessionIds(long userId) {
        return interviewSessionRepository.findIdsByUserIdAndInputType(userId, InterviewInputType.VOICE);
    }

    public void deleteAllBySessionIds(List<Long> sessionIds) {
        sessionIds.forEach(this::deleteOrQueueRetry);
    }

    public void deleteBySessionId(long sessionId) {
        interviewAudioStorage.deleteAllByPrefix(interviewAudioKeyPolicy.sessionPrefix(sessionId));
    }

    private void deleteOrQueueRetry(long sessionId) {
        try {
            deleteBySessionId(sessionId);
        } catch (Exception e) {
            log.error("면접 음성 삭제 실패, 재시도 큐 적재: sessionId={}", sessionId, e);
            queueRetry(sessionId);
        }
    }

    private void queueRetry(long sessionId) {
        try {
            retryEventPublisher.publish(RETRY_QUEUE_KEY, Map.of(SESSION_ID_FIELD, String.valueOf(sessionId)));
        } catch (Exception e) {
            log.error("면접 음성 삭제 재시도 적재 실패, 유실: sessionId={}", sessionId, e);
        }
    }
}
