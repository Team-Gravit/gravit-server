package gravit.code.interview.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.interview.service.InterviewAudioDeletionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class InterviewAudioDeletionRetryTarget implements RetrySweepTarget {

    private static final String QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";
    private static final int MAX_ATTEMPTS = 10;

    private final InterviewAudioDeletionService interviewAudioDeletionService;

    @Override
    public String queueKey() {
        return QUEUE_KEY;
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        long sessionId = Long.parseLong(fields.get(SESSION_ID_FIELD));

        interviewAudioDeletionService.deleteBySessionId(sessionId);
    }
}
