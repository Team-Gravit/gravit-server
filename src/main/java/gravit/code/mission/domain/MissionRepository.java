package gravit.code.mission.domain;

import org.springframework.data.domain.Pageable;
import java.util.List;
import java.util.Optional;

public interface MissionRepository {
    Optional<Mission> findByUserId(Long userId);
    Mission save(Mission mission);
    List<Mission> findAll(Pageable pageable);
}