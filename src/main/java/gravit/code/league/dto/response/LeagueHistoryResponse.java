package gravit.code.league.dto.response;

import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record LeagueHistoryResponse(
        int currentSeasonRank,
        int totalSeasonCount,
        int top3SeasonCount,
        String bestLeagueName,
        List<SeasonHistoryEntry> seasonHistory
) {
    public record SeasonHistoryEntry(
            String seasonKey,
            String leagueName
    ) {}

    public static LeagueHistoryResponse of(
            int currentSeasonRank,
            int totalSeasonCount,
            int top3SeasonCount,
            String bestLeagueName,
            List<SeasonHistoryEntry> seasonHistory
    ) {
        return LeagueHistoryResponse.builder()
                .currentSeasonRank(currentSeasonRank)
                .totalSeasonCount(totalSeasonCount)
                .top3SeasonCount(top3SeasonCount)
                .bestLeagueName(bestLeagueName)
                .seasonHistory(seasonHistory)
                .build();
    }
}
