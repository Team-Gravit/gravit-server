package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.ProblemSubmission;
import gravit.code.learning.domain.ProblemSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ProblemSubmissionRepositoryImpl implements ProblemSubmissionRepository {

    private final ProblemSubmissionJpaRepository problemSubmissionJpaRepository;

    @Override
    public List<ProblemSubmission> saveAll(List<ProblemSubmission> problemSubmissions){
        return problemSubmissionJpaRepository.saveAll(problemSubmissions);
    }

    @Override
    public List<ProblemSubmission> findByIdInIdsAndUserId(List<Long> problemIds, long userId) {
        return problemSubmissionJpaRepository.findByIdInIdsAndUserId(problemIds, userId);
    }
}
