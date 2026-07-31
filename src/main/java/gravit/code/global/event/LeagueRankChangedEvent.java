package gravit.code.global.event;

public record LeagueRankChangedEvent(
        long userId,
        long seasonId,
        Long oldLeagueId,
        long newLeagueId,
        int leaguePoint,
        boolean removed
) {

    private static final int NO_LEAGUE_POINT = 0;

    public static LeagueRankChangedEvent joined(
            long userId,
            long seasonId,
            long leagueId,
            int leaguePoint
    ) {
        return new LeagueRankChangedEvent(userId, seasonId, null, leagueId, leaguePoint, false);
    }

    public static LeagueRankChangedEvent pointsChanged(
            long userId,
            long seasonId,
            long oldLeagueId,
            long newLeagueId,
            int leaguePoint
    ) {
        return new LeagueRankChangedEvent(userId, seasonId, oldLeagueId, newLeagueId, leaguePoint, false);
    }

    public static LeagueRankChangedEvent removed(
            long userId,
            long seasonId,
            long leagueId
    ) {
        return new LeagueRankChangedEvent(userId, seasonId, leagueId, leagueId, NO_LEAGUE_POINT, true);
    }
}
