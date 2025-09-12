package gravit.code.recentLearning.listener;

import gravit.code.progress.dto.response.ChapterSummaryResponse;
import gravit.code.progress.service.ChapterProgressService;
import gravit.code.learning.dto.request.RecentLearningEvent;
import gravit.code.recentLearning.service.RecentLearningService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Log4j2
@Component
@RequiredArgsConstructor
public class RecentLearningEventListener {

    private final ChapterProgressService chapterProgressService;
    private final RecentLearningService recentLearningService;

    @Async("learningAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void updateRecentLearning(RecentLearningEvent recentLearningEventDto){
        try{
            ChapterSummaryResponse chapterSummaryResponse = chapterProgressService.getChapterSummary(recentLearningEventDto.chapterId(), recentLearningEventDto.userId());

            recentLearningService.updateRecentLearning(recentLearningEventDto.userId(), chapterSummaryResponse);
        }catch(Exception e){
            log.error("Exception occurred while updating recentLearning with {}", e.getMessage());
        }
    }
}
