package gravit.code.interview.listener;

import gravit.code.interview.dto.event.InterviewTranscriptionRequestedEvent;
import gravit.code.interview.facade.InterviewTranscriptionFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
public class InterviewTranscriptionEventListener {

    private final InterviewTranscriptionFacade interviewTranscriptionFacade;

    @Async("interviewTranscriptionAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleTranscriptionRequested(InterviewTranscriptionRequestedEvent event) {
        interviewTranscriptionFacade.transcribe(event.answerId(), event.audioKey());
    }
}
