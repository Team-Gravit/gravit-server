package gravit.code.global.event.retry;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.Map;

@Slf4j
@Component
public class RetryFallbackProcessor {

    private final RetryEventPublisher retryEventPublisher;

    private final TransactionTemplate requiresNewTemplate;

    public RetryFallbackProcessor(
            RetryEventPublisher retryEventPublisher,
            PlatformTransactionManager transactionManager
    ) {
        this.retryEventPublisher = retryEventPublisher;
        this.requiresNewTemplate = new TransactionTemplate(transactionManager);
        this.requiresNewTemplate.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
    }

    public void publishOrProcess(
            RetrySweepTarget target,
            Map<String, String> fields
    ) {
        try {
            retryEventPublisher.publish(target.queueKey(), fields);
            return;
        } catch (Exception e) {
            log.warn("재시도 큐 적재 실패, 직접 처리: queueKey={}", target.queueKey(), e);
        }

        try {
            requiresNewTemplate.executeWithoutResult(status -> target.reprocess(fields));
        } catch (Exception e) {
            log.error("재시도 큐 적재와 직접 처리 모두 실패, 유실: queueKey={}, fields={}", target.queueKey(), fields, e);
        }
    }
}
