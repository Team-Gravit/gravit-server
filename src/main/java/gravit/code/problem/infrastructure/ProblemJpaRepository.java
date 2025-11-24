package gravit.code.problem.infrastructure;

import gravit.code.problem.domain.Problem;
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
    List<Problem> findAllByLessonId(@Param("lessonId")long lessonId);

    boolean existsProblemById(long id);
}
