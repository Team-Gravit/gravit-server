package gravit.code.experiment.txevent.listener;

import gravit.code.experiment.txevent.fixture.ExperimentEvent;
import gravit.code.experiment.txevent.fixture.ExperimentGate;
import gravit.code.experiment.txevent.fixture.ExperimentRecord;
import gravit.code.experiment.txevent.fixture.ExperimentRecordRepository;
import gravit.code.experiment.txevent.fixture.TraceRecorder;
import lombok.RequiredArgsConstructor;
import org.springframework.core.annotation.Order;
import org.springframework.scheduling.annotation.Async;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.concurrent.TimeUnit;

import static gravit.code.experiment.txevent.fixture.ExperimentEvent.LISTENER_FAILURE_MESSAGE;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.GATE_HELD_UNTIL_LISTENER_READ;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.ORIGIN_VISIBLE_TO_LISTENER;

/**
 * 안티패턴 ⑤ — BEFORE_COMMIT + 비동기 + REQUIRES_NEW.
 * <p>
 * 다른 스레드로 위임되는 순간 BEFORE_COMMIT이 약속하는 두 가지가 모두 사라진다.
 * <ul>
 *     <li>"커밋 전 실행" — 실행은 커밋 전이 맞지만, 별도 트랜잭션이라 원본의 미커밋 데이터를 볼 수 없다.</li>
 *     <li>"원본 개입" — 예외를 던져도 원본 스레드에 닿지 못해 롤백을 유발하지 못한다.</li>
 * </ul>
 */
@RequiredArgsConstructor
public class BeforeCommitAsyncNewTxListener {

    private static final long GATE_TIMEOUT_SECONDS = 5L;

    private final ExperimentRecordRepository experimentRecordRepository;
    private final TraceRecorder traceRecorder;
    private final ExperimentGate experimentGate;

    @Order(1)
    @Async("experimentAsync")
    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handle(ExperimentEvent.BeforeCommitAsyncNewTx event) {
        try {
            traceRecorder.capture(LISTENER);

            // 원본은 아직 커밋 전이다. 그러나 별도 스레드의 별도 트랜잭션이라 READ_COMMITTED에서 보이지 않는다.
            traceRecorder.putFlag(ORIGIN_VISIBLE_TO_LISTENER, experimentRecordRepository.existsByTag(event.originTag()));

            experimentRecordRepository.save(ExperimentRecord.create(event.listenerTag()));

            if (event.listenerThrows()) {
                throw new IllegalStateException(LISTENER_FAILURE_MESSAGE);
            }
        } catch (Exception e) {
            traceRecorder.captureError(LISTENER, e);
            throw e;
        } finally {
            experimentGate.signalListenerRead();
        }
    }

    /**
     * {@code @Order(1)}이 비동기 위임 후 즉시 반환하므로, 원본 스레드를 여기서 붙잡아
     * 비동기 리스너가 "원본 미커밋" 상태를 관찰할 창을 연다. {@code @Async}가 없으니 원본 스레드에서 동기 실행된다.
     * <p>
     * 이 메서드는 {@code triggerBeforeCommit} 안에서 실행되므로 {@code doCommit}보다 앞선다.
     * 즉 여기서 대기하는 동안 원본은 확실히 미커밋 상태다.
     */
    @Order(2)
    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    public void holdOriginUncommitted(ExperimentEvent.BeforeCommitAsyncNewTx event) {
        boolean signaledByListener = experimentGate.awaitListenerRead(GATE_TIMEOUT_SECONDS, TimeUnit.SECONDS);

        // 타임아웃으로 풀렸다면 원본이 먼저 커밋됐을 수 있어 관찰이 무의미하다. 테스트가 이 값을 단언한다.
        traceRecorder.putFlag(GATE_HELD_UNTIL_LISTENER_READ, signaledByListener);
    }
}
