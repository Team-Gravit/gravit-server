package gravit.code.domain.recentLearning.service;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfo;
import gravit.code.domain.chapterProgress.service.ChapterProgressService;
import gravit.code.domain.learning.dto.request.RecentLearningEventDto;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
public class RecentLearningEventHandler {

    private final ChapterProgressService chapterProgressService;
    private final RecentLearningService recentLearningService;

    @Async("learningAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void updateRecentLearning(RecentLearningEventDto recentLearningEventDto){
        ChapterInfo chapterInfo = chapterProgressService.getChapterInfo(recentLearningEventDto.userId(), recentLearningEventDto.chapterId());

        recentLearningService.updateRecentLearning(recentLearningEventDto.userId(), chapterInfo);
    }
}
