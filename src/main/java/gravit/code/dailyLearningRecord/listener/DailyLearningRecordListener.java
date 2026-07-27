package gravit.code.dailyLearningRecord.listener;

import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;

import static org.springframework.transaction.event.TransactionPhase.AFTER_COMMIT;

@Slf4j
@Component
@RequiredArgsConstructor
public class DailyLearningRecordListener {

    private final DailyLearningRecordService dailyLearningRecordService;
    private final RetryEventPublisher retryEventPublisher;

    @TransactionalEventListener(phase = AFTER_COMMIT)
    public void handleDailyLearningRecord(LessonCompletedEvent event) {
        try {
            dailyLearningRecordService.handleDailyLearningRecord(event.userId());
        } catch (Exception e) {
            log.error("일일 학습 기록 처리 실패, 재시도 큐 적재: userId={}", event.userId(), e);
            retryEventPublisher.publish("daily-learning-record-retry", Map.of(
                    "userId", String.valueOf(event.userId())
            ));
        }
    }
}
