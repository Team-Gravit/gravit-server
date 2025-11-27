package gravit.code.userLeague.dto.response;

import jakarta.validation.constraints.NotNull;

public record LeagueRankRow(

        int rank,
        long userId,
        int lp,
        @NotNull
        String nickname,
        int profileImgNumber,
        int xp,
        int level
) {
}
