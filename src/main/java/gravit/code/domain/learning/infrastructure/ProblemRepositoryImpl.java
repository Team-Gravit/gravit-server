package gravit.code.domain.learning.infrastructure;

import gravit.code.domain.learning.domain.Problem;
import gravit.code.domain.learning.domain.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

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

}
