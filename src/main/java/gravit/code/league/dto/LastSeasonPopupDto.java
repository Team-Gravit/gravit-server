package gravit.code.league.dto;

import gravit.code.userLeagueHistory.domain.UserLeagueHistory;
import jakarta.validation.constraints.NotNull;

public record LastSeasonPopupDto(

        int rank,
        @NotNull
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
