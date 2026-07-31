package gravit.code.userLeague.infrastructure;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.experimental.UtilityClass;

@UtilityClass
public class LeagueRankScore {

    private static final long TIE_BREAK_BASE = 1_000_000_000L;
    private static final long MIN_USER_ID = 1L;

    public static double encode(
            int leaguePoint,
            long userId
    ) {
        validateUserId(userId);

        return (double) (leaguePoint * TIE_BREAK_BASE + (TIE_BREAK_BASE - userId));
    }

    public static int toLeaguePoint(double score) {
        return (int) ((long) score / TIE_BREAK_BASE);
    }

    private static void validateUserId(long userId) {
        if (userId < MIN_USER_ID || userId >= TIE_BREAK_BASE) {
            throw new RestApiException(CustomErrorCode.LEAGUE_RANK_USER_ID_OUT_OF_RANGE);
        }
    }
}
