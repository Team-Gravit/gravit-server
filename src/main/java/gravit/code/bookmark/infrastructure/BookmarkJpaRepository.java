package gravit.code.bookmark.infrastructure;

import gravit.code.bookmark.domain.Bookmark;
import gravit.code.problem.dto.response.ProblemDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BookmarkJpaRepository extends JpaRepository<Bookmark, Long> {

    @Modifying
    @Query("""
        DELETE
        FROM Bookmark b
        WHERE b.problemId = :problemId AND b.userId = :userId
    """)
    void deleteByProblemIdAndUserId(
            @Param("problemId") long problemId,
            @Param("userId") long userId
    );

    boolean existsByProblemIdAndUserId(long problemId, long userId);

    @Query("""
        SELECT new gravit.code.problem.dto.response.ProblemDetail(
            p.id,
            p.problemType,
            p.instruction,
            p.content,
            true
        )
        FROM Bookmark b
        JOIN Problem p ON p.id = b.problemId
        JOIN Lesson l ON l.id = p.lessonId
        JOIN Unit u ON u.id = l.unitId
        WHERE u.id = :unitId AND b.userId = :userId
        ORDER BY b.createdAt ASC
    """)
    List<ProblemDetail> findBookmarkedProblemDetailByUnitIdAndUserId(
            @Param("unitId")long unitId,
            @Param("userId")long userId
    );

    @Query("""
        SELECT COUNT(b)
        FROM Bookmark b
        JOIN Problem p ON p.id = b.problemId
        JOIN Lesson l ON l.id = p.lessonId
        JOIN Unit u ON u.id = l.unitId
        WHERE u.id = :unitId AND b.userId = :userId
    """)
    int countByUnitIdAndUserId(
            @Param("unitId")long unitId,
            @Param("userId")long userId
    );
}
