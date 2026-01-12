package gravit.code.lesson.repository;

import gravit.code.learning.dto.common.LearningIds;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.dto.response.LessonSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LessonRepository extends JpaRepository<Lesson, Long> {

    @Query("""
        SELECT new gravit.code.learning.dto.common.LearningIds(c.id, u.id, l.id)
        FROM Lesson l
        INNER JOIN Unit u ON u.id = l.unitId
        INNER JOIN Chapter c ON c.id = u.chapterId
        WHERE l.id = :lessonId
    """)
    Optional<LearningIds> findLearningIdsByLessonId(@Param("lessonId")long lessonId);

    @Query("""
        SELECT COUNT(l.id)
        FROM Chapter c
        JOIN Unit u ON u.chapterId = c.id
        JOIN Lesson l ON l.unitId = u.id
        WHERE c.id = :chapterId
    """)
    int countTotalLessonByChapterId(@Param("chapterId") long chapterId);

    @Query("""
        SELECT COUNT(l.id)
        FROM Unit u
        JOIN Lesson l ON l.unitId = u.id
        WHERE u.id = :unitId
    """)
    int countTotalLessonByUnitId(@Param("unitId") long unitId);

    @Query("""
        SELECT new gravit.code.lesson.dto.response.LessonSummary(
          l.id,
          l.title,
          (SELECT COUNT(p.id) FROM Problem p WHERE p.lessonId = l.id),
          CASE WHEN ls.id IS NOT NULL THEN true ELSE false END
        )
        FROM Lesson l
        LEFT JOIN LessonSubmission ls ON ls.lessonId = l.id AND ls.userId = :userId
        WHERE l.unitId = :unitId
    """)
    List<LessonSummary> findAllLessonSummaryByUnitId(
            @Param("unitId") long unitId,
            @Param("userId") long userId
    );

}
