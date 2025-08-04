package gravit.code.domain.recentLearning.domain;

import gravit.code.domain.recentLearning.dto.response.RecentLearningSummaryResponse;

import java.util.Optional;

public interface RecentLearningRepository {

    RecentLearning save(RecentLearning recentLearning);

    Optional<RecentLearning> findByUserId(Long userId);

    Optional<RecentLearningSummaryResponse> findRecentLearningSummaryByUserId(Long userId);
}
