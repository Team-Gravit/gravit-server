package gravit.code.dailyLearningRecord.domain;

import java.time.LocalDate;

public enum DayTiming {
    PAST,
    TODAY,
    FUTURE;

    public static DayTiming of(
            LocalDate date,
            LocalDate today
    ) {
        if (date.isBefore(today)) {
            return PAST;
        }

        return date.isEqual(today) ? TODAY : FUTURE;
    }
}
