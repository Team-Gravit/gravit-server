package gravit.code.userLeague.dto.internal;

public record LeagueRankReconcileResultDto(
        long scanned,

        long placed,

        long rebuiltLeagues,

        long elapsedMs
) {

    private static final long NONE = 0L;

    public static LeagueRankReconcileResultDto empty() {
        return new LeagueRankReconcileResultDto(NONE, NONE, NONE, NONE);
    }

    public boolean hasMismatch() {
        return placed + rebuiltLeagues > NONE;
    }
}
