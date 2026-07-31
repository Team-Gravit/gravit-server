package gravit.code.userLeague.dto.internal;

public record LeagueRankEntry(
        int rank,
        long userId,
        int leaguePoint,
        long leagueId
) {
}
