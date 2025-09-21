package gravit.code.mission.domain;

import gravit.code.mission.dto.MissionSummary;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface MissionRepository {
    Optional<Mission> findByUserId(long userId);
    Mission save(Mission mission);
    List<Mission> findAll(Pageable pageable);
    MissionSummary findMissionSummaryByUserId(long userId);
}