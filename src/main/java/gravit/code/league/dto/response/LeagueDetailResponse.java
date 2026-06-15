package gravit.code.league.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record LeagueDetailResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long leagueId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String leagueName,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int currentLP,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int minLP,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int maxLP
) {
    public static LeagueDetailResponse of(
            long leagueId,
            String leagueName,
            int currentLP,
            int minLP,
            int maxLP
    ){
        return  LeagueDetailResponse.builder()
                .leagueId(leagueId)
                .leagueName(leagueName)
                .currentLP(currentLP)
                .minLP(minLP)
                .maxLP(maxLP)
                .build();
    }
}
