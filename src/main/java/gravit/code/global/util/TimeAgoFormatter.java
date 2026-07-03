package gravit.code.global.util;

import gravit.code.global.consts.TimeZoneConst;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

// 생성 시각을 "방금 전 / N분 전 / N시간 전 / N일 전(최대 7일)" 상대 표현으로 변환한다
public final class TimeAgoFormatter {

    private static final long MAX_DAYS = 7;

    private TimeAgoFormatter() {
    }

    public static String format(LocalDateTime createdAt) {
        LocalDateTime now = LocalDateTime.now(TimeZoneConst.KST);

        long minutes = ChronoUnit.MINUTES.between(createdAt, now);
        if (minutes < 1) return "방금 전";
        if (minutes < 60) return minutes + "분 전";

        long hours = ChronoUnit.HOURS.between(createdAt, now);
        if (hours < 24) return hours + "시간 전";

        long days = ChronoUnit.DAYS.between(createdAt, now);
        return Math.min(days, MAX_DAYS) + "일 전";
    }
}
