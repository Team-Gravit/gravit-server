package gravit.code.experiment.txevent.listener;

import gravit.code.experiment.txevent.fixture.ExperimentEvent;
import gravit.code.experiment.txevent.fixture.ExperimentRecordWriter;
import gravit.code.experiment.txevent.fixture.TraceRecorder;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import static gravit.code.experiment.txevent.fixture.ExperimentEvent.LISTENER_FAILURE_MESSAGE;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER_ENTRY;

/**
 * 안티패턴 ④ — AFTER_COMMIT + 동기 + REQUIRED.
 * <p>
 * 이 메서드에 {@code @Transactional(propagation = REQUIRED)}를 직접 붙이면
 * {@code RestrictedTransactionalEventListenerFactory}가 컨텍스트 기동을 거부한다(Spring 6.1+).
 * 그래서 REQUIRED는 리스너가 호출하는 {@link ExperimentRecordWriter} 쪽에 둔다.
 * 가드는 리스너의 어노테이션만 보므로 이 형태는 통과하고, 안티패턴은 그대로 성립한다.
 * <p>
 * AFTER_COMMIT 시점엔 {@code EntityManagerHolder}가 아직 언바인드되지 않아
 * ({@code doCleanupAfterCompletion}은 콜백 이후 실행) {@code isExistingTransaction()}이 참이다.
 * REQUIRED는 새 트랜잭션을 열지 않고 <b>이미 커밋이 끝난 원본 트랜잭션에 그대로 참여</b>한다.
 * 두 번째 커밋은 일어나지 않으므로 여기서의 쓰기는 커넥션 반납과 함께 사라진다.
 */
@RequiredArgsConstructor
public class AfterCommitSyncRequiredListener {

    private final ExperimentRecordWriter experimentRecordWriter;
    private final TraceRecorder traceRecorder;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handle(ExperimentEvent.AfterCommitSyncRequired event) {
        try {
            // @Transactional을 거치기 전, 죽은 트랜잭션이 남긴 스레드 상태를 그대로 찍는다.
            traceRecorder.capture(LISTENER_ENTRY);

            experimentRecordWriter.write(LISTENER, event.listenerTag());

            if (event.listenerThrows()) {
                throw new IllegalStateException(LISTENER_FAILURE_MESSAGE);
            }
        } catch (Exception e) {
            // write() 자체가 죽은 트랜잭션에서 예외를 던질 가능성도 있어, 무엇이 터지든 기록만 하고 재던진다.
            // 어차피 invokeAfterCompletion이 삼키므로 호출자는 아무것도 알 수 없다.
            traceRecorder.captureError(LISTENER, e);
            throw e;
        }
    }
}
