package gravit.code.admin.repository;

import gravit.code.admin.domain.staging.OptionStaging;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OptionStagingRepository extends JpaRepository<OptionStaging, Long> {
    List<OptionStaging> findByLabelOrderById(String label);
    List<OptionStaging> findByProblemIdInOrderById(List<Long> problemIds);
}
