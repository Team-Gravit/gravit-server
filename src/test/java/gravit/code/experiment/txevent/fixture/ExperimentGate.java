package gravit.code.experiment.txevent.fixture;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * 안티패턴 ⑤ 전용. 원본 트랜잭션을 미커밋 상태로 붙잡아 둔다.
 * <p>
 * {@code @Async} 리스너는 위임 후 즉시 반환하므로 원본은 곧장 커밋해버린다. 그러면 "커밋 전"이라는
 * 관찰 창 자체가 닫힌다. 뒤 순번의 동기 리스너가 이 래치를 기다려 창을 열어둔다.
 */
public class ExperimentGate {

    private volatile CountDownLatch listenerRead = new CountDownLatch(1);

    public void signalListenerRead() {
        listenerRead.countDown();
    }

    public boolean awaitListenerRead(long timeout, TimeUnit unit) {
        try {
            return listenerRead.await(timeout, unit);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return false;
        }
    }

    public void reset() {
        listenerRead = new CountDownLatch(1);
    }
}
