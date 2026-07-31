package gravit.code.userLeague.dto.internal;

public record MyLeagueProfileDto(
        long seasonId,
        long leagueId,
        String leagueName,
        int maxLp,
        long userId,
        int lp,
        String nickname,
        int profileImgNumber,
        int xp,
        int level
) {
}
