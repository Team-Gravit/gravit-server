package gravit.code.mission.infrastructure;

import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MissionRepositoryImpl implements MissionRepository {
    private final MissionJpaRepository missionJpaRepository;

    @Override
    public Optional<Mission> findByUserId(Long userId){
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
}
