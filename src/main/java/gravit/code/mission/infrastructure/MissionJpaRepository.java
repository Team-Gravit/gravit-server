package gravit.code.mission.infrastructure;

import gravit.code.mission.domain.Mission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MissionJpaRepository extends JpaRepository<Mission, Long> {
    Optional<Mission> findByUserId(Long userId);
}
