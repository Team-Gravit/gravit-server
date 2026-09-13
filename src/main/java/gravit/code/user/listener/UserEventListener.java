package gravit.code.user.listener;

import gravit.code.global.event.InterviewCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserEventListener {

    private final UserService userService;
    private final RetryEventPublisher retryEventPublisher;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleInterviewCompleted(InterviewCompletedEvent event) {
        try {
            userService.addXp(event.userId(), event.rewardPoints());
        } catch (RestApiException e) {
            if (e.getErrorCode() == CustomErrorCode.USER_NOT_FOUND) {
                log.error("면접 완료 XP 지급 실패(재시도 불가, 확인 필요): userId={}, sessionId={}, errorCode={}", event.userId(), event.sessionId(), e.getErrorCode(), e);
                return;
            }
            queueInterviewXpRetry(event, e);
        } catch (Exception e) {
            queueInterviewXpRetry(event, e);
        }
    }

    private void queueInterviewXpRetry(
            InterviewCompletedEvent event,
            Exception cause
    ) {
        log.error("면접 완료 XP 지급 실패, 재시도 큐 적재: userId={}, sessionId={}", event.userId(), event.sessionId(), cause);
        retryEventPublisher.publish("user-xp-interview-retry", Map.of(
                "userId", String.valueOf(event.userId()),
                "xp", String.valueOf(event.rewardPoints())
        ));
    }
}
