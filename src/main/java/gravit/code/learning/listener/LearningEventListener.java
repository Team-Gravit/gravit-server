package gravit.code.learning.listener;

import gravit.code.global.event.badge.StreakUpdatedEvent;
import gravit.code.learning.dto.common.StreakDto;
import gravit.code.learning.dto.event.CreateLearningEvent;
import gravit.code.learning.dto.event.UpdateLearningEvent;
import gravit.code.learning.service.LearningService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Log4j2
@Component
@RequiredArgsConstructor
public class LearningEventListener {

    private final LearningService learningService;

    private final ApplicationEventPublisher publisher;

    @Async("learningAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void updateLearning(UpdateLearningEvent event){
        try{
            StreakDto streakDto = learningService.updateLearningStatus(event.userId(), event.chapterId());

            if(streakDto.before() != streakDto.after())
                publisher.publishEvent(new StreakUpdatedEvent(event.userId(), streakDto.after()));

        }catch (Exception e){
            log.error("Exception occurred while updating Learning with {}", e.getMessage());
        }
    }

    @Async("learningAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void createLearning(CreateLearningEvent event){
        try{
            learningService.createLearning(event.userId());
        }catch (Exception e){
            log.error("Exception occurred while creating Learning with {}", e.getMessage());
        }
    }
}
