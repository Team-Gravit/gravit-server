package gravit.code.learning.dto.response;

import gravit.code.dailyLearningRecord.dto.response.DailySolvedCountResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record LearningHistoryResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<DailySolvedCountResponse> dailySolvedCounts,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int peakLearningHour,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<Integer> years
) {
    public static LearningHistoryResponse of(
            List<DailySolvedCountResponse> dailySolvedCounts,
            int peakLearningHour,
            List<Integer> years
    ) {
        return LearningHistoryResponse.builder()
                .dailySolvedCounts(dailySolvedCounts)
                .peakLearningHour(peakLearningHour)
                .years(years)
                .build();
    }
}
