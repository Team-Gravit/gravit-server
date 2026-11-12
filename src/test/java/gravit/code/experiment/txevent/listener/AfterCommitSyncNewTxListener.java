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
import static gravit.code.experiment.txevent.fixture.TraceRecorder.ORIGIN_VISIBLE_TO_LISTENER;

/**
 * 권장 조합 ② — AFTER_COMMIT + 동기 + REQUIRES_NEW.
 * 독립된 새 트랜잭션에서 실행되어 원본에 영향을 주지 않는다.
 * <p>
 * 예외는 요청 스레드로 전파되지 <b>않는다</b>. {@code TransactionalApplicationListenerSynchronization}은
 * {@code afterCommit()}이 아니라 {@code afterCompletion(int)}에 AFTER_COMMIT 처리를 구현하는데,
 * {@code TransactionSynchronizationUtils.invokeAfterCompletion}이 Throwable을 잡아 ERROR 로그만 남기고 삼킨다.
 * (반면 {@code invokeAfterCommit}에는 catch 블록이 없다.)
 */
@RequiredArgsConstructor
public class AfterCommitSyncNewTxListener {

    private final ExperimentRecordRepository experimentRecordRepository;
    private final TraceRecorder traceRecorder;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handle(ExperimentEvent.AfterCommitSyncNewTx event) {
        try {
            traceRecorder.capture(LISTENER);

            // 원본은 이미 커밋됐으므로, 별도 트랜잭션에서도 보인다.
            traceRecorder.putFlag(ORIGIN_VISIBLE_TO_LISTENER, experimentRecordRepository.existsByTag(event.originTag()));

            experimentRecordRepository.save(ExperimentRecord.create(event.listenerTag()));

            if (event.listenerThrows()) {
                throw new IllegalStateException(LISTENER_FAILURE_MESSAGE);
            }
        } catch (Exception e) {
            // 기록 후 재던져, 예외가 삼켜지는 경로 자체를 보존한다.
            traceRecorder.captureError(LISTENER, e);
            throw e;
        }
    }
}
