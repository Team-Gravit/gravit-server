package gravit.code.problem.repository;

import gravit.code.problem.domain.ProblemSubmission;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProblemSubmissionRepository extends JpaRepository<ProblemSubmission, Long> {
}
