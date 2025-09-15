package gravit.code.learning.domain;

import java.util.List;

public interface ProblemRepository {
    Problem save(Problem problem);
    List<Problem> findAllProblemByLessonId(Long lessonId);
    boolean existsProblemById(Long problemId);
}