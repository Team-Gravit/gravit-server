package gravit.code.learning.scheduler;

import gravit.code.learning.service.LearningService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LearningScheduler {

    private final LearningService learningService;

    @Scheduled(cron = "0 1 0 * * *", zone = "Asia/Seoul")
    public void updateConsecutiveDays(){
        learningService.updateConsecutiveDays();
    }
}
