package gravit.code.user.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserXpInterviewRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "user-xp-interview-retry";
    public static final String FIELD_USER_ID = "userId";
    public static final String FIELD_XP = "xp";

    private static final int MAX_ATTEMPTS = 10;

    private final UserService userService;

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
        Long userId = Long.valueOf(fields.get(FIELD_USER_ID));
        int xp = Integer.parseInt(fields.get(FIELD_XP));

        try {
            userService.addXp(userId, xp);
        } catch (RestApiException e) {
            if (e.getErrorCode() == USER_NOT_FOUND) {
                log.error("면접 완료 XP 지급 실패(재시도 불가, 확인 필요), 재시도 종료: userId={}, errorCode={}", userId, e.getErrorCode(), e);
                return;
            }
            throw e;
        }
    }
}
