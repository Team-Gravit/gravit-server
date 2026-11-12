package gravit.code.admin.repository;

import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.domain.staging.StagingLabel;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StagingLabelRepository extends JpaRepository<StagingLabel, Long> {

    Optional<StagingLabel> findByLabel(String label);
    Page<StagingLabel> findByStatus(
            LabelStatus status,
            Pageable pageable
    );
    long countByStatus(LabelStatus status);
}
