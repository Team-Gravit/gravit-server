package gravit.code.userLeague.dto.response;

public record LeagueRankRow(
        int rank,
        Long userId,
        int lp,
        String nickname,
        int profileImgNumber,
        int level
) {
}
