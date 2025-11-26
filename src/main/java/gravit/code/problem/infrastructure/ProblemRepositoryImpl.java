package gravit.code.problem.infrastructure;

import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemRepository;
import gravit.code.problem.dto.response.ProblemDetail;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ProblemRepositoryImpl implements ProblemRepository {

    private final ProblemJpaRepository problemJpaRepository;

    @Override
    public List<ProblemDetail> findAllProblemDetailByLessonIdAndUserId(
            long lessonId,
            long userId
    ){
        return problemJpaRepository.findAllProblemDetailByLessonIdAndUserId(lessonId,userId);
    }

    @Override
    public Optional<Problem> findById(long problemId){
        return problemJpaRepository.findById(problemId);
    }

    @Override
    public boolean existsProblemById(long problemId){
        return problemJpaRepository.existsProblemById(problemId);
    }

    @Override
    public Problem save(Problem problem) {
        return problemJpaRepository.save(problem);
    }

    @Override
    public void saveAll(List<Problem> problems) {
        problemJpaRepository.saveAll(problems);
    }

    @Override
    public void deleteById(long problemId){
        problemJpaRepository.deleteById(problemId);
    }
}