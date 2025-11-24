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
    public List<Problem> findAllProblemByLessonId(long lessonId){
        return problemJpaRepository.findAllByLessonId(lessonId);
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