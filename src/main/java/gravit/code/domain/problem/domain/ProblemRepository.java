package gravit.code.domain.problem.domain;

import gravit.code.domain.problem.dto.response.ProblemResponse;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemRepository {
    Problem save(Problem problem);
    List<ProblemResponse> findAllProblemByLessonId(@Param("lessonId") Long lessonId);
}