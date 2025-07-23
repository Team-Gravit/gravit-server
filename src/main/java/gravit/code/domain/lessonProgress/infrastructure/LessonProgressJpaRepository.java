package gravit.code.domain.lessonProgress.infrastructure;

import gravit.code.domain.lessonProgress.domain.LessonProgress;
import gravit.code.domain.lessonProgress.dto.response.LessonInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LessonProgressJpaRepository extends JpaRepository<LessonProgress, Long> {
    Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId);

    boolean existsByLessonIdAndUserId(Long lessonId, Long userId);

    @Query("""
        SELECT new gravit.code.domain.lessonProgress.dto.response.LessonInfo(l.id, l.name, lp.isCompleted)
        FROM Lesson l
        LEFT JOIN LessonProgress lp ON l.id = lp.lessonId AND lp.userId = :userId
        WHERE l.unitId = :unitId
        ORDER BY l.id
    """)
    List<LessonInfo> findLessonsWithProgressByUnitId(@Param("userId") Long userId, @Param("unitId") Long unitId);
}
