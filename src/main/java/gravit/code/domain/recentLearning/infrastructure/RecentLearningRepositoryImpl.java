package gravit.code.domain.recentLearning.infrastructure;

import gravit.code.domain.recentLearning.domain.RecentLearning;
import gravit.code.domain.recentLearning.domain.RecentLearningRepository;
import gravit.code.domain.recentLearning.dto.response.RecentLearningInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class RecentLearningRepositoryImpl implements RecentLearningRepository {

    private final RecentLearningJpaRepository recentLearningJpaRepository;

    @Override
    public RecentLearning save(RecentLearning recentLearning) {
        return recentLearningJpaRepository.save(recentLearning);
    }

    @Override
    public Optional<RecentLearning> findByUserId(Long userId) {
        return recentLearningJpaRepository.findByUserId(userId);
    }

    @Override
    public Optional<RecentLearningInfo> findRecentLearningInfoByUserId(Long userId) {
        return recentLearningJpaRepository.findRecentLearningInfoByUserId(userId);
    }
}
