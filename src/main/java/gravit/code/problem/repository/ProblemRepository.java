package gravit.code.problem.repository;

import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.domain.Problem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ProblemRepository extends JpaRepository<Problem,Long> {

    @Query("""
        SELECT new gravit.code.lesson.dto.response.LessonResponse(p.id, p.problemType, p.question, p.options, p.answer)
        FROM Problem p
        WHERE p.lessonId = :lessonId
        ORDER BY p.id ASC
    """)
    List<LessonResponse> findByLessonId(Long lessonId);
}