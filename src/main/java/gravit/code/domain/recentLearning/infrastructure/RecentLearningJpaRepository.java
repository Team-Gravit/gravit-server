package gravit.code.domain.recentLearning.infrastructure;

import gravit.code.domain.recentLearning.domain.RecentLearning;
import gravit.code.domain.recentLearning.dto.response.RecentLearningInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface RecentLearningJpaRepository extends JpaRepository<RecentLearning,Long> {
    Optional<RecentLearning> findByUserId(Long userId);

    @Query("""
        SELECT new gravit.code.domain.recentLearning.dto.response.RecentLearningInfo(rl.chapterId, rl.chapterName, rl.totalUnits, rl.completedUnits)
        FROM RecentLearning rl
        WHERE rl.userId = :userId
    """)
    Optional<RecentLearningInfo> findRecentLearningInfoByUserId(@Param("userId") Long userId);
}
