package gravit.code.domain.unit.infrastructure;

import gravit.code.domain.unit.domain.Unit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UnitJpaRepository extends JpaRepository<Unit, Long> {
    @Query("""
        SELECT u.totalLessons
        FROM Unit u
        WHERE u.id = :unitId
    """)
    Long getTotalLessonsByUnitId(@Param("unitId") Long unitId);
}
