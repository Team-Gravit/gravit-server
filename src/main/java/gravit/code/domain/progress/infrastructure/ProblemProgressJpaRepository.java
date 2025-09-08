package gravit.code.domain.progress.infrastructure;

import gravit.code.domain.progress.domain.ProblemProgress;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProblemProgressJpaRepository extends JpaRepository<ProblemProgress, Long> {
}
