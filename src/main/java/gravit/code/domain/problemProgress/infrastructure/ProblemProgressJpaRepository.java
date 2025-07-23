package gravit.code.domain.problemProgress.infrastructure;

import gravit.code.domain.problemProgress.domain.ProblemProgress;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProblemProgressJpaRepository extends JpaRepository<ProblemProgress, Long> {
}
