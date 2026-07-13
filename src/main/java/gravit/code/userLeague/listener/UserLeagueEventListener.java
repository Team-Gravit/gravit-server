package gravit.code.userLeague.listener;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.userLeague.service.UserLeaguePointService;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserLeagueEventListener {

    private final UserLeaguePointService pointService;
    private final UserLeagueService userLeagueService;
    private final RetryEventPublisher retryEventPublisher;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleLessonCompleted(LessonCompletedEvent event) {
        try {
            pointService.addLeaguePoints(event.userId(), event.points(), event.accuracy());
        } catch (RestApiException e) {
            if (e.getErrorCode() == CustomErrorCode.USER_LEAGUE_NOT_FOUND
                    || e.getErrorCode() == CustomErrorCode.LEAGUE_NOT_MATCH_LEAGUE_POINT
            ) {
                log.error("리그 포인트 반영 실패(재시도 불가, 확인 필요): userId={}, errorCode={}", event.userId(), e.getErrorCode(), e);
                return;
            }
            queueLeaguePointsRetry(event, e);
        } catch (Exception e) {
            queueLeaguePointsRetry(event, e);
        }
    }

    private void queueLeaguePointsRetry(
            LessonCompletedEvent event,
            Exception cause
    ) {
        log.error("리그 포인트 반영 실패, 재시도 큐 적재: userId={}", event.userId(), cause);
        retryEventPublisher.publish("league-points-retry", Map.of(
                "userId", String.valueOf(event.userId()),
                "points", String.valueOf(event.points()),
                "accuracy", String.valueOf(event.accuracy())
        ));
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void createUserLeague(OnboardingCompletedEvent event) {
        try {
            userLeagueService.initUserLeague(event.userId());
        } catch (RestApiException e) {
            if (e.getErrorCode() == CustomErrorCode.USER_LEAGUE_CONFLICT) {
                log.warn("유저 리그 이미 존재, 재시도 큐 적재 생략: userId={}", event.userId());
                return;
            }
            queueUserLeagueCreateRetry(event.userId(), e);
        } catch (Exception e) {
            queueUserLeagueCreateRetry(event.userId(), e);
        }
    }

    private void queueUserLeagueCreateRetry(
            Long userId,
            Exception cause
    ) {
        log.error("유저 리그 생성 실패, 재시도 큐 적재: userId={}", userId, cause);
        retryEventPublisher.publish("user-league-create-retry", Map.of(
                "userId", String.valueOf(userId)
        ));
    }
}
