package gravit.code.experiment.txevent.fixture;

/**
 * 조합마다 이벤트 타입을 분리한다. 5개 리스너가 한 이벤트를 공유하면 전부 발화해 조합을 격리할 수 없다.
 */
public interface ExperimentEvent {

    String LISTENER_FAILURE_MESSAGE = "listener failed";

    String originTag();

    String listenerTag();

    boolean listenerThrows();

    record BeforeCommitSyncRequired(
            String originTag,
            String listenerTag,
            boolean listenerThrows
    ) implements ExperimentEvent {}

    record AfterCommitSyncNewTx(
            String originTag,
            String listenerTag,
            boolean listenerThrows
    ) implements ExperimentEvent {}

    record AfterCommitAsyncNewTx(
            String originTag,
            String listenerTag,
            boolean listenerThrows
    ) implements ExperimentEvent {}

    record AfterCommitSyncRequired(
            String originTag,
            String listenerTag,
            boolean listenerThrows
    ) implements ExperimentEvent {}

    record BeforeCommitAsyncNewTx(
            String originTag,
            String listenerTag,
            boolean listenerThrows
    ) implements ExperimentEvent {}
}
