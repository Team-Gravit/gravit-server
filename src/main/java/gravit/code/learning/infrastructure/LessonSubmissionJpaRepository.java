package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.LessonSubmission;
import gravit.code.learning.dto.response.LessonProgressSummaryResponse;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LessonSubmissionJpaRepository extends JpaRepository<LessonSubmission, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<LessonSubmission> findByLessonIdAndUserId(
            long lessonId,
            long userId
    );

    @Query("""
        SELECT new gravit.code.progress.dto.response.LessonProgressSummaryResponse(l.id, l.name, COALESCE(lp.isCompleted, false))
        FROM Lesson l
        LEFT JOIN LessonSubmission lp ON l.id = lp.lessonId AND lp.userId = :userId
        WHERE l.unitId = :unitId AND EXISTS (SELECT 1 FROM User u WHERE u.id = :userId)
        ORDER BY l.id
    """)
    List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(
            @Param("unitId") long unitId,
            @Param("userId") long userId
    );

    long countByUserId(long userId);

    @Query("""
        SELECT COUNT(DISTINCT l.id)
        FROM Chapter c
        JOIN Unit u ON u.chapterId = c.id
        JOIN Lesson l ON l.unitId = u.id
        JOIN LessonSubmission ls ON ls.lessonId = l.id
        WHERE c.id = :chapterId AND ls.userId = :userId
    """)
    int countSolvedLessonByChapterIdAndUserId(
            @Param("chapterId") long chapterId,
            @Param("userId") long userId
    );

    @Query("""
        SELECT COUNT(DISTINCT l.id)
        FROM Unit u
        JOIN Lesson l ON l.unitId = u.id
        JOIN LessonSubmission ls ON ls.lessonId = l.id
        WHERE u.id = :unitId AND ls.userId = :userId
    """)
    int countSolvedLessonByUnitIdAndUserId(
            long unitId,
            long userId
    );

    @Query("""
        SELECT COUNT(ls.id)
        From LessonSubmission ls
        WHERE ls.lessonId = :lessonId AND ls.userId = :userId
    """)
    int countLessonSubmissionByLessonIdAndUserId(
            @Param("lessonId") long lessonId,
            @Param("userId") long userId
    );

    boolean existsByLessonIdAndUserId(long lessonId, long userId);
}
