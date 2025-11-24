package gravit.code.unit.infrastructure;

import gravit.code.unit.domain.Unit;
import gravit.code.unit.dto.response.UnitSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UnitJpaRepository extends JpaRepository<Unit, Long> {

    @Query("""
        SELECT new gravit.code.unit.dto.response.UnitSummary(u.id, u.title, u.description)
        FROM Unit u
        WHERE u.chapterId = :chapterId
    """)
    List<UnitSummary> findAllUnitSummaryByChapterId(@Param("chapterId") long chapterId);

    @Query("""
        SELECT new gravit.code.unit.dto.response.UnitSummary(u.id, u.title, u.description)
        FROM Unit u
        JOIN Lesson l ON l.unitId = u.id
        WHERE l.id = :lessonId
    """)
    Optional<UnitSummary> findUnitSummaryByLessonId(@Param("lessonId") long lessonId);

    @Query("""
        SELECT new gravit.code.unit.dto.response.UnitSummary(u.id, u.title, u.description)
        FROM Unit u
        WHERE u.id = :unitId
    """)
    Optional<UnitSummary> findUnitSummaryById(@Param("unitId")long unitId);
}
