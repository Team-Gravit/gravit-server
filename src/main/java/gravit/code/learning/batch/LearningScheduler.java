package gravit.code.learning.batch;

import gravit.code.learning.service.LearningCommandService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LearningScheduler {

    private final LearningCommandService learningCommandService;

    @Scheduled(cron = "0 1 0 * * *", zone = "Asia/Seoul")
    public void updateConsecutiveDays(){
        learningCommandService.updateConsecutiveDays();
    }
}
