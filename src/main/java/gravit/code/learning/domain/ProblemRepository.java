package gravit.code.learning.domain;

import gravit.code.learning.dto.response.ProblemResponse;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemRepository {
    Problem save(Problem problem);
    List<ProblemResponse> findAllProblemByLessonId(@Param("lessonId") Long lessonId);
}