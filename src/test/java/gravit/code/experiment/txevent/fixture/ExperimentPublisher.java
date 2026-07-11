package gravit.code.experiment.txevent.fixture;

import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.experiment.txevent.fixture.TraceRecorder.ORIGIN;

/**
 * 원본 트랜잭션 보유자. 프로덕션의 Service 경계에 대응한다.
 */
@RequiredArgsConstructor
public class ExperimentPublisher {

    private final ExperimentRecordRepository experimentRecordRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final TraceRecorder traceRecorder;

    @Transactional
    public void publish(ExperimentEvent event) {
        traceRecorder.capture(ORIGIN);

        // 원본 행을 먼저 저장해야, BEFORE_COMMIT 비동기 리스너가 미커밋 상태를 조회하는 순간을 관찰할 수 있다.
        experimentRecordRepository.save(ExperimentRecord.create(event.originTag()));

        eventPublisher.publishEvent(event);
    }
}
