package gravit.code.metricReport.dto.internal;

public record ServiceMetricSnapshotDto(

        MetricRangeDto range,

        UserMetricDto users,

        LessonMetricDto lessons,

        InterviewMetricDto interviews
) {
    public static ServiceMetricSnapshotDto of(
            MetricRangeDto range,
            UserMetricDto users,
            LessonMetricDto lessons,
            InterviewMetricDto interviews
    ) {
        return new ServiceMetricSnapshotDto(range, users, lessons, interviews);
    }
}
