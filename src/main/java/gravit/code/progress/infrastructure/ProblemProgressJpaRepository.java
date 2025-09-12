package gravit.code.progress.infrastructure;

import gravit.code.progress.domain.ProblemProgress;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProblemProgressJpaRepository extends JpaRepository<ProblemProgress, Long> {
}
