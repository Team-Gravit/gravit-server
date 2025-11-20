package gravit.code.learning.domain;

import java.util.List;
import java.util.Optional;

public interface ProblemRepository {
    Problem save(Problem problem);
    List<Problem> findAllProblemByLessonId(long lessonId);
    boolean existsProblemById(long problemId);
    Optional<Problem> findById(long problemId);
    void deleteById(long problemId);
    void saveAll(List<Problem> problems);
}