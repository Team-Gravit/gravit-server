package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Lesson;
import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface LessonJpaRepository extends JpaRepository<Lesson, Long> {
    @Query("""
        SELECT new gravit.code.learning.dto.LearningIds(c.id, u.id, l.id)
        FROM Lesson l
        INNER JOIN Unit u ON u.id = l.unitId
        INNER JOIN Chapter c ON c.id = u.chapterId
        WHERE l.id = :lessonId
    """)
    LearningIds findLearningIdsByLessonId(@Param("lessonId")long lessonId);

    @Query("""
        SELECT l.name
        FROM Lesson l
        WHERE l.id = :lessonId
    """)
    Optional<String> findLessonNameByLessonId(@Param("lessonId") long lessonId);

    @Query("""
        SELECT new gravit.code.learning.dto.LearningAdditionalInfo(c.id, l.name)
        FROM Lesson l
        INNER JOIN Unit u ON u.id = l.unitId
        INNER JOIN Chapter c ON c.id = u.chapterId
        WHERE l.id = :lessonId
    """)
    Optional<LearningAdditionalInfo> findLearningAdditionalInfoByLessonId(@Param("lessonId") long lessonId);
}
