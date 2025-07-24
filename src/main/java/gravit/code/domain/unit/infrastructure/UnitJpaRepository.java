package gravit.code.domain.unit.infrastructure;

import gravit.code.domain.unit.domain.Unit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UnitJpaRepository extends JpaRepository<Unit, Long> {
}
