package gravit.code.user.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserXpInterviewRetryTarget implements RetrySweepTarget {

    private static final int MAX_ATTEMPTS = 10;

    private final UserService userService;

    @Override
    public String queueKey() {
        return "user-xp-interview-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        Long userId = Long.valueOf(fields.get("userId"));
        int xp = Integer.parseInt(fields.get("xp"));

        try {
            userService.addXp(userId, xp);
        } catch (RestApiException e) {
            if (e.getErrorCode() == CustomErrorCode.USER_NOT_FOUND) {
                log.error("면접 완료 XP 지급 실패(재시도 불가, 확인 필요), 재시도 종료: userId={}, errorCode={}", userId, e.getErrorCode(), e);
                return;
            }
            throw e;
        }
    }
}
