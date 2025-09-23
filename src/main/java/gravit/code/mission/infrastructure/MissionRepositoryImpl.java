package gravit.code.mission.infrastructure;

import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionRepository;
import gravit.code.mission.dto.MissionSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MissionRepositoryImpl implements MissionRepository {
    private final MissionJpaRepository missionJpaRepository;

    @Override
    public Optional<Mission> findByUserId(long userId){
        return missionJpaRepository.findByUserId(userId);
    }

    @Override
    public Mission save(Mission mission){
        return missionJpaRepository.save(mission);
    }

    @Override
    public List<Mission> findAll(Pageable pageable) {
        return missionJpaRepository.findAll(pageable).getContent();
    }

    @Override
    public Optional<MissionSummary> findMissionSummaryByUserId(long userId){
        return missionJpaRepository.findMissionSummaryByUserId(userId);
    }
}
