package gravit.code.learning.domain;

import java.util.List;
import java.util.Optional;

public interface ProblemRepository {
    Problem save(Problem problem);
    List<Problem> findAllProblemByLessonId(Long lessonId);
    boolean existsProblemById(Long problemId);
    Optional<Problem> findById(Long problemId);
    void deleteById(Long problemId);
}