package gravit.code.unitProgress.repository;

import gravit.code.unitProgress.domain.UnitProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UnitProgressRepository extends JpaRepository<UnitProgress,Long> {
    Optional<UnitProgress> findByUnitIdAndUserId(Long unitId, Long userId);
}
