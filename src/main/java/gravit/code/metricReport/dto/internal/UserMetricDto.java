package gravit.code.metricReport.dto.internal;

import java.time.YearMonth;

public record UserMetricDto(

        long totalUsers,

        long newSignups,

        double averageDailyActiveUsers,

        long activeUsers,

        long monthlyActiveUsers,

        YearMonth mauMonth,

        boolean mauInProgress,

        RetentionDto d1Retention,

        RetentionDto d7Retention
) {
    public static UserMetricDto of(
            long totalUsers,
            long newSignups,
            double averageDailyActiveUsers,
            long activeUsers,
            long monthlyActiveUsers,
            YearMonth mauMonth,
            boolean mauInProgress,
            RetentionDto d1Retention,
            RetentionDto d7Retention
    ) {
        return new UserMetricDto(
                totalUsers,
                newSignups,
                averageDailyActiveUsers,
                activeUsers,
                monthlyActiveUsers,
                mauMonth,
                mauInProgress,
                d1Retention,
                d7Retention
        );
    }
}
