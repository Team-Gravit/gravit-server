package gravit.code.season.calendar;

import gravit.code.season.calendar.dto.SeasonResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.time.temporal.WeekFields;

@Component
@RequiredArgsConstructor
public class SeasonCalendar {
    private final Clock clock;

    // kst 기준 이번 주 시즌 리턴
    public SeasonResponse currentWeek() {
        LocalDate monday = weekMonday(LocalDate.now(clock));
        LocalDateTime start = monday.atStartOfDay();
        LocalDateTime end = start.plusWeeks(1);
        return new SeasonResponse(isoWeekKey(monday), start, end);
    }

    // 특정 종료시각(=현재 시즌 endsAt) 기준 다음 주 시즌
    public SeasonResponse nextFromEndsAt(LocalDateTime currentEndsAt) {
        LocalDateTime start = currentEndsAt;
        LocalDateTime end = start.plusWeeks(1);
        return new SeasonResponse(isoWeekKey(start.toLocalDate()), start, end);
    }

    public static String isoWeekKey(LocalDate kstDate) {
        WeekFields wf = WeekFields.ISO;
        int week = kstDate.get(wf.weekOfWeekBasedYear());
        int year = kstDate.get(wf.weekBasedYear());
        return String.format("%d-W%02d", year, week);
    }

    private static LocalDate weekMonday(LocalDate date) {
        return date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }

}
