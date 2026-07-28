package gravit.code.problem.repository;

import gravit.code.learning.dto.internal.WeakUnitStatDto;
import gravit.code.problem.domain.ProblemSubmission;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProblemSubmissionRepository extends JpaRepository<ProblemSubmission, Long> {

    @Query("""
        SELECT new gravit.code.learning.dto.internal.WeakUnitStatDto(
            u.id, u.title, c.title,
            COUNT(DISTINCT CASE WHEN ps.isCorrect = false THEN ps.problemId END),
            COUNT(DISTINCT ps.problemId)
        )
        FROM ProblemSubmission ps
        JOIN Problem p ON p.id = ps.problemId
        JOIN Lesson l ON l.id = p.lessonId
        JOIN Unit u ON u.id = l.unitId
        JOIN Chapter c ON c.id = u.chapterId
        WHERE ps.userId = :userId
        GROUP BY u.id, u.title, c.title
        HAVING COUNT(DISTINCT CASE WHEN ps.isCorrect = false THEN ps.problemId END) > 0
        ORDER BY
            (1.0 * COUNT(DISTINCT CASE WHEN ps.isCorrect = false THEN ps.problemId END) / COUNT(DISTINCT ps.problemId)) DESC,
            COUNT(DISTINCT CASE WHEN ps.isCorrect = false THEN ps.problemId END) DESC,
            u.id ASC
    """)
    List<WeakUnitStatDto> findWeakUnitsByUserId(
            @Param("userId") long userId,
            Pageable pageable
    );
}
