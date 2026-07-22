package gravit.code.learning.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.service.LearningCommandService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class LearningCreateRetryTarget implements RetrySweepTarget {

    private static final int MAX_ATTEMPTS = 10;

    private final LearningCommandService learningCommandService;

    @Override
    public String queueKey() {
        return "learning-create-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        Long userId = Long.valueOf(fields.get("userId"));

        try {
            learningCommandService.createLearning(userId);
        } catch (RestApiException e) {
            if (e.getErrorCode() == CustomErrorCode.LEARNING_CONFLICT) {
                log.warn("학습 정보 이미 존재, 재시도 종료: userId={}", userId);
                return;
            }
            throw e;
        }
    }
}
