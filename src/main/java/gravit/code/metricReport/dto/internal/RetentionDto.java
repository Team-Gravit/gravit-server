package gravit.code.metricReport.dto.internal;

public record RetentionDto(

        long cohortSize,

        long retainedCount
) {
    public Double rate() {
        if (cohortSize == 0) {
            return null;
        }

        return (double) retainedCount / cohortSize;
    }
}
