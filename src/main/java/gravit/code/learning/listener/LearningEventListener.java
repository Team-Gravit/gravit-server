package gravit.code.learning.listener;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.domain.LearningRepository;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.learning.dto.event.CreateLearningEvent;
import gravit.code.learning.dto.event.UpdateLearningEvent;
import gravit.code.progress.domain.LessonProgressRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Log4j2
@Component
@RequiredArgsConstructor
public class LearningEventListener {

    private final LearningRepository learningRepository;

    private final LessonRepository lessonRepository;
    private final LessonProgressRepository lessonProgressRepository;

    @Async("learningAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void updateLearning(UpdateLearningEvent updateLearningEvent){
        try{
            Learning learning = learningRepository.findByUserId(updateLearningEvent.userId())
                    .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

            Long totalLesson = lessonRepository.count();
            Long solvedLesson = lessonProgressRepository.countByUserId(updateLearningEvent.userId());

            Integer planetConquestRate = Math.toIntExact(
                    Math.round((solvedLesson.doubleValue() / totalLesson) * 100)
            );

            learning.updateLearningStatus(updateLearningEvent.chapterId(), planetConquestRate);

            learningRepository.save(learning);
        }catch (Exception e){
            log.error("Exception occurred while updating Learning with {}", e.getMessage());
        }
    }

    @Async("learningAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void createLearning(CreateLearningEvent createLearningEvent){
        try{
            Learning learning = Learning.create(createLearningEvent.userId());

            learningRepository.save(learning);
        }catch (Exception e){
            log.error("Exception occurred while creating Learning with {}", e.getMessage());

        }
    }
}
