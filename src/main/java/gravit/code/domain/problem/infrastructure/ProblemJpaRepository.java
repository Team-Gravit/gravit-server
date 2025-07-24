package gravit.code.domain.problem.infrastructure;

import gravit.code.domain.problem.dto.response.ProblemInfo;
import gravit.code.domain.problem.domain.Problem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemJpaRepository extends JpaRepository<Problem, Long> {
    @Query("""
        SELECT new gravit.code.domain.lesson.dto.response.ProblemInfo(p.id, p.problemType, p.question, p.options, p.answer)
        FROM Problem p
        WHERE p.lessonId = :lessonId
        ORDER BY p.id ASC
    """)
    List<ProblemInfo> findAllProblemsByLessonId(@Param("lessonId") Long lessonId);
}
