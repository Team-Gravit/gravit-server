package gravit.code.problem.domain;

import java.util.List;
import java.util.Optional;

public interface ProblemSubmissionRepository {
    List<ProblemSubmission> findByIdInIdsAndUserId(
            List<Long> problemIds,
            long userId
    );
    Optional<ProblemSubmission> findByProblemIdAndUserId(
            long problemId,
            long userId
    );
    List<ProblemSubmission> saveAll(List<ProblemSubmission> problemSubmissions);
    void save(ProblemSubmission problemSubmission);
}
