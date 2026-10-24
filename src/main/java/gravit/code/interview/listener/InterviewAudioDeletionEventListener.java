package gravit.code.interview.listener;

import gravit.code.interview.dto.event.InterviewSessionAbandonedEvent;
import gravit.code.interview.service.InterviewAudioDeletionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
public class InterviewAudioDeletionEventListener {

    private final InterviewAudioDeletionService interviewAudioDeletionService;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleSessionAbandoned(InterviewSessionAbandonedEvent event) {
        interviewAudioDeletionService.queueAllBySessionIds(event.voiceSessionIds());
    }
}
