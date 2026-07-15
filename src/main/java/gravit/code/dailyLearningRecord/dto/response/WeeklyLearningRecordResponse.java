package gravit.code.dailyLearningRecord.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.DayOfWeek;
import java.util.Set;

public record WeeklyLearningRecordResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int consecutiveSolvedDays,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean MONDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean TUESDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean WEDNESDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean THURSDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean FRIDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean SATURDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean SUNDAY
) {
    public static WeeklyLearningRecordResponse of(
            int consecutiveSolvedDays,
            Set<DayOfWeek> solvedDays
    ) {
        return new WeeklyLearningRecordResponse(
                consecutiveSolvedDays,
                solvedDays.contains(DayOfWeek.MONDAY),
                solvedDays.contains(DayOfWeek.TUESDAY),
                solvedDays.contains(DayOfWeek.WEDNESDAY),
                solvedDays.contains(DayOfWeek.THURSDAY),
                solvedDays.contains(DayOfWeek.FRIDAY),
                solvedDays.contains(DayOfWeek.SATURDAY),
                solvedDays.contains(DayOfWeek.SUNDAY)
        );
    }
}
