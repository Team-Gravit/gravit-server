package gravit.code.learning.domain;

import java.util.List;

public interface ProblemSubmissionRepository {
    List<ProblemSubmission> findByIdInIdsAndUserId(
            List<Long> problemIds,
            long userId
    );
    List<ProblemSubmission> saveAll(List<ProblemSubmission> problemSubmissions);
}
