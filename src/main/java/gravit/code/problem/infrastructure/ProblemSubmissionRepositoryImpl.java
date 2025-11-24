package gravit.code.problem.infrastructure;

import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.domain.ProblemSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ProblemSubmissionRepositoryImpl implements ProblemSubmissionRepository {

    private final ProblemSubmissionJpaRepository problemSubmissionJpaRepository;

    @Override
    public List<ProblemSubmission> findByIdInIdsAndUserId(
            List<Long> problemIds,
            long userId
    ) {
        return problemSubmissionJpaRepository.findByIdInIdsAndUserId(problemIds, userId);
    }

    @Override
    public Optional<ProblemSubmission> findByProblemIdAndUserId(
            long problemId,
            long userId
    ) {
        return problemSubmissionJpaRepository.findByProblemIdAndUserId(problemId, userId);
    }

    @Override
    public List<ProblemSubmission> saveAll(List<ProblemSubmission> problemSubmissions){
        return problemSubmissionJpaRepository.saveAll(problemSubmissions);
    }
}
