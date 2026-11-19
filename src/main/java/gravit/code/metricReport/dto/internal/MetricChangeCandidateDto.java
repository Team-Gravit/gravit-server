package gravit.code.metricReport.dto.internal;

public record MetricChangeCandidateDto(

        String label,

        double current,

        double previous,

        String unit,

        boolean isDecimal
) {
    public static MetricChangeCandidateDto of(
            String label,
            double current,
            double previous,
            String unit,
            boolean isDecimal
    ) {
        return new MetricChangeCandidateDto(label, current, previous, unit, isDecimal);
    }

    public double diff() {
        return current - previous;
    }

    public double changeRate() {
        return Math.abs(diff()) / previous;
    }
}
