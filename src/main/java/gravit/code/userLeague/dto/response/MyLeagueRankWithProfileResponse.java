package gravit.code.userLeague.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record MyLeagueRankWithProfileResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long leagueId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String leagueName,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int rank,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long userId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int lp,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int maxLp,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int profileImgNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int xp,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int level
) {
    public static MyLeagueRankWithProfileResponse of(
            long leagueId,
            String leagueName,
            int rank,
            long userId,
            int lp,
            int maxLp,
            String nickname,
            int profileImgNumber,
            int xp,
            int level
    ) {
        return MyLeagueRankWithProfileResponse.builder()
                .leagueId(leagueId)
                .leagueName(leagueName)
                .rank(rank)
                .userId(userId)
                .lp(lp)
                .maxLp(maxLp)
                .nickname(nickname)
                .profileImgNumber(profileImgNumber)
                .xp(xp)
                .level(level)
                .build();
    }
}
