package gravit.code.mission.listener;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class MissionEventListener {

    private final MissionService missionService;
    private final RetryEventPublisher retryEventPublisher;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleCompleteLessonMission(LessonCompletedEvent event){
        try {
            missionService.handleLessonMission(
                    event.userId(),
                    event.lessonId(),
                    event.learningTime(),
                    event.accuracy()
            );
        } catch (RestApiException e) {
            if (isNonRetryable(e)) {
                log.error("레슨 완료 미션 처리 실패(재시도 불가, 확인 필요): userId={}, errorCode={}", event.userId(), e.getErrorCode(), e);
                return;
            }
            queueLessonMissionRetry(event, e);
        } catch (Exception e) {
            queueLessonMissionRetry(event, e);
        }
    }

    private void queueLessonMissionRetry(
            LessonCompletedEvent event,
            Exception cause
    ) {
        log.error("레슨 완료 미션 처리 실패, 재시도 큐 적재: userId={}", event.userId(), cause);
        retryEventPublisher.publish("mission-lesson-retry", Map.of(
                "userId", String.valueOf(event.userId()),
                "lessonId", String.valueOf(event.lessonId()),
                "learningTime", String.valueOf(event.learningTime()),
                "accuracy", String.valueOf(event.accuracy())
        ));
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleFollowMission(FollowMissionEvent followMissionDto){
        try {
            missionService.handleFollowMission(followMissionDto);
        } catch (RestApiException e) {
            if (isNonRetryable(e)) {
                log.error("팔로우 미션 처리 실패(재시도 불가, 확인 필요): userId={}, errorCode={}", followMissionDto.userId(), e.getErrorCode(), e);
                return;
            }
            queueFollowMissionRetry(followMissionDto.userId(), e);
        } catch (Exception e) {
            queueFollowMissionRetry(followMissionDto.userId(), e);
        }
    }

    private void queueFollowMissionRetry(
            long userId,
            Exception cause
    ) {
        log.error("팔로우 미션 처리 실패, 재시도 큐 적재: userId={}", userId, cause);
        retryEventPublisher.publish("mission-follow-retry", Map.of(
                "userId", String.valueOf(userId)
        ));
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void createMission(OnboardingCompletedEvent event){
        try {
            missionService.createMission(event.userId());
        } catch (Exception e) {
            queueMissionCreateRetry(event.userId(), e);
        }
    }

    private void queueMissionCreateRetry(
            long userId,
            Exception cause
    ) {
        log.error("미션 생성 실패, 재시도 큐 적재: userId={}", userId, cause);
        retryEventPublisher.publish("mission-create-retry", Map.of(
                "userId", String.valueOf(userId)
        ));
    }

    private boolean isNonRetryable(RestApiException e) {
        return e.getErrorCode() == CustomErrorCode.MISSION_NOT_FOUND
                || e.getErrorCode() == CustomErrorCode.USER_NOT_FOUND;
    }
}
