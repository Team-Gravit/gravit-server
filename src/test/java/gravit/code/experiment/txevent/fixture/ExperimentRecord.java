package gravit.code.experiment.txevent.fixture;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 조합별 쓰기가 실제로 커밋됐는지 판별하는 유일한 관찰 대상.
 * IDENTITY는 persist() 시점에 INSERT를 즉시 발행하므로, 커밋되지 않은 쓰기가 유실되는 경로가 그대로 드러난다.
 */
@Entity
@Table(name = "experiment_record")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ExperimentRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String tag;

    private ExperimentRecord(String tag) {
        this.tag = tag;
    }

    public static ExperimentRecord create(String tag) {
        return new ExperimentRecord(tag);
    }
}
