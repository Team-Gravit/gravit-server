package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Unit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UnitJpaRepository extends JpaRepository<Unit, Long> {
}
