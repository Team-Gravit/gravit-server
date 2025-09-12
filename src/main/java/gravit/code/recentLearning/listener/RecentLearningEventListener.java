package gravit.code.recentLearning.listener;

import gravit.code.progress.dto.response.ChapterSummaryResponse;
import gravit.code.progress.service.ChapterProgressService;
import gravit.code.recentLearning.domain.RecentLearning;
import gravit.code.recentLearning.domain.RecentLearningRepository;
import gravit.code.recentLearning.dto.common.InitRecentLearningEvent;
import gravit.code.recentLearning.dto.common.UpdateRecentLearningEvent;
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
    private final RecentLearningRepository recentLearningRepository;

    @Async("learningAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void updateRecentLearning(UpdateRecentLearningEvent recentLearningEvent){
        try{
            ChapterSummaryResponse chapterSummaryResponse = chapterProgressService.getChapterSummary(recentLearningEvent.chapterId(), recentLearningEvent.userId());

            RecentLearning recentLearning = recentLearningRepository.findByUserId(recentLearningEvent.userId())
                    .orElseGet(() -> RecentLearning.init(recentLearningEvent.userId()));

            recentLearning.update(chapterSummaryResponse);

            recentLearningRepository.save(recentLearning);
        }catch(Exception e){
            log.error("Exception occurred while updating recentLearning with {}", e.getMessage());
        }
    }

    @Async("learningAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void initRecentLearning(InitRecentLearningEvent initRecentLearningEvent){
        RecentLearning recentLearning = RecentLearning.init(initRecentLearningEvent.userId());

        recentLearningRepository.save(recentLearning);
    }
}
