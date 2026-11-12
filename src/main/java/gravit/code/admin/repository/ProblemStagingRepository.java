package gravit.code.admin.repository;

import gravit.code.admin.domain.staging.ProblemStaging;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProblemStagingRepository extends JpaRepository<ProblemStaging, Long> {
    List<ProblemStaging> findByLabelOrderById(String label);
}
