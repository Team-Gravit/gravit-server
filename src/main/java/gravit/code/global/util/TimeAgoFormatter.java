package gravit.code.global.util;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

@Component
@RequiredArgsConstructor
public class TimeAgoFormatter {

    private static final long DAYS_PER_WEEK = 7;

    private final Clock clock;

    public String format(LocalDateTime createdAt) {
        LocalDateTime now = LocalDateTime.now(clock);

        long minutes = ChronoUnit.MINUTES.between(createdAt, now);
        if (minutes < 60) {
            return Math.max(1, minutes) + "분 전";
        }

        long hours = ChronoUnit.HOURS.between(createdAt, now);
        if (hours < 24) {
            return hours + "시간 전";
        }

        long days = ChronoUnit.DAYS.between(createdAt, now);
        if (days == 1) {
            return "어제";
        }
        if (days < DAYS_PER_WEEK) {
            return days + "일 전";
        }
        return (days / DAYS_PER_WEEK) + "주 전";
    }
}
