package gravit.code.recentLearning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.recentLearning.domain.RecentLearningRepository;
import gravit.code.recentLearning.dto.response.RecentLearningSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RecentLearningService {

    private final RecentLearningRepository recentLearningRepository;

    public RecentLearningSummaryResponse getRecentLearningSummary(Long userId) {
        return recentLearningRepository.findRecentLearningSummaryByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.RECENT_LEARNING_INFO_NOT_FOUND));
    }
}
