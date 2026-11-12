package gravit.code.interviewFeedback.listener;

import gravit.code.interview.dto.event.InterviewSubmittedEvent;
import gravit.code.interviewFeedback.facade.InterviewGradingFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
public class InterviewGradingEventListener {

    private final InterviewGradingFacade interviewGradingFacade;

    @Async("interviewGradingAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleInterviewSubmitted(InterviewSubmittedEvent event) {
        interviewGradingFacade.grade(event.sessionId());
    }
}
