package gravit.code.mission.repository;

import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MissionRepository extends JpaRepository<Mission, Long> {

    List<Mission> findAllByStatus(MissionStatus status);
}
