package gravit.code.experiment.txevent;

import gravit.code.experiment.txevent.fixture.ExecutionTrace;
import gravit.code.experiment.txevent.fixture.ExperimentEvent;
import gravit.code.experiment.txevent.fixture.ExperimentPublisher;
import gravit.code.experiment.txevent.fixture.ExperimentRecordRepository;
import gravit.code.experiment.txevent.fixture.TraceRecorder;
import gravit.code.experiment.txevent.listener.AfterCommitAsyncNewTxListener;
import gravit.code.experiment.txevent.listener.AfterCommitSyncNewTxListener;
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
import static gravit.code.experiment.txevent.fixture.ExperimentEvent.LISTENER_FAILURE_MESSAGE;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.ORIGIN;
import static gravit.code.experiment.txevent.fixture.TraceRecorder.ORIGIN_VISIBLE_TO_LISTENER;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.awaitility.Awaitility.await;

/**
 * 권장 조합 검증.
 * <p>
 * 테스트 메서드에 {@code @Transactional}을 붙이면 롤백되어 AFTER_COMMIT이 발화하지 않고,
 * 검증 조회도 같은 트랜잭션 안에서 이뤄져 "실제로 커밋됐는가"를 판별할 수 없다. 절대 붙이지 마라.
 */
@Tag("experiment")
@TCSpringBootTest
@Import(ExperimentFixtureConfig.class)
class RecommendedCombinationIntegrationTest {

    private static final String ORIGIN_TAG = "origin-record";
    private static final String LISTENER_TAG = "listener-record";
    private static final Duration AWAIT_TIMEOUT = Duration.ofSeconds(3);

    @Autowired
    private ExperimentPublisher experimentPublisher;

    @Autowired
    private ExperimentRecordRepository experimentRecordRepository;

    @Autowired
    private TraceRecorder traceRecorder;

    @BeforeEach
    void setUp() {
        traceRecorder.reset();
    }

    @AfterEach
    void printTraces() {
        traceRecorder.traces().values().forEach(trace -> System.out.println("[TRACE] " + trace));
        traceRecorder.flags().forEach((key, value) -> System.out.println("[FLAG] " + key + " = " + value));
        traceRecorder.errors().forEach((label, error) -> System.out.println("[ERROR] " + label + " -> " + error));
    }

    @Nested
    @DisplayName("BEFORE_COMMIT + 동기 + REQUIRED 조합에서")
    class BeforeCommitSyncRequired {

        @Test
        void 리스너가_정상_동작하면_원본과_리스너의_쓰기가_같은_트랜잭션에서_함께_커밋된다() {
            // given
            ExperimentEvent event = new ExperimentEvent.BeforeCommitSyncRequired(ORIGIN_TAG, LISTENER_TAG, false);

            // when
            experimentPublisher.publish(event);

            // then
            ExecutionTrace origin = traceRecorder.trace(ORIGIN);
            ExecutionTrace listener = traceRecorder.trace(LISTENER);

            assertSoftly(softly -> {
                // 데이터 잔존: 원본과 리스너의 쓰기가 모두 살아남는다
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isTrue();
                softly.assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isTrue();

                // 트랜잭션 경계: 트랜잭션명이 원본 그대로 → 새 트랜잭션이 아니라 원본에 참여했다
                softly.assertThat(listener.transactionName()).isEqualTo(origin.transactionName());
                softly.assertThat(listener.actualTransactionActive()).isTrue();

                // 같은 EntityManager를 공유한다 (④와 동일). 결정적 차이는 그 트랜잭션이 아직 살아있다는 것이다.
                softly.assertThat(listener.entityManagerId()).isEqualTo(origin.entityManagerId());
                softly.assertThat(listener.hibernateTransactionInProgress()).isTrue();

                // 스레드 경계: 위임 없이 요청 스레드에서 그대로 실행된다
                softly.assertThat(listener.threadName()).isEqualTo(origin.threadName());
            });
        }

        @Test
        void 리스너가_예외를_던지면_원본_트랜잭션까지_함께_롤백된다() {
            // given
            ExperimentEvent event = new ExperimentEvent.BeforeCommitSyncRequired(ORIGIN_TAG, LISTENER_TAG, true);

            // when & then: 예외가 요청 스레드로 전파된다
            assertThatThrownBy(() -> experimentPublisher.publish(event))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessage(LISTENER_FAILURE_MESSAGE);

            // 데이터 잔존: 원본까지 함께 사라진다 (원자성)
            assertSoftly(softly -> {
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isFalse();
                softly.assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isFalse();
            });
        }
    }

    @Nested
    @DisplayName("AFTER_COMMIT + 동기 + REQUIRES_NEW 조합에서")
    class AfterCommitSyncNewTx {

        @Test
        void 리스너가_정상_동작하면_원본과_별개인_새_트랜잭션에서_커밋된다() {
            // given
            ExperimentEvent event = new ExperimentEvent.AfterCommitSyncNewTx(ORIGIN_TAG, LISTENER_TAG, false);

            // when
            experimentPublisher.publish(event);

            // then
            ExecutionTrace origin = traceRecorder.trace(ORIGIN);
            ExecutionTrace listener = traceRecorder.trace(LISTENER);

            assertSoftly(softly -> {
                // 데이터 잔존: 원본과 리스너의 쓰기가 모두 살아남는다
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isTrue();
                softly.assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isTrue();

                // 트랜잭션 경계: 트랜잭션명이 리스너 메서드로 바뀐다 → 원본을 중단하고 새 트랜잭션이 열렸다
                softly.assertThat(listener.transactionName()).isNotEqualTo(origin.transactionName());
                softly.assertThat(listener.transactionName())
                        .contains(AfterCommitSyncNewTxListener.class.getSimpleName());
                softly.assertThat(listener.actualTransactionActive()).isTrue();

                // 원본을 중단(suspend)하고 새 EntityManager를 바인딩했다 → ④와 갈리는 지점
                softly.assertThat(listener.entityManagerId()).isNotEqualTo(origin.entityManagerId());
                softly.assertThat(listener.hibernateTransactionInProgress()).isTrue();

                // 원본이 이미 커밋된 뒤에 실행되므로, 별도 트랜잭션에서도 원본 행이 보인다
                softly.assertThat(traceRecorder.flag(ORIGIN_VISIBLE_TO_LISTENER)).isTrue();

                // 스레드 경계: 위임 없이 요청 스레드에서 그대로 실행된다
                softly.assertThat(listener.threadName()).isEqualTo(origin.threadName());
            });
        }

        @Test
        void 리스너가_예외를_던져도_원본은_커밋된_채로_남고_예외는_요청_스레드에_닿지_않는다() {
            // given
            ExperimentEvent event = new ExperimentEvent.AfterCommitSyncNewTx(ORIGIN_TAG, LISTENER_TAG, true);

            // when & then: AFTER_COMMIT 리스너는 afterCompletion 콜백에서 실행되고,
            // TransactionSynchronizationUtils.invokeAfterCompletion이 Throwable을 잡아 ERROR 로그만 남긴다.
            assertThatCode(() -> experimentPublisher.publish(event)).doesNotThrowAnyException();

            assertSoftly(softly -> {
                // 원본은 이미 커밋되어 되돌릴 수 없다 → 리스너 실패가 원본에 영향을 주지 못한다
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isTrue();

                // 리스너의 새 트랜잭션만 롤백된다
                softly.assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isFalse();

                // 예외는 분명히 발생했으나 호출자에게 전달되지 않았다 (조용히 삼켜짐)
                softly.assertThat(traceRecorder.error(LISTENER))
                        .containsInstanceOf(IllegalStateException.class);
            });
        }
    }

    @Nested
    @DisplayName("AFTER_COMMIT + 비동기 + REQUIRES_NEW 조합에서")
    class AfterCommitAsyncNewTx {

        @Test
        void 리스너가_정상_동작하면_별도_스레드의_새_트랜잭션에서_커밋된다() {
            // given
            ExperimentEvent event = new ExperimentEvent.AfterCommitAsyncNewTx(ORIGIN_TAG, LISTENER_TAG, false);

            // when: 요청 스레드는 리스너를 기다리지 않고 즉시 반환한다
            experimentPublisher.publish(event);

            // then: 리스너 행이 보이면 리스너의 새 트랜잭션이 커밋된 것이다
            await().atMost(AWAIT_TIMEOUT).untilAsserted(() ->
                    assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isTrue());

            ExecutionTrace origin = traceRecorder.trace(ORIGIN);
            ExecutionTrace listener = traceRecorder.trace(LISTENER);

            assertSoftly(softly -> {
                // 데이터 잔존: 원본과 리스너의 쓰기가 모두 살아남는다
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isTrue();

                // 트랜잭션 경계: 별도 스레드에는 물려받을 트랜잭션이 없으므로 새 트랜잭션이 열린다
                softly.assertThat(listener.transactionName()).isNotEqualTo(origin.transactionName());
                softly.assertThat(listener.transactionName())
                        .contains(AfterCommitAsyncNewTxListener.class.getSimpleName());
                softly.assertThat(listener.actualTransactionActive()).isTrue();

                // 스레드가 다르니 EntityManager도 커넥션도 별개다
                softly.assertThat(listener.entityManagerId()).isNotEqualTo(origin.entityManagerId());
                softly.assertThat(listener.hibernateTransactionInProgress()).isTrue();

                // 원본이 이미 커밋된 뒤에 실행되므로, 다른 커넥션에서도 원본 행이 보인다
                softly.assertThat(traceRecorder.flag(ORIGIN_VISIBLE_TO_LISTENER)).isTrue();

                // 스레드 경계: @Async 어드바이저가 @Transactional보다 바깥이라 트랜잭션도 풀 스레드에서 열린다
                softly.assertThat(listener.threadName()).isNotEqualTo(origin.threadName());
                softly.assertThat(listener.threadName()).startsWith(EXPERIMENT_ASYNC_THREAD_PREFIX);
            });
        }

        @Test
        void 리스너가_예외를_던져도_원본은_커밋된_채로_남고_예외는_요청_스레드에_닿지_않는다() {
            // given
            ExperimentEvent event = new ExperimentEvent.AfterCommitAsyncNewTx(ORIGIN_TAG, LISTENER_TAG, true);

            // when & then: 이미 스레드가 갈라졌으므로 예외가 호출자에게 닿을 길이 없다
            assertThatCode(() -> experimentPublisher.publish(event)).doesNotThrowAnyException();

            await().atMost(AWAIT_TIMEOUT).untilAsserted(() ->
                    assertThat(traceRecorder.error(LISTENER)).containsInstanceOf(IllegalStateException.class));

            assertSoftly(softly -> {
                // 원본은 이미 커밋되어 리스너 실패의 영향을 받지 않는다
                softly.assertThat(experimentRecordRepository.existsByTag(ORIGIN_TAG)).isTrue();

                // 리스너의 새 트랜잭션만 롤백된다
                softly.assertThat(experimentRecordRepository.existsByTag(LISTENER_TAG)).isFalse();

                // 예외는 비동기 풀 스레드에서 발생했다
                softly.assertThat(traceRecorder.trace(LISTENER).threadName())
                        .startsWith(EXPERIMENT_ASYNC_THREAD_PREFIX);
            });
        }
    }
}
