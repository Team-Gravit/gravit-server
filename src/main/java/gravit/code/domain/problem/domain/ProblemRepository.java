package gravit.code.domain.problem.domain;

import gravit.code.domain.lesson.dto.response.LessonResponse;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemRepository {
    List<LessonResponse> findAllProblemsByLessonId(@Param("lessonId") Long lessonId);
}