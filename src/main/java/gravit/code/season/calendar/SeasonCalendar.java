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

    public static final int SEASON_MONTHS = 4;
    public static final String SEASON_KEY_DELIMITER = "-";

    private static final String SEASON_NUMBER_PREFIX = "S";

    private final Clock clock;

    public SeasonDto currentSeason() {
        LocalDate today = LocalDate.now(clock);
        int year = today.getYear();
        int sn = seasonNumberOf(today.getMonthValue());
        LocalDateTime start = seasonStart(year, sn);
        LocalDateTime end = start.plusMonths(SEASON_MONTHS);
        return new SeasonDto(formatSeasonKey(year, sn), start, end);
    }

    public SeasonDto nextFromEndsAt(LocalDateTime currentEndsAt) {
        LocalDate nextDate = currentEndsAt.toLocalDate();
        int year = nextDate.getYear();
        int sn = seasonNumberOf(nextDate.getMonthValue());
        LocalDateTime end = currentEndsAt.plusMonths(SEASON_MONTHS);
        return new SeasonDto(formatSeasonKey(year, sn), currentEndsAt, end);
    }

    public static String seasonKey(LocalDate kstDate) {
        int year = kstDate.getYear();
        int sn = seasonNumberOf(kstDate.getMonthValue());
        return formatSeasonKey(year, sn);
    }

    private static int seasonNumberOf(int month) {
        return (month - 1) / SEASON_MONTHS + 1;
    }

    private static LocalDateTime seasonStart(
            int year,
            int seasonNumber
    ) {
        int startMonth = (seasonNumber - 1) * SEASON_MONTHS + 1;
        return LocalDate.of(year, startMonth, 1).atStartOfDay();
    }

    private static String formatSeasonKey(
            int year,
            int seasonNumber
    ) {
        return year + SEASON_KEY_DELIMITER + SEASON_NUMBER_PREFIX + seasonNumber;
    }
}
