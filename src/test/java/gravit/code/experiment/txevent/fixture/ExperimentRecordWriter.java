package gravit.code.experiment.txevent.fixture;

import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.experiment.txevent.fixture.TraceRecorder.LISTENER_WRITE_VISIBLE_IN_SAME_TX;

/**
 * {@code @Transactional(REQUIRED)}를 리스너 <b>바깥</b>이 아니라 <b>안쪽</b>(호출되는 서비스)에 두기 위한 fixture.
 * <p>
 * Spring 6.1의 {@code RestrictedTransactionalEventListenerFactory}는 BEFORE_COMMIT이 아닌 리스너 메서드에
 * REQUIRES_NEW/NOT_SUPPORTED가 아닌 {@code @Transactional}이 붙으면 컨텍스트 기동을 거부한다.
 * 그러나 그 가드는 <b>리스너의 어노테이션만</b> 검사할 뿐, 리스너가 무엇을 호출하는지는 보지 못한다.
 * <p>
 * 프로덕션 리스너들이 실제로 이 모양이다 (예: {@code LearningEventListener} → {@code LearningCommandService}).
 * 따라서 안티패턴 ④는 가드를 통과한 채로 그대로 재현된다.
 */
@RequiredArgsConstructor
public class ExperimentRecordWriter {

    private final ExperimentRecordRepository experimentRecordRepository;
    private final TraceRecorder traceRecorder;

    @Transactional(propagation = Propagation.REQUIRED)
    public void write(String label, String tag) {
        traceRecorder.capture(label);

        experimentRecordRepository.save(ExperimentRecord.create(tag));

        // 자기 트랜잭션(=자기 커넥션) 안에서 방금 쓴 행을 조회한다.
        // true면 INSERT가 DB에 실제로 도달했다는 뜻이다. 나중에 밖에서 안 보이면 "쓰였다가 사라진" 것이다.
        traceRecorder.putFlag(LISTENER_WRITE_VISIBLE_IN_SAME_TX, experimentRecordRepository.existsByTag(tag));
    }
}
