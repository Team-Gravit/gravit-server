package gravit.code.league.dto.response;

import gravit.code.league.domain.League;
import lombok.Builder;

@Builder
public record LeagueResponse(
        Long leagueId,
        String name,
        int minLp,
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
