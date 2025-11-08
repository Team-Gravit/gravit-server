package gravit.code.learning.domain;

import java.util.List;
import java.util.Optional;

public interface UnitRepository {
    Unit save(Unit unit);
    Optional<Unit> findById(Long unitId);
    void saveAll(List<Unit> units);
}
