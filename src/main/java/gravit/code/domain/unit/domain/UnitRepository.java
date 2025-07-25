package gravit.code.domain.unit.domain;

public interface UnitRepository {
    Unit save(Unit unit);
    Long getTotalLessonsByUnitId(Long unitId);
}
