package gravit.code.userLeague.dto.internal;

public record LeagueRankEntryDto(
        int rank,

        long userId,

        int leaguePoint,

        long leagueId
) {
}
