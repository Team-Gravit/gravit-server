package gravit.code.userLeague.listener;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.dto.event.InterviewCompletedEvent;
import gravit.code.lesson.dto.event.LessonCompletedEvent;
import gravit.code.user.dto.event.OnboardingCompletedEvent;
import gravit.code.userLeague.infrastructure.LeaguePointInterviewRetryTarget;
import gravit.code.userLeague.infrastructure.LeaguePointRetryTarget;
import gravit.code.userLeague.infrastructure.UserLeagueCreateRetryTarget;
import gravit.code.userLeague.service.UserLeaguePointService;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_NOT_MATCH_LEAGUE_POINT;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_CONFLICT;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

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
            pointService.addLeaguePointsForLesson(event.userId(), event.points(), event.accuracy());
        } catch (RestApiException e) {
            if (isNonRetryable(e)) {
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
        retryEventPublisher.publish(LeaguePointRetryTarget.QUEUE_KEY, Map.of(
                LeaguePointRetryTarget.FIELD_USER_ID, String.valueOf(event.userId()),
                LeaguePointRetryTarget.FIELD_POINTS, String.valueOf(event.points()),
                LeaguePointRetryTarget.FIELD_ACCURACY, String.valueOf(event.accuracy())
        ));
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleInterviewCompleted(InterviewCompletedEvent event) {
        try {
            pointService.addLeaguePointsForInterview(event.userId(), event.rewardPoints());
        } catch (RestApiException e) {
            if (isNonRetryable(e)) {
                log.error("면접 완료 리그 포인트 반영 실패(재시도 불가, 확인 필요): userId={}, sessionId={}, errorCode={}", event.userId(), event.sessionId(), e.getErrorCode(), e);
                return;
            }
            queueInterviewLeaguePointsRetry(event, e);
        } catch (Exception e) {
            queueInterviewLeaguePointsRetry(event, e);
        }
    }

    private void queueInterviewLeaguePointsRetry(
            InterviewCompletedEvent event,
            Exception cause
    ) {
        log.error("면접 완료 리그 포인트 반영 실패, 재시도 큐 적재: userId={}, sessionId={}", event.userId(), event.sessionId(), cause);
        retryEventPublisher.publish(LeaguePointInterviewRetryTarget.QUEUE_KEY, Map.of(
                LeaguePointInterviewRetryTarget.FIELD_USER_ID, String.valueOf(event.userId()),
                LeaguePointInterviewRetryTarget.FIELD_POINTS, String.valueOf(event.rewardPoints())
        ));
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void createUserLeague(OnboardingCompletedEvent event) {
        try {
            userLeagueService.initUserLeague(event.userId());
        } catch (RestApiException e) {
            if (e.getErrorCode() == USER_LEAGUE_CONFLICT) {
                log.warn("유저 리그 이미 존재, 재시도 큐 적재 생략: userId={}", event.userId());
                return;
            }
            if (e.getErrorCode() == USER_NOT_FOUND) {
                log.error("유저 리그 생성 실패(재시도 불가, 확인 필요): userId={}, errorCode={}", event.userId(), e.getErrorCode(), e);
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
        retryEventPublisher.publish(UserLeagueCreateRetryTarget.QUEUE_KEY, Map.of(
                UserLeagueCreateRetryTarget.FIELD_USER_ID, String.valueOf(userId)
        ));
    }

    private boolean isNonRetryable(RestApiException e) {
        return e.getErrorCode() == USER_LEAGUE_NOT_FOUND
                || e.getErrorCode() == LEAGUE_NOT_MATCH_LEAGUE_POINT;
    }
}
