package gravit.code.dailyLearningRecord.infrastructure;

import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.event.retry.RetrySweepTarget;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class DailyLearningRecordRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "daily-learning-record-retry";
    public static final String FIELD_USER_ID = "userId";

    private static final int MAX_ATTEMPTS = 10;

    private final DailyLearningRecordService dailyLearningRecordService;

    @Override
    public String queueKey() {
        return QUEUE_KEY;
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        long userId = Long.parseLong(fields.get(FIELD_USER_ID));

        dailyLearningRecordService.handleDailyLearningRecord(userId);
    }
}
