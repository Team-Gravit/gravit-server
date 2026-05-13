package gravit.code.userLeague.dto.internal;

import jakarta.validation.constraints.NotNull;

public record LeagueRankRowDto(

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
