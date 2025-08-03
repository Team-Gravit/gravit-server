package gravit.code.domain.unit.domain;

import java.util.Optional;

public interface UnitRepository {
    Optional<Unit> findById(Long unitId);
    Unit save(Unit unit);
    Long getTotalLessonsByUnitId(Long unitId);
}
