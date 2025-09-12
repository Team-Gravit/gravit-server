package gravit.code.mission.infrastructure;

import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MissionRepositoryImpl implements MissionRepository {
    private final MissionJpaRepository missionJpaRepository;

    @Override
    public Optional<Mission> findByUserId(Long userId){
        return missionJpaRepository.findByUserId(userId);
    }
}
