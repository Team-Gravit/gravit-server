package gravit.code.experiment.txevent;

import gravit.code.experiment.txevent.fixture.ExperimentGate;
import gravit.code.experiment.txevent.fixture.ExperimentPublisher;
import gravit.code.experiment.txevent.fixture.ExperimentRecordRepository;
import gravit.code.experiment.txevent.fixture.ExperimentRecordWriter;
import gravit.code.experiment.txevent.fixture.TraceRecorder;
import gravit.code.experiment.txevent.listener.AfterCommitAsyncNewTxListener;
import gravit.code.experiment.txevent.listener.AfterCommitSyncNewTxListener;
import gravit.code.experiment.txevent.listener.AfterCommitSyncRequiredListener;
import gravit.code.experiment.txevent.listener.BeforeCommitAsyncNewTxListener;
import gravit.code.experiment.txevent.listener.BeforeCommitSyncRequiredListener;
import jakarta.persistence.EntityManagerFactory;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

/**
 * {@code @TestConfiguration}은 컴포넌트 스캔에서 제외되므로, 이 설정을 {@code @Import}한 테스트에서만
 * 실험용 리스너가 등록된다. 다른 통합 테스트 컨텍스트를 오염시키지 않는다.
 */
@TestConfiguration(proxyBeanMethods = false)
public class ExperimentFixtureConfig {

    public static final String EXPERIMENT_ASYNC_EXECUTOR = "experimentAsync";
    public static final String EXPERIMENT_ASYNC_THREAD_PREFIX = "ExperimentAsync-";

    private static final int CORE_POOL_SIZE = 2;
    private static final int MAX_POOL_SIZE = 4;
    private static final int QUEUE_CAPACITY = 20;

    @Bean
    public TraceRecorder traceRecorder(EntityManagerFactory entityManagerFactory) {
        return new TraceRecorder(entityManagerFactory);
    }

    @Bean
    public ExperimentGate experimentGate() {
        return new ExperimentGate();
    }

    /**
     * 프로덕션 풀이 아니라 전용 풀을 쓴다. 스레드명 접두사로 스레드 경계를 명확히 단언할 수 있고,
     * ⑤의 래치 핸드셰이크가 프로덕션 풀 포화에 걸려 굶는 일을 막는다.
     */
    @Bean(name = EXPERIMENT_ASYNC_EXECUTOR)
    public Executor experimentAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

        executor.setCorePoolSize(CORE_POOL_SIZE);
        executor.setMaxPoolSize(MAX_POOL_SIZE);
        executor.setQueueCapacity(QUEUE_CAPACITY);
        executor.setThreadNamePrefix(EXPERIMENT_ASYNC_THREAD_PREFIX);
        executor.initialize();

        return executor;
    }

    @Bean
    public ExperimentPublisher experimentPublisher(
            ExperimentRecordRepository experimentRecordRepository,
            ApplicationEventPublisher eventPublisher,
            TraceRecorder traceRecorder
    ) {
        return new ExperimentPublisher(experimentRecordRepository, eventPublisher, traceRecorder);
    }

    @Bean
    public BeforeCommitSyncRequiredListener beforeCommitSyncRequiredListener(
            ExperimentRecordRepository experimentRecordRepository,
            TraceRecorder traceRecorder
    ) {
        return new BeforeCommitSyncRequiredListener(experimentRecordRepository, traceRecorder);
    }

    @Bean
    public AfterCommitSyncNewTxListener afterCommitSyncNewTxListener(
            ExperimentRecordRepository experimentRecordRepository,
            TraceRecorder traceRecorder
    ) {
        return new AfterCommitSyncNewTxListener(experimentRecordRepository, traceRecorder);
    }

    @Bean
    public AfterCommitAsyncNewTxListener afterCommitAsyncNewTxListener(
            ExperimentRecordRepository experimentRecordRepository,
            TraceRecorder traceRecorder
    ) {
        return new AfterCommitAsyncNewTxListener(experimentRecordRepository, traceRecorder);
    }

    /**
     * ④의 {@code @Transactional(REQUIRED)}를 리스너가 아니라 이 빈에 둔다.
     * 리스너에 직접 붙이면 {@code RestrictedTransactionalEventListenerFactory}가 컨텍스트 기동을 거부한다.
     */
    @Bean
    public ExperimentRecordWriter experimentRecordWriter(
            ExperimentRecordRepository experimentRecordRepository,
            TraceRecorder traceRecorder
    ) {
        return new ExperimentRecordWriter(experimentRecordRepository, traceRecorder);
    }

    @Bean
    public AfterCommitSyncRequiredListener afterCommitSyncRequiredListener(
            ExperimentRecordWriter experimentRecordWriter,
            TraceRecorder traceRecorder
    ) {
        return new AfterCommitSyncRequiredListener(experimentRecordWriter, traceRecorder);
    }

    @Bean
    public BeforeCommitAsyncNewTxListener beforeCommitAsyncNewTxListener(
            ExperimentRecordRepository experimentRecordRepository,
            TraceRecorder traceRecorder,
            ExperimentGate experimentGate
    ) {
        return new BeforeCommitAsyncNewTxListener(experimentRecordRepository, traceRecorder, experimentGate);
    }
}
