package gravit.code.problem.domain;

import gravit.code.problem.dto.response.ProblemDetail;

import java.util.List;
import java.util.Optional;

public interface ProblemRepository {
    List<ProblemDetail> findAllProblemDetailByLessonIdAndUserId(
            long lessonId,
            long userId
    );
    List<ProblemDetail> findBookmarkedProblemDetailByUnitIdAndUserId(
            long unitId,
            long userId
    );
    List<ProblemDetail> findWrongAnsweredProblemsByUnitIdAndUserId(
            long unitId,
            long userId
    );
    Optional<Problem> findById(long problemId);
    boolean existsProblemById(long problemId);
    Problem save(Problem problem);
    void saveAll(List<Problem> problems);
    void deleteById(long problemId);
}