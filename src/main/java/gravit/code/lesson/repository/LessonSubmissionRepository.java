package gravit.code.lesson.repository;

import gravit.code.chapter.dto.internal.ChapterSolvedStatDto;
import gravit.code.lesson.domain.LessonSubmission;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface LessonSubmissionRepository extends JpaRepository<LessonSubmission, Long> {

    @Query("""
        SELECT COUNT(DISTINCT ls.lessonId)
        FROM LessonSubmission ls
        WHERE ls.userId = :userId
    """)
    long countDistinctLessonByUserId(@Param("userId") long userId);

    @Query("""
        SELECT COUNT(DISTINCT l.id)
        FROM LessonSubmission ls
        JOIN Lesson l ON l.id = ls.lessonId
        JOIN Unit u ON u.id = l.unitId
        WHERE u.chapterId = :chapterId AND ls.userId = :userId
    """)
    int countSolvedLessonByChapterIdAndUserId(
            @Param("chapterId") long chapterId,
            @Param("userId") long userId
    );

    @Query("""
        SELECT COUNT(DISTINCT l.id)
        FROM LessonSubmission ls
        JOIN Lesson l ON l.id = ls.lessonId
        WHERE l.unitId = :unitId AND ls.userId = :userId
    """)
    int countSolvedLessonByUnitIdAndUserId(
            @Param("unitId") long unitId,
            @Param("userId") long userId
    );

    @Query("""
        SELECT COUNT(ls.id)
        FROM LessonSubmission ls
        WHERE ls.lessonId = :lessonId AND ls.userId = :userId
    """)
    int countLessonSubmissionByLessonIdAndUserId(
            @Param("lessonId") long lessonId,
            @Param("userId") long userId
    );

    boolean existsByLessonIdAndUserId(
            long lessonId,
            long userId
    );

    @Query(value = """
            SELECT CAST(CEIL(CUME_DIST() OVER (ORDER BY solved_count DESC) * 100) AS INTEGER)
            FROM (
                SELECT u.id AS user_id, COUNT(DISTINCT ls.lesson_id) AS solved_count
                FROM users u
                LEFT JOIN lesson_submission ls ON ls.user_id = u.id
                WHERE u.deleted_at IS NULL
                GROUP BY u.id
            ) ranked
            WHERE user_id = :userId
            """, nativeQuery = true)
    Optional<Integer> findLearningRateTopPercent(@Param("userId") long userId);

    @Query("""
        SELECT COALESCE(SUM(ls.learningTime), 0)
        FROM LessonSubmission ls
        WHERE ls.userId = :userId
    """)
    int getTotalLearningTime(@Param("userId") long userId);

    @Query("""
        SELECT COALESCE(CEIL(AVG(ls.accuracy)), 0)
        FROM LessonSubmission ls
        WHERE ls.userId = :userId
    """)
    int getAverageAccuracy(@Param("userId") long userId);

    @Query(value = """
        SELECT CAST(EXTRACT(HOUR FROM created_at) AS INTEGER) AS hour
        FROM lesson_submission
        WHERE user_id = :userId AND created_at IS NOT NULL
        GROUP BY hour
        ORDER BY COUNT(*) DESC, hour ASC
        LIMIT 1
    """, nativeQuery = true)
    Optional<Integer> getPeakLearningHour(@Param("userId") long userId);

    @Query("""
        SELECT new gravit.code.chapter.dto.internal.ChapterSolvedStatDto(
            c.id, c.title, COUNT(DISTINCT l.id)
        )
        FROM LessonSubmission ls
        JOIN Lesson l ON l.id = ls.lessonId
        JOIN Unit u ON u.id = l.unitId
        JOIN Chapter c ON c.id = u.chapterId
        WHERE ls.userId = :userId
          AND ls.createdAt >= :weekStart
          AND ls.createdAt < :nextWeekStart
        GROUP BY c.id, c.title
        ORDER BY COUNT(DISTINCT l.id) DESC, c.id ASC
    """)
    List<ChapterSolvedStatDto> findTopChaptersByUserIdInWeek(
            @Param("userId") long userId,
            @Param("weekStart") LocalDateTime weekStart,
            @Param("nextWeekStart") LocalDateTime nextWeekStart,
            Pageable pageable
    );

    @Query("""
        SELECT COUNT(DISTINCT ls.lessonId)
        FROM LessonSubmission ls
        WHERE ls.userId = :userId
          AND ls.createdAt >= :weekStart
          AND ls.createdAt < :nextWeekStart
    """)
    long countSolvedLessonsByUserIdInWeek(
            @Param("userId") long userId,
            @Param("weekStart") LocalDateTime weekStart,
            @Param("nextWeekStart") LocalDateTime nextWeekStart
    );
}
