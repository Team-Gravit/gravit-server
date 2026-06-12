package gravit.code.league.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record LeagueHistoryResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int currentSeasonRank,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int totalSeasonCount,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int top3SeasonCount,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String bestLeagueName,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<SeasonHistoryEntry> seasonHistory
) {
    public record SeasonHistoryEntry(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
            String seasonKey,

            @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
            String displayKey,

            @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
            String leagueName,

            @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
            int sortOrder,

            @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
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
