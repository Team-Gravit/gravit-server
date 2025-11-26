package gravit.code.problem.infrastructure;

import gravit.code.problem.domain.Problem;
import gravit.code.problem.dto.response.ProblemDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemJpaRepository extends JpaRepository<Problem, Long> {

    @Query("""
        SELECT new gravit.code.problem.dto.response.ProblemDetail(
            p.id,
            p.problemType,
            p.instruction,
            p.content,
            CASE WHEN b.id IS NOT NULL THEN true ELSE false END
        )
        FROM Problem p
        LEFT JOIN Bookmark b ON b.problemId = p.id AND b.userId = :userId
        WHERE p.lessonId = :lessonId
        ORDER BY p.id
    """)
    List<ProblemDetail> findAllProblemDetailByLessonIdAndUserId(
            @Param("lessonId") long lessonId,
            @Param("userId") long userId
    );

    boolean existsProblemById(long id);

}
