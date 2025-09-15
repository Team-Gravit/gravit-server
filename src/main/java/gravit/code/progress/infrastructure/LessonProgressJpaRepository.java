package gravit.code.progress.infrastructure;

import gravit.code.progress.domain.LessonProgress;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LessonProgressJpaRepository extends JpaRepository<LessonProgress, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId);

    @Query("""
        SELECT new gravit.code.progress.dto.response.LessonProgressSummaryResponse(l.id, l.name, COALESCE(lp.isCompleted, false))
        FROM Lesson l
        LEFT JOIN LessonProgress lp ON l.id = lp.lessonId AND lp.userId = :userId
        WHERE l.unitId = :unitId AND EXISTS (SELECT 1 FROM User u WHERE u.id = :userId)
        ORDER BY l.id
    """)
    List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(@Param("unitId") Long unitId, @Param("userId") Long userId);
}
