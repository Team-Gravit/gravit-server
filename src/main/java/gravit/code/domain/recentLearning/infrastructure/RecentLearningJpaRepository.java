package gravit.code.domain.recentLearning.infrastructure;

import gravit.code.domain.recentLearning.domain.RecentLearning;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RecentLearningJpaRepository extends JpaRepository<RecentLearning,Long> {
    Optional<RecentLearning> findByUserId(Long userId);
}
