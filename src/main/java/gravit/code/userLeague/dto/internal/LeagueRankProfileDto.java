package gravit.code.userLeague.dto.internal;

public record LeagueRankProfileDto(
        long userId,
        String nickname,
        int profileImgNumber,
        int xp,
        int level
) {
}
