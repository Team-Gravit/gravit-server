package gravit.code.problemProgress.repository;

import gravit.code.problemProgress.domain.ProblemProgress;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProblemProgressRepository extends JpaRepository<ProblemProgress, Long> {
}
