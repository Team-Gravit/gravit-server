package gravit.code.userLeague.dto.response;

import jakarta.validation.constraints.NotNull;

public record MyLeagueRankWithProfileResponse(

        long leagueId,
        @NotNull
        String leagueName,
        int rank,
        long userId,
        int lp,
        int maxLp,
        @NotNull
        String nickname,
        int profileImgNumber,
        int xp,
        int level
) {
}
