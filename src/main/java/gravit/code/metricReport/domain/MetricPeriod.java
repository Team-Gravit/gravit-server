package gravit.code.metricReport.domain;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.metricReport.dto.internal.MetricRangeDto;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.Arrays;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.DISCORD_UNSUPPORTED_INTERACTION;

@Getter
@RequiredArgsConstructor
public enum MetricPeriod {

    TODAY("today", "오늘"),
    YESTERDAY("yesterday", "어제"),
    LAST_7_DAYS("7d", "최근 7일"),
    LAST_30_DAYS("30d", "최근 30일"),
    LAST_WEEK("last-week", "지난주");

    private static final int WEEK_DAYS = 7;
    private static final int MONTH_DAYS = 30;

    private final String optionValue;
    private final String label;

    public MetricRangeDto toRange(LocalDate today) {
        LocalDate yesterday = today.minusDays(1);

        return switch (this) {
            case TODAY -> MetricRangeDto.of(today, today);
            case YESTERDAY -> MetricRangeDto.of(yesterday, yesterday);
            case LAST_7_DAYS -> MetricRangeDto.of(today.minusDays(WEEK_DAYS), yesterday);
            case LAST_30_DAYS -> MetricRangeDto.of(today.minusDays(MONTH_DAYS), yesterday);
            case LAST_WEEK -> toLastWeekRange(today);
        };
    }

    private MetricRangeDto toLastWeekRange(LocalDate today) {
        LocalDate thisMonday = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        return MetricRangeDto.of(thisMonday.minusDays(WEEK_DAYS), thisMonday.minusDays(1));
    }

    public Optional<MetricRangeDto> toPreviousRange(LocalDate today) {
        if (this == TODAY) {
            return Optional.empty();
        }

        MetricRangeDto range = toRange(today);
        return Optional.of(range.minusDays(range.days()));
    }

    public static MetricPeriod fromOptionValue(String optionValue) {
        if (optionValue == null) {
            return TODAY;
        }

        return Arrays.stream(values())
                .filter(period -> period.optionValue.equals(optionValue))
                .findFirst()
                .orElseThrow(() -> new RestApiException(DISCORD_UNSUPPORTED_INTERACTION));
    }
}
