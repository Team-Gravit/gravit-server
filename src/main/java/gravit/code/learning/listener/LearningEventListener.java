package gravit.code.learning.listener;

import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.service.LearningCommandService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class LearningEventListener {

    private final LearningCommandService learningCommandService;
    private final RetryEventPublisher retryEventPublisher;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void createLearning(OnboardingCompletedEvent event){
        try {
            learningCommandService.createLearning(event.userId());
        } catch (RestApiException e) {
            if (e.getErrorCode() == CustomErrorCode.LEARNING_CONFLICT) {
                log.warn("학습 정보 이미 존재, 재시도 큐 적재 생략: userId={}", event.userId());
                return;
            }
            queueLearningCreateRetry(event.userId(), e);
        } catch (Exception e) {
            queueLearningCreateRetry(event.userId(), e);
        }
    }

    private void queueLearningCreateRetry(
            long userId,
            Exception cause
    ) {
        log.error("학습 정보 생성 실패, 재시도 큐 적재: userId={}", userId, cause);
        retryEventPublisher.publish("learning-create-retry", Map.of(
                "userId", String.valueOf(userId)
        ));
    }
}
