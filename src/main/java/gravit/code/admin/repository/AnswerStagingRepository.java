package gravit.code.admin.repository;

import gravit.code.admin.domain.staging.AnswerStaging;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AnswerStagingRepository extends JpaRepository<AnswerStaging, Long> {
    List<AnswerStaging> findByLabelOrderById(String label);
    List<AnswerStaging> findByProblemIdInOrderById(List<Long> problemIds);
}
