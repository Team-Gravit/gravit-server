package gravit.code.recentLearning.infrastructure;

import gravit.code.recentLearning.domain.RecentLearning;
import gravit.code.recentLearning.dto.response.RecentLearningSummaryResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface RecentLearningJpaRepository extends JpaRepository<RecentLearning,Long> {
    Optional<RecentLearning> findByUserId(Long userId);

    @Query("""
        SELECT new gravit.code.recentLearning.dto.response.RecentLearningSummaryResponse(rl.chapterId, rl.chapterName, rl.totalUnits, rl.completedUnits)
        FROM RecentLearning rl
        WHERE rl.userId = :userId
    """)
    Optional<RecentLearningSummaryResponse> findRecentLearningSummaryByUserId(@Param("userId") Long userId);
}
