package gravit.code.userLeague.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_CONFLICT;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserLeagueCreateRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "user-league-create-retry";
    public static final String FIELD_USER_ID = "userId";

    private static final int MAX_ATTEMPTS = 10;

    private final UserLeagueService userLeagueService;

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

        try {
            userLeagueService.initUserLeague(userId);
        } catch (RestApiException e) {
            if (e.getErrorCode() == USER_LEAGUE_CONFLICT) {
                log.warn("유저 리그 이미 존재, 재시도 종료: userId={}", userId);
                return;
            }
            throw e;
        }
    }
}
