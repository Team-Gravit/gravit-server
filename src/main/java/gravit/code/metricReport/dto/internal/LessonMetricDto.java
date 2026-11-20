package gravit.code.metricReport.dto.internal;

public record LessonMetricDto(

        long submissionCount,

        long learnerCount,

        Double averageAccuracy
) {
}
