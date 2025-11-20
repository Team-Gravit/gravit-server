package gravit.code.learning.domain;

import java.util.List;

public interface ProblemSubmissionRepository {
    List<ProblemSubmission> saveAll(List<ProblemSubmission> problemSubmissions);
    List<ProblemSubmission> findByIdInIdsAndUserId(List<Long> problemIds, long userId);
}
