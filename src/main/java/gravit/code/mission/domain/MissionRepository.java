package gravit.code.mission.domain;

import java.util.Optional;

public interface MissionRepository {
    Optional<Mission> findByUserId(Long userId);
    Mission save(Mission mission);
}
