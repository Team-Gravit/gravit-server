package gravit.code.domain.learning.infrastructure;

import gravit.code.domain.learning.domain.Problem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemJpaRepository extends JpaRepository<Problem, Long> {

    @Query("""
        SELECT p
        FROM Problem p
        WHERE p.lessonId = :lessonId
        ORDER BY p.id
    """)
    List<Problem> findAllByLessonId(@Param("lessonId")Long lessonId);
}
