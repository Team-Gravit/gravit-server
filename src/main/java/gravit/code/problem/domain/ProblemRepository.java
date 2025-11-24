package gravit.code.problem.domain;

import java.util.List;
import java.util.Optional;

public interface ProblemRepository {
    List<Problem> findAllProblemByLessonId(long lessonId);
    Optional<Problem> findById(long problemId);
    boolean existsProblemById(long problemId);
    Problem save(Problem problem);
    void saveAll(List<Problem> problems);
    void deleteById(long problemId);
}