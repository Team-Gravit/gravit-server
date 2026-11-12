package gravit.code.experiment.txevent.listener;

import gravit.code.experiment.txevent.fixture.ExperimentEvent;
import gravit.code.experiment.txevent.fixture.ExperimentRecord;
import gravit.code.experiment.txevent.fixture.ExperimentRecordRepository;
import gravit.code.experiment.txevent.fixture.TraceRecorder;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import static gravit.code.experiment.txevent.fixture.ExperimentEvent.LISTENER_FAILURE_MESSAGE;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.ORIGIN_VISIBLE_TO_LISTENER;

/**
 * 권장 조합 ③ — AFTER_COMMIT + 비동기 + REQUIRES_NEW.
 * <p>
 * {@code AsyncAnnotationBeanPostProcessor}가 {@code setBeforeExistingAdvisors(true)}로 등록되므로
 * {@code @Async} 어드바이저가 {@code @Transactional}보다 <b>바깥</b>에 걸린다.
 * 따라서 트랜잭션은 요청 스레드가 아니라 비동기 풀 스레드에서 열린다.
 * <p>
 * 예외는 ②와 마찬가지로 요청 스레드에 닿지 않는다. 다만 이유가 다르다.
 * ②는 {@code invokeAfterCompletion}이 삼키고, ③은 그 이전에 이미 스레드가 갈라져
 * {@code AsyncUncaughtExceptionHandler}가 처리한다.
 */
@RequiredArgsConstructor
public class AfterCommitAsyncNewTxListener {

    private final ExperimentRecordRepository experimentRecordRepository;
    private final TraceRecorder traceRecorder;

    @Async("experimentAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handle(ExperimentEvent.AfterCommitAsyncNewTx event) {
        try {
            traceRecorder.capture(LISTENER);

            // 원본은 이미 커밋됐으므로, 다른 스레드의 다른 커넥션에서도 보인다.
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
