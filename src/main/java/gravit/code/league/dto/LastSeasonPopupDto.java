package gravit.code.league.dto;

import gravit.code.userLeagueHistory.domain.UserLeagueHistory;

public record LastSeasonPopupDto(
        int rank,
        String leagueName,
        long profileImgNumber
) {
    public static LastSeasonPopupDto from(UserLeagueHistory userLeagueHistory) {
        return new LastSeasonPopupDto(
                userLeagueHistory.getFinalRank(),
                userLeagueHistory.getFinalLeague().getName(),
                userLeagueHistory.getUser().getProfileImgNumber()
        );
    }
}
