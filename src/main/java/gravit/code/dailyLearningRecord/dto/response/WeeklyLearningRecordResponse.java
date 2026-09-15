package gravit.code.dailyLearningRecord.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.DayOfWeek;
import java.util.Map;

public record WeeklyLearningRecordResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int consecutiveSolvedDays,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse MONDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse TUESDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse WEDNESDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse THURSDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse FRIDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse SATURDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        DayLearningRecordResponse SUNDAY
) {
    public static WeeklyLearningRecordResponse of(
            int consecutiveSolvedDays,
            Map<DayOfWeek, DayLearningRecordResponse> dayOfWeekToRecord
    ) {
        return new WeeklyLearningRecordResponse(
                consecutiveSolvedDays,
                dayOfWeekToRecord.get(DayOfWeek.MONDAY),
                dayOfWeekToRecord.get(DayOfWeek.TUESDAY),
                dayOfWeekToRecord.get(DayOfWeek.WEDNESDAY),
                dayOfWeekToRecord.get(DayOfWeek.THURSDAY),
                dayOfWeekToRecord.get(DayOfWeek.FRIDAY),
                dayOfWeekToRecord.get(DayOfWeek.SATURDAY),
                dayOfWeekToRecord.get(DayOfWeek.SUNDAY)
        );
    }
}
