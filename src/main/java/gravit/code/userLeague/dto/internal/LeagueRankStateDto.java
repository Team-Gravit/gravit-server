package gravit.code.userLeague.dto.internal;

public record LeagueRankStateDto(
        long userLeagueId,

        long userId,

        long seasonId,

        long leagueId,

        int leaguePoint
) {
}
