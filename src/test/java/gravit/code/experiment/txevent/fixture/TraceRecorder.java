package gravit.code.experiment.txevent.fixture;

import jakarta.persistence.EntityManagerFactory;
import lombok.RequiredArgsConstructor;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 비동기 리스너가 다른 스레드에서 기록하므로 전부 동시성 컬렉션으로 둔다.
 */
@RequiredArgsConstructor
public class TraceRecorder {

    public static final String ORIGIN = "origin";
    public static final String LISTENER = "listener";

    /** 리스너 메서드 진입 직후, 아직 어떤 {@code @Transactional}도 거치지 않은 시점의 스레드 상태. */
    public static final String LISTENER_ENTRY = "listener-entry";

    /** 리스너가 자기 트랜잭션에서 원본 행을 조회할 수 있는지. AFTER_COMMIT이면 true, BEFORE_COMMIT + 별도 트랜잭션이면 false. */
    public static final String ORIGIN_VISIBLE_TO_LISTENER = "originVisibleToListener";

    /**
     * 리스너가 방금 쓴 행이 <b>자기 트랜잭션(=자기 커넥션) 안에서</b> 보이는지.
     * <p>
     * true면 INSERT가 DB에 도달한 뒤 커밋되지 않아 사라진 것이고,
     * false면 INSERT가 <b>발행조차 되지 않은</b> 것이다. 후자가 안티패턴 ④의 실제 거동이다.
     */
    public static final String LISTENER_WRITE_VISIBLE_IN_SAME_TX = "listenerWriteVisibleInSameTx";

    /**
     * 게이트가 타임아웃이 아니라 <b>비동기 리스너의 신호</b>로 풀렸는지 (안티패턴 ⑤).
     * <p>
     * 이 값이 true여야 "리스너가 조회한 시점에 원본은 아직 커밋 전이었다"가 보장된다.
     * false면 게이트가 먼저 만료되어 원본이 커밋됐을 수 있으므로, 그 실행의 관찰은 무의미하다.
     */
    public static final String GATE_HELD_UNTIL_LISTENER_READ = "gateHeldUntilListenerRead";

    private final EntityManagerFactory entityManagerFactory;

    private final Map<String, ExecutionTrace> traces = new ConcurrentHashMap<>();
    private final Map<String, Throwable> errors = new ConcurrentHashMap<>();
    private final Map<String, Boolean> flags = new ConcurrentHashMap<>();

    public void capture(String label) {
        traces.put(label, ExecutionTrace.here(label, entityManagerFactory));
    }

    public void captureError(String label, Throwable error) {
        errors.put(label, error);
    }

    public void putFlag(String key, boolean value) {
        flags.put(key, value);
    }

    public ExecutionTrace trace(String label) {
        return traces.get(label);
    }

    public Optional<Throwable> error(String label) {
        return Optional.ofNullable(errors.get(label));
    }

    public boolean flag(String key) {
        return Boolean.TRUE.equals(flags.get(key));
    }

    public Map<String, ExecutionTrace> traces() {
        return Map.copyOf(traces);
    }

    public Map<String, Boolean> flags() {
        return Map.copyOf(flags);
    }

    public Map<String, Throwable> errors() {
        return Map.copyOf(errors);
    }

    public void reset() {
        traces.clear();
        errors.clear();
        flags.clear();
    }
}
