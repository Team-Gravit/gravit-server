package gravit.code.admin.dto.internal;

import java.time.LocalDate;

public record DailyActiveUserCountDto(
        LocalDate activityDate,
        Long activeUserCount
) {
}
