package gravit.code.userLeague.dto.response;

public record LeagueRankRow(
        int rank,
        long userId,
        int lp,
        String nickname,
        int profileImgNumber,
        int xp,
        int level
) {
}
