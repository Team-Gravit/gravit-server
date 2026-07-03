package gravit.code.league.dto.response;

import gravit.code.league.domain.League;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record LeagueResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long leagueId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String name,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int minLp,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int maxLp
) {
    public static LeagueResponse from(League league) {
        return LeagueResponse.builder()
                .leagueId(league.getId())
                .name(league.getName())
                .minLp(league.getMinLp())
                .maxLp(league.getMaxLp())
                .build();
    }
}
