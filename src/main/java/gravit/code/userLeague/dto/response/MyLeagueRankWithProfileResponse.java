package gravit.code.userLeague.dto.response;

public record MyLeagueRankWithProfileResponse(
        long leagueId,
        String leagueName,
        int rank,
        long userId,
        int lp,
        int maxLp,
        String nickname,
        int profileImgNumber,
        int xp,
        int level
) {
}
