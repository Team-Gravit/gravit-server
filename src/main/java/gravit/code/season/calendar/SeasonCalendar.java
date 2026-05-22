package gravit.code.season.calendar;

import gravit.code.season.calendar.dto.SeasonDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class SeasonCalendar {
    private final Clock clock;

    // kst 기준 현재 시즌 리턴 (4개월 단위: S1=1~4월, S2=5~8월, S3=9~12월)
    public SeasonDto currentSeason() {
        LocalDate today = LocalDate.now(clock);
        int year = today.getYear();
        int sn = seasonNumberOf(today.getMonthValue());
        LocalDateTime start = seasonStart(year, sn);
        LocalDateTime end = start.plusMonths(4);
        return new SeasonDto(formatSeasonKey(year, sn), start, end);
    }

    // 특정 종료시각(=현재 시즌 endsAt) 기준 다음 시즌
    public SeasonDto nextFromEndsAt(LocalDateTime currentEndsAt) {
        LocalDate nextDate = currentEndsAt.toLocalDate();
        int year = nextDate.getYear();
        int sn = seasonNumberOf(nextDate.getMonthValue());
        LocalDateTime end = currentEndsAt.plusMonths(4);
        return new SeasonDto(formatSeasonKey(year, sn), currentEndsAt, end);
    }

    // kstDate 기준 시즌 키 반환 (예: 2026-S1)
    public static String seasonKey(LocalDate kstDate) {
        int year = kstDate.getYear();
        int sn = seasonNumberOf(kstDate.getMonthValue());
        return formatSeasonKey(year, sn);
    }

    private static int seasonNumberOf(int month) {
        return (month - 1) / 4 + 1;
    }

    private static LocalDateTime seasonStart(int year, int seasonNumber) {
        int startMonth = (seasonNumber - 1) * 4 + 1;
        return LocalDate.of(year, startMonth, 1).atStartOfDay();
    }

    private static String formatSeasonKey(int year, int seasonNumber) {
        return year + "-S" + seasonNumber;
    }
}
