package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Unit;
import gravit.code.learning.domain.UnitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class UnitRepositoryImpl implements UnitRepository {

    private final UnitJpaRepository unitJpaRepository;

    @Override
    public Unit save(Unit unit) {
        return unitJpaRepository.save(unit);
    }

    @Override
    public Optional<Unit> findById(Long unitId) {
        return unitJpaRepository.findById(unitId);
    }

}
