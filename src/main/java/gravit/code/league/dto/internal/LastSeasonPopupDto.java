package gravit.code.league.dto.internal;

import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeagueHistory.domain.UserLeagueHistory;
import jakarta.validation.constraints.NotNull;

public record LastSeasonPopupDto(

        int rank,
        @NotNull
        String leagueName,
        long profileImgNumber,
        @NotNull
        String nextLeagueName,
        int nextStartLp
) {
    public static LastSeasonPopupDto from(
            UserLeagueHistory history,
            UserLeague nextUserLeague
    ) {
        return new LastSeasonPopupDto(
                history.getFinalRank(),
                history.getFinalLeague().getName(),
                history.getUser().getProfileImgNumber(),
                nextUserLeague.getLeague().getName(),
                nextUserLeague.getLp()
        );
    }
}
