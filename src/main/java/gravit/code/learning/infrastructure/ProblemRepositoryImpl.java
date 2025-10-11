package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ProblemRepositoryImpl implements ProblemRepository {

    private final ProblemJpaRepository problemJpaRepository;

    @Override
    public Problem save(Problem problem) {
        return problemJpaRepository.save(problem);
    }

    @Override
    public List<Problem> findAllProblemByLessonId(Long lessonId){
        return problemJpaRepository.findAllByLessonId(lessonId);
    }

    @Override
    public boolean existsProblemById(Long problemId){
        return problemJpaRepository.existsProblemById(problemId);
    }

    @Override
    public Optional<Problem> findById(Long problemId){
        return problemJpaRepository.findById(problemId);
    }

    @Override
    public void deleteById(Long problemId){
        problemJpaRepository.deleteById(problemId);
    }

    @Override
    public void saveAll(List<Problem> problems) {
        problemJpaRepository.saveAll(problems);
    }
}