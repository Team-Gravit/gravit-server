package gravit.code.userLeague.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.userLeague.service.LeagueRankSyncService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_RANK_USER_ID_OUT_OF_RANGE;

@Slf4j
@Component
@RequiredArgsConstructor
public class LeagueRankSyncRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "league-rank-sync-retry";
    public static final String FIELD_SEASON_ID = "seasonId";
    public static final String FIELD_USER_ID = "userId";

    private static final int MAX_ATTEMPTS = 10;

    private final LeagueRankSyncService leagueRankSyncService;

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
        long seasonId = Long.parseLong(fields.get(FIELD_SEASON_ID));
        long userId = Long.parseLong(fields.get(FIELD_USER_ID));

        try {
            leagueRankSyncService.syncFromDatabase(seasonId, userId);
        } catch (RestApiException e) {
            if (e.getErrorCode() == LEAGUE_RANK_USER_ID_OUT_OF_RANGE) {
                log.error("랭킹 반영 실패(재시도 불가, 확인 필요), 재시도 종료: userId={}, seasonId={}, errorCode={}", userId, seasonId, e.getErrorCode(), e);
                return;
            }
            throw e;
        }
    }
}
