package gravit.code.recentLearning.domain;

import gravit.code.recentLearning.dto.response.RecentLearningSummaryResponse;

import java.util.Optional;

public interface RecentLearningRepository {

    RecentLearning save(RecentLearning recentLearning);

    Optional<RecentLearning> findByUserId(Long userId);

    Optional<RecentLearningSummaryResponse> findRecentLearningSummaryByUserId(Long userId);
}
