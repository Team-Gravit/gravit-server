package gravit.code.userLeague.dto.response;

public record MyLeagueRankWithProfileResponse(
        Long leagueId,
        String leagueName,
        int rank,
        Long userId,
        int lp,
        int maxLp,
        String nickname,
        int profileImgNumber,
        int xp,
        int level
) {
}
