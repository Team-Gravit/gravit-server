package gravit.code.domain.recentLearning.service;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfo;
import gravit.code.domain.recentLearning.domain.RecentLearning;
import gravit.code.domain.recentLearning.domain.RecentLearningRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RecentLearningService {

    private final RecentLearningRepository recentLearningRepository;

    // 유저 온보딩 완료시 호출 메소드
    public void initRecentLearning(Long userId){
        RecentLearning recentLearning = RecentLearning.init(userId);

        recentLearningRepository.save(recentLearning);
    }

    public void updateRecentLearning(Long userId, ChapterInfo chapterInfo){
        RecentLearning recentLearning = recentLearningRepository.findByUserId(userId)
                .orElseGet(() -> RecentLearning.init(userId));

        recentLearning.update(chapterInfo);

        recentLearningRepository.save(recentLearning);
    }

}
