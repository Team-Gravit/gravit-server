package gravit.code.dailyLearningRecord.infrastructure;

import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.event.retry.RetrySweepTarget;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class DailyLearningRecordRetryTarget implements RetrySweepTarget {

    private static final int MAX_ATTEMPTS = 10;

    private final DailyLearningRecordService dailyLearningRecordService;

    @Override
    public String queueKey() {
        return "daily-learning-record-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        long userId = Long.parseLong(fields.get("userId"));

        dailyLearningRecordService.handleDailyLearningRecord(userId);
    }
}
