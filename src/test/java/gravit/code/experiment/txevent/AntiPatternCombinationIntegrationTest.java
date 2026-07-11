package gravit.code.experiment.txevent;

import gravit.code.experiment.txevent.fixture.ExecutionTrace;
import gravit.code.experiment.txevent.fixture.ExperimentEvent;
import gravit.code.experiment.txevent.fixture.ExperimentGate;
import gravit.code.experiment.txevent.fixture.ExperimentPublisher;
import gravit.code.experiment.txevent.fixture.ExperimentRecordRepository;
import gravit.code.experiment.txevent.fixture.ExperimentRecordWriter;
import gravit.code.experiment.txevent.fixture.TraceRecorder;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import java.time.Duration;

import static gravit.code.experiment.txevent.ExperimentFixtureConfig.EXPERIMENT_ASYNC_THREAD_PREFIX;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.GATE_HELD_UNTIL_LISTENER_READ;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER_ENTRY;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER_WRITE_VISIBLE_IN_SAME_TX;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.ORIGIN;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.ORIGIN_VISIBLE_TO_LISTENER;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.awaitility.Awaitility.await;

/**
 * 안티패턴 조합 검증. "부작용이 실제로 나는지"를 관찰한다.
 */
@Tag("experiment")
@TCSpringBootTest
@Import(ExperimentFixtureConfig.class)
class AntiPatternCombinationIntegrationTest {

    private static final String ORIGIN_TAG = "origin-record";
    private static final String LISTENER_TAG = "listener-record";
    private static final Duration AWAIT_TIMEOUT = Duration.ofSeconds(3);

    @Autowired
    private ExperimentPublisher experimentPublisher;

    @Autowired
    private ExperimentRecordRepository experimentRecordRepository;

    @Autowired
    private TraceRecorder traceRecorder;

    @Autowired
    private ExperimentGate experimentGate;

    @BeforeEach
    void setUp() {
        traceRecorder.reset();

        // 리셋하지 않으면 이전 테스트가 열어둔 래치 때문에 게이트가 즉시 통과되어 관찰 창이 닫힌다.
        experimentGate.reset();
    }

    @AfterEach
    void printTraces() {
        traceRecorder.traces().values().forEach(trace -> System.out.println("[TRACE] " + trace));
        traceRecorder.flags().forEach((key, value) -> System.out.println("[FLAG] " + key + " = " + value));
        traceRecorder.errors().forEach((label, error) -> System.out.println("[ERROR] " + label + " -> " + error));
    }

    @Nested
    @DisplayName("AFTER_COMMIT + 동기 + REQUIRED 조합에서 (안티패턴)")
    class AfterCommitSyncRequired {

        @Test
        void 리스너의_쓰기가_INSERT조차_발행되지_못한_채_예외_하나_없이_사라진다() {
            // given: 리스너는 예외를 던지지 않는다
            ExperimentEvent event = new ExperimentEvent.AfterCommitSyncRequired(ORIGIN_TAG, LISTENER_TAG, false);

            // when: 호출자는 아무 이상도 감지하지 못한다
            assertThatCode(() -> experimentPublisher.publish(event)).doesNotThrowAnyException();

            // then
            ExecutionTrace origin = traceRecorder.trace(ORIGIN);
            ExecutionTrace listener = traceRecorder.trace(LISTENER);

            assertSoftly(softly -> {
                // Spring은 트랜잭션이 살아있다 하고, Hibernate는 이미 끝났다 한다
                softly.assertThat(listener.actualTransactionActive()).isTrue();
                softly.assertThat(listener.hibernateTransactionInProgress()).isFalse();
                softly.assertThat(origin.hibernateTransactionInProgress()).isTrue();

                // 그래서 identity insert가 지연되고 auto-flush도 없다 → INSERT 미발행
                softly.assertThat(traceRecorder.flag(LISTENER_WRITE_VISIBLE_IN_SAME_TX)).isFalse();

                // 롤백이 아니라 ActionQueue에서 증발. 예외조차 없다
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isTrue();
                softly.assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isFalse();
                softly.assertThat(traceRecorder.error(LISTENER)).isEmpty();

                // 새 트랜잭션이 아니라 죽은 원본에 올라탔다
                softly.assertThat(listener.entityManagerId()).isEqualTo(origin.entityManagerId());
                softly.assertThat(listener.threadName()).isEqualTo(origin.threadName());

                // 함정: 트랜잭션명만 새것처럼 갱신된다
                softly.assertThat(listener.transactionName()).isNotEqualTo(origin.transactionName());
                softly.assertThat(listener.transactionName()).contains(ExperimentRecordWriter.class.getSimpleName());
                softly.assertThat(listener.synchronizationActive()).isTrue();
            });
        }

        @Test
        void 리스너_진입_시점의_스레드에는_커밋이_끝난_원본_트랜잭션이_그대로_남아있다() {
            // given
            ExperimentEvent event = new ExperimentEvent.AfterCommitSyncRequired(ORIGIN_TAG, LISTENER_TAG, false);

            // when
            experimentPublisher.publish(event);

            // then: 아직 어떤 @Transactional도 거치지 않은, 리스너 메서드 진입 직후의 스레드 상태
            ExecutionTrace origin = traceRecorder.trace(ORIGIN);
            ExecutionTrace listenerEntry = traceRecorder.trace(LISTENER_ENTRY);

            assertSoftly(softly -> {
                // 동기화는 이미 해제됐다 (triggerAfterCompletion이 invokeAfterCompletion 직전에 clearSynchronization)
                softly.assertThat(listenerEntry.synchronizationActive()).isFalse();

                // 그런데 Spring은 트랜잭션이 아직 살아있다고 보고한다. cleanupAfterCompletion이 뒤에 실행되기 때문이다.
                // 이 어긋난 창이 바로 REQUIRED가 올라타는 "죽은 트랜잭션"이다.
                softly.assertThat(listenerEntry.actualTransactionActive()).isTrue();
                softly.assertThat(listenerEntry.transactionName()).isEqualTo(origin.transactionName());
                softly.assertThat(listenerEntry.entityManagerId()).isEqualTo(origin.entityManagerId());

                // 정작 Hibernate는 이미 트랜잭션이 끝났다고 본다. 이 불일치가 쓰기 유실의 근본 원인이다.
                softly.assertThat(listenerEntry.hibernateTransactionInProgress()).isFalse();
            });
        }
    }

    @Nested
    @DisplayName("BEFORE_COMMIT + 비동기 + REQUIRES_NEW 조합에서 (안티패턴)")
    class BeforeCommitAsyncNewTx {

        @Test
        void 커밋_전에_실행되지만_별도_트랜잭션이라_원본의_미커밋_데이터를_보지_못한다() {
            // given
            ExperimentEvent event = new ExperimentEvent.BeforeCommitAsyncNewTx(ORIGIN_TAG, LISTENER_TAG, false);

            // when: 게이트 리스너가 원본 스레드를 doCommit 직전에 붙잡아, 비동기 리스너가 조회할 창을 연다.
            // publish()는 동기 호출이라 반환 시점에 원본은 이미 커밋되어 있다.
            experimentPublisher.publish(event);

            // 리스너의 자기 트랜잭션이 커밋될 때까지 기다린다. 순서를 만드는 건 이 await가 아니라 게이트다.
            await().atMost(AWAIT_TIMEOUT).untilAsserted(() ->
                    assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isTrue());

            // then
            ExecutionTrace origin = traceRecorder.trace(ORIGIN);
            ExecutionTrace listener = traceRecorder.trace(LISTENER);

            assertSoftly(softly -> {
                // 전제: 게이트가 타임아웃이 아니라 리스너 신호로 풀렸다 → 조회 시점에 원본은 미커밋이었다
                softly.assertThat(traceRecorder.flag(GATE_HELD_UNTIL_LISTENER_READ)).isTrue();

                // 핵심: BEFORE_COMMIT인데도 원본 행이 보이지 않는다 (②③에서는 true였다)
                softly.assertThat(traceRecorder.flag(ORIGIN_VISIBLE_TO_LISTENER)).isFalse();

                // 스레드도 트랜잭션도 커넥션도 전부 별개다
                softly.assertThat(listener.threadName()).isNotEqualTo(origin.threadName());
                softly.assertThat(listener.threadName()).startsWith(EXPERIMENT_ASYNC_THREAD_PREFIX);
                softly.assertThat(listener.entityManagerId()).isNotEqualTo(origin.entityManagerId());

                // 원본과 리스너가 각자 따로 커밋된다 (원자성 없음)
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isTrue();
            });
        }

        @Test
        void 리스너가_예외를_던져도_원본_트랜잭션을_롤백시키지_못한다() {
            // given
            ExperimentEvent event = new ExperimentEvent.BeforeCommitAsyncNewTx(ORIGIN_TAG, LISTENER_TAG, true);

            // when & then: 예외가 원본 스레드에 닿지 못한다 (①은 원본까지 롤백시켰다)
            assertThatCode(() -> experimentPublisher.publish(event)).doesNotThrowAnyException();

            await().atMost(AWAIT_TIMEOUT).untilAsserted(() ->
                    assertThat(traceRecorder.error(LISTENER)).containsInstanceOf(IllegalStateException.class));

            assertSoftly(softly -> {
                // 전제: 예외는 원본이 커밋되기 전에 터졌다 (게이트가 리스너 신호로 풀렸으므로)
                softly.assertThat(traceRecorder.flag(GATE_HELD_UNTIL_LISTENER_READ)).isTrue();

                // 그런데도 원본은 그대로 커밋된다 → "원본 개입" 보장이 사라졌다
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isTrue();

                // 리스너의 새 트랜잭션만 롤백된다
                softly.assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isFalse();
            });
        }
    }
}
