package gravit.code.experiment.txevent.fixture;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ExperimentRecordRepository extends JpaRepository<ExperimentRecord, Long> {

    boolean existsByTag(String tag);
}
