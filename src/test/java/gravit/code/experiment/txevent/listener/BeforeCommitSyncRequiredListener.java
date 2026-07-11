package gravit.code.experiment.txevent.listener;

import gravit.code.experiment.txevent.fixture.ExperimentEvent;
import gravit.code.experiment.txevent.fixture.ExperimentRecord;
import gravit.code.experiment.txevent.fixture.ExperimentRecordRepository;
import gravit.code.experiment.txevent.fixture.TraceRecorder;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import static gravit.code.experiment.txevent.fixture.ExperimentEvent.LISTENER_FAILURE_MESSAGE;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER;

/**
 * 권장 조합 ① — BEFORE_COMMIT + 동기 + REQUIRED.
 * 원본 트랜잭션에 참여해 하나로 커밋/롤백된다.
 */
@RequiredArgsConstructor
public class BeforeCommitSyncRequiredListener {

    private final ExperimentRecordRepository experimentRecordRepository;
    private final TraceRecorder traceRecorder;

    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    @Transactional(propagation = Propagation.REQUIRED)
    public void handle(ExperimentEvent.BeforeCommitSyncRequired event) {
        traceRecorder.capture(LISTENER);

        experimentRecordRepository.save(ExperimentRecord.create(event.listenerTag()));

        if (event.listenerThrows()) {
            throw new IllegalStateException(LISTENER_FAILURE_MESSAGE);
        }
    }
}
