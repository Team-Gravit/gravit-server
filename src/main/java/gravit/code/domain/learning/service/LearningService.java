package gravit.code.domain.learning.service;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfo;
import gravit.code.domain.chapterProgress.service.ChapterProgressService;
import gravit.code.domain.recentLearning.service.RecentLearningService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LearningService {

    private final RecentLearningService recentLearningService;

    private final ChapterProgressService chapterProgressService;

    @Async("learningAsync")
    public void updateRecentLearning(Long userId, Long chapterId){
        ChapterInfo chapterInfo = chapterProgressService.getChapterInfo(userId, chapterId);

        recentLearningService.updateRecentLearning(userId, chapterInfo);
    }
}
