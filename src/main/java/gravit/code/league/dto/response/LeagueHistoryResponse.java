package gravit.code.league.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
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
            String leagueName,
            int sortOrder,
            @JsonProperty("isCurrent")
            boolean isCurrent
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
