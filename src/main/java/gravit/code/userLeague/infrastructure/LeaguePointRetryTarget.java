package gravit.code.userLeague.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.userLeague.service.UserLeaguePointService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;

@Slf4j
@Component
@RequiredArgsConstructor
public class LeaguePointRetryTarget implements RetrySweepTarget {

    private static final int MAX_ATTEMPTS = 10;

    private static final Set<ErrorCode> NON_RETRYABLE_ERRORS = Set.of(
            CustomErrorCode.USER_LEAGUE_NOT_FOUND,
            CustomErrorCode.LEAGUE_NOT_MATCH_LEAGUE_POINT
    );

    private final UserLeaguePointService pointService;

    @Override
    public String queueKey() {
        return "league-points-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        Long userId = Long.valueOf(fields.get("userId"));
        int points = Integer.parseInt(fields.get("points"));
        int accuracy = Integer.parseInt(fields.get("accuracy"));

        try {
            pointService.addLeaguePoints(userId, points, accuracy);
        } catch (RestApiException e) {
            if (NON_RETRYABLE_ERRORS.contains(e.getErrorCode())) {
                log.error("리그 포인트 반영 실패(재시도 불가, 확인 필요), 재시도 종료: userId={}, errorCode={}", userId, e.getErrorCode(), e);
                return;
            }
            throw e;
        }
    }
}
