package gravit.code.learning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record LearningSummaryResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int topPercent,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int completedLessonCount,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int totalLessonCount,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        double totalLearningHours,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int averageAccuracy
) {
    public static LearningSummaryResponse of(
            int topPercent,
            int completedLessonCount,
            int totalLessonCount,
            double totalLearningHours,
            int averageAccuracy
    ) {
        return LearningSummaryResponse.builder()
                .topPercent(topPercent)
                .completedLessonCount(completedLessonCount)
                .totalLessonCount(totalLessonCount)
                .totalLearningHours(totalLearningHours)
                .averageAccuracy(averageAccuracy)
                .build();
    }
}
