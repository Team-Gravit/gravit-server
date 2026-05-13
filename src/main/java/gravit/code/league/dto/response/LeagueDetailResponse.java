package gravit.code.league.dto.response;

import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record LeagueDetailResponse(
        long leagueId,
        String leagueName,
        int currentLP,
        int maxLP
) {
    public static LeagueDetailResponse of(
            long leagueId,
            String leagueName,
            int currentLP,
            int maxLP
    ){
        return  LeagueDetailResponse.builder()
                .leagueId(leagueId)
                .leagueName(leagueName)
                .currentLP(currentLP)
                .maxLP(maxLP)
                .build();
    }
}
