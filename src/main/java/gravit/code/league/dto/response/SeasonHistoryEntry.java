package gravit.code.league.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
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
) {
    public static SeasonHistoryEntry of(
            String seasonKey,
            String displayKey,
            String leagueName,
            int sortOrder,
            boolean isCurrent
    ) {
        return SeasonHistoryEntry.builder()
                .seasonKey(seasonKey)
                .displayKey(displayKey)
                .leagueName(leagueName)
                .sortOrder(sortOrder)
                .isCurrent(isCurrent)
                .build();
    }
}
