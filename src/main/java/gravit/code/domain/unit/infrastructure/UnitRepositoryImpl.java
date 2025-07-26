package gravit.code.domain.unit.infrastructure;

import gravit.code.domain.unit.domain.Unit;
import gravit.code.domain.unit.domain.UnitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class UnitRepositoryImpl implements UnitRepository {

    private final UnitJpaRepository unitJpaRepository;

    @Override
    public Unit save(Unit unit) {
        return unitJpaRepository.save(unit);
    }

    @Override
    public Long getTotalLessonsByUnitId(Long unitId) {
        return unitJpaRepository.getTotalLessonsByUnitId(unitId);
    }
}
