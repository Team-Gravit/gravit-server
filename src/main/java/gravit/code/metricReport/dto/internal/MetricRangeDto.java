package gravit.code.metricReport.dto.internal;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public record MetricRangeDto(

        LocalDate startDate,

        LocalDate endDate
) {
    public static MetricRangeDto of(
            LocalDate startDate,
            LocalDate endDate
    ) {
        return new MetricRangeDto(startDate, endDate);
    }

    public LocalDateTime startAt() {
        return startDate.atStartOfDay();
    }

    public LocalDateTime endExclusiveAt() {
        return endDate.plusDays(1).atStartOfDay();
    }

    public long days() {
        return ChronoUnit.DAYS.between(startDate, endDate) + 1;
    }

    public boolean isSingleDay() {
        return startDate.equals(endDate);
    }

    public MetricRangeDto minusDays(long days) {
        return MetricRangeDto.of(startDate.minusDays(days), endDate.minusDays(days));
    }
}
