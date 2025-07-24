package gravit.code.domain.problem.domain;

import gravit.code.domain.problem.dto.response.ProblemInfo;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemRepository {
    List<ProblemInfo> findAllProblemsByLessonId(@Param("lessonId") Long lessonId);
    Problem save(Problem problem);
}