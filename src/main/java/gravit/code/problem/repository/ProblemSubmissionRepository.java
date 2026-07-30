package gravit.code.problem.repository;

import gravit.code.learning.dto.internal.WeakUnitStatDto;
import gravit.code.problem.domain.ProblemSubmission;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface ProblemSubmissionRepository extends JpaRepository<ProblemSubmission, Long> {

    @Modifying
    @Query(value = """
        INSERT INTO problem_submission (user_id, problem_id, is_correct, selected_option_id, submitted_content, created_at, updated_at)
        SELECT :userId, t.problem_id, t.is_correct, t.selected_option_id, t.submitted_content, :now, :now
        FROM jsonb_to_recordset(CAST(:payload AS jsonb))
             AS t(problem_id bigint, is_correct boolean, selected_option_id bigint, submitted_content text)
    """, nativeQuery = true)
    void insertAll(
            @Param("userId") long userId,
            @Param("payload") String payload,
            @Param("now") LocalDateTime now
    );

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
