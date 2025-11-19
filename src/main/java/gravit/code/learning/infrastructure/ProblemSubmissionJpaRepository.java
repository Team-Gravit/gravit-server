package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.ProblemSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemSubmissionJpaRepository extends JpaRepository<ProblemSubmission, Long> {
    @Query("""
        SELECT ps
        FROM ProblemSubmission ps
        WHERE ps.problemId IN (:problemIds) AND ps.userId = :userId
    """)
    List<ProblemSubmission> findByIdInIdsAndUserId(
            @Param("problemIds") List<Long> problemIds,
            @Param("userId") long userId
    );
}
