package gravit.code.dailyLearningRecord.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.DayOfWeek;
import java.util.List;
import java.util.Map;

@Builder(access = AccessLevel.PRIVATE)
public record WeeklyLearningReportResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int MONDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int TUESDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int WEDNESDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int THURSDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int FRIDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int SATURDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int SUNDAY,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int thisWeekCompletedLessonCount,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<Integer> weekOverWeekDeltas
) {
    public static WeeklyLearningReportResponse of(
            Map<DayOfWeek, Integer> dayOfWeekToCount,
            int thisWeekCompletedLessonCount,
            List<Integer> weekOverWeekDeltas
    ) {
        return WeeklyLearningReportResponse.builder()
                .MONDAY(dayOfWeekToCount.getOrDefault(DayOfWeek.MONDAY, 0))
                .TUESDAY(dayOfWeekToCount.getOrDefault(DayOfWeek.TUESDAY, 0))
                .WEDNESDAY(dayOfWeekToCount.getOrDefault(DayOfWeek.WEDNESDAY, 0))
                .THURSDAY(dayOfWeekToCount.getOrDefault(DayOfWeek.THURSDAY, 0))
                .FRIDAY(dayOfWeekToCount.getOrDefault(DayOfWeek.FRIDAY, 0))
                .SATURDAY(dayOfWeekToCount.getOrDefault(DayOfWeek.SATURDAY, 0))
                .SUNDAY(dayOfWeekToCount.getOrDefault(DayOfWeek.SUNDAY, 0))
                .thisWeekCompletedLessonCount(thisWeekCompletedLessonCount)
                .weekOverWeekDeltas(weekOverWeekDeltas)
                .build();
    }
}
