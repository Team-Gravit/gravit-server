package gravit.code.domain.recentLearning.domain;

import java.util.Optional;

public interface RecentLearningRepository {

    RecentLearning save(RecentLearning recentLearning);
    Optional<RecentLearning> findByUserId(Long userId);
}
