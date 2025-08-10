package gravit.code.domain.recentLearning.service;

import gravit.code.domain.chapterProgress.dto.response.ChapterSummaryResponse;
import gravit.code.domain.recentLearning.domain.RecentLearning;
import gravit.code.domain.recentLearning.domain.RecentLearningRepository;
import gravit.code.domain.recentLearning.dto.response.RecentLearningSummaryResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RecentLearningService {

    private final RecentLearningRepository recentLearningRepository;

    // 유저 온보딩 완료시 호출 메소드
    @Async("learningAsync")
    public void initRecentLearning(Long userId){
        RecentLearning recentLearning = RecentLearning.init(userId);

        recentLearningRepository.save(recentLearning);
    }

    public void updateRecentLearning(Long userId, ChapterSummaryResponse chapterSummaryResponse){
        RecentLearning recentLearning = recentLearningRepository.findByUserId(userId)
                .orElseGet(() -> RecentLearning.init(userId));

        recentLearning.update(chapterSummaryResponse);
        recentLearningRepository.save(recentLearning);
    }

    public RecentLearningSummaryResponse getRecentLearningSummary(Long userId) {
        return recentLearningRepository.findRecentLearningSummaryByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.RECENT_LEARNING_INFO_NOT_FOUND));
    }
}
