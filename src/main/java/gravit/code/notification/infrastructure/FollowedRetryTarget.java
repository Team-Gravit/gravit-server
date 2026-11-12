package gravit.code.notification.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Slf4j
@Component
@RequiredArgsConstructor
public class FollowedRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "followed-retry";
    public static final String FIELD_FOLLOWER_ID = "followerId";
    public static final String FIELD_FOLLOWEE_ID = "followeeId";

    private static final int MAX_ATTEMPTS = 10;

    private static final Set<ErrorCode> NON_RETRYABLE_ERRORS = Set.of(
            USER_NOT_FOUND
    );

    private final NotificationFacade notificationFacade;

    private final UserService userService;

    private final NotificationMessageProvider messageProvider;

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
        long followerId = Long.parseLong(fields.get(FIELD_FOLLOWER_ID));
        long followeeId = Long.parseLong(fields.get(FIELD_FOLLOWEE_ID));

        try {
            String nickname = userService.getUser(followerId).getNickname();
            String message = messageProvider.followReceived(nickname);
            notificationFacade.notifyUserInApp(followeeId, NotificationType.FOLLOW, message, followerId);
        } catch (RestApiException e) {
            if (NON_RETRYABLE_ERRORS.contains(e.getErrorCode())) {
                log.warn("팔로우 알림 재처리 실패(재시도 불가, 확인 필요), 재시도 종료: followerId={}, followeeId={}, errorCode={}", followerId, followeeId, e.getErrorCode(), e);
                return;
            }
            throw e;
        }
    }
}
