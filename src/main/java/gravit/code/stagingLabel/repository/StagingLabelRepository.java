package gravit.code.stagingLabel.repository;

import gravit.code.stagingLabel.domain.StagingLabel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface StagingLabelRepository extends JpaRepository<StagingLabel, Long> {
    @Query("""
        SELECT count(sl)
        FROM StagingLabel sl
        WHERE sl.labelStatus = 'PENDING'
    """)
    long countPendingLabel();
}
