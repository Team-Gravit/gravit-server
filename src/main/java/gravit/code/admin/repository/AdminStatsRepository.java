package gravit.code.admin.repository;

import gravit.code.admin.dto.internal.UnitStatRowDto;
import gravit.code.unit.domain.Unit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AdminStatsRepository extends JpaRepository<Unit, Long> {

    @Query("""
            SELECT new gravit.code.admin.dto.internal.UnitStatRowDto(
                u.id, u.title, COUNT(DISTINCT ls.userId)
            )
            FROM Unit u
            LEFT JOIN Lesson l ON l.unitId = u.id
            LEFT JOIN LessonSubmission ls ON ls.lessonId = l.id
            WHERE u.chapterId = :chapterId
            GROUP BY u.id, u.title
            ORDER BY u.id
    """)
    List<UnitStatRowDto> findUnitStatsByChapterId(@Param("chapterId") long chapterId);
}
