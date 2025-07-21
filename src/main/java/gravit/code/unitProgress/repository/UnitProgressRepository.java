package gravit.code.unitProgress.repository;

import gravit.code.unitProgress.domain.UnitProgress;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UnitProgressRepository extends JpaRepository<UnitProgress,Long> {
    UnitProgress findByUnitIdAndUserId(Long unitId, Long userId);
}
