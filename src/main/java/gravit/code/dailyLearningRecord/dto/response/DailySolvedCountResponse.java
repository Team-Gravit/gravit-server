package gravit.code.dailyLearningRecord.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;

public record DailySolvedCountResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDate date,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int solvedLessonCount
) {
}
