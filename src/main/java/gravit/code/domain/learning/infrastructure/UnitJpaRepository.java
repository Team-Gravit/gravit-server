package gravit.code.domain.learning.infrastructure;

import gravit.code.domain.learning.domain.Unit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UnitJpaRepository extends JpaRepository<Unit, Long> {
}
