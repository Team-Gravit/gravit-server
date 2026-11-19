package gravit.code.metricReport.support;

import gravit.code.metricReport.dto.internal.RetentionDto;
import org.springframework.stereotype.Component;

@Component
public class MetricChangeFormatter {

    public static final int SMALL_SAMPLE_THRESHOLD = 10;

    private static final double UNCHANGED_THRESHOLD = 0.05;
    private static final String UNCHANGED = "→";
    private static final String UP = "▲";
    private static final String DOWN = "▼";

    public String number(long value) {
        return String.format("%,d", value);
    }

    public String decimal(double value) {
        return String.format("%,.1f", value);
    }

    public String pill(String text) {
        if (text == null || text.isEmpty()) {
            return "";
        }

        return "`" + text + "`";
    }

    public String countChange(
            long current,
            Long previous
    ) {
        if (previous == null) {
            return "";
        }

        long diff = current - previous;
        if (diff == 0) {
            return UNCHANGED;
        }

        String change = arrow(diff) + number(Math.abs(diff));
        if (previous < SMALL_SAMPLE_THRESHOLD) {
            return change;
        }

        double changeRate = (double) diff / previous * 100;
        return change + " · " + String.format("%+.1f%%", changeRate);
    }

    private String arrow(double diff) {
        return diff > 0 ? UP : DOWN;
    }

    public String averageChange(
            double current,
            Double previous
    ) {
        if (previous == null) {
            return "";
        }

        double diff = current - previous;
        if (Math.abs(diff) < UNCHANGED_THRESHOLD) {
            return UNCHANGED;
        }

        return arrow(diff) + String.format("%.1f", Math.abs(diff));
    }

    public String percentPointChange(
            Double currentPercent,
            Double previousPercent
    ) {
        if (currentPercent == null) {
            return "";
        }

        if (previousPercent == null) {
            return "직전 없음";
        }

        double diff = currentPercent - previousPercent;
        if (Math.abs(diff) < UNCHANGED_THRESHOLD) {
            return UNCHANGED;
        }

        return arrow(diff) + String.format("%.1f%%p", Math.abs(diff));
    }

    public String retention(
            RetentionDto current,
            RetentionDto previous
    ) {
        if (current.cohortSize() == 0) {
            return pill("가입자 없음");
        }

        if (current.cohortSize() < SMALL_SAMPLE_THRESHOLD) {
            return "**" + number(current.cohortSize()) + "명 중 " + number(current.retainedCount()) + "명** " + pill("표본 적음");
        }

        double currentPercent = current.rate() * 100;
        String value = "**" + String.format("%.1f%%", currentPercent) + "** ("
                + number(current.retainedCount()) + "/" + number(current.cohortSize()) + "명)";

        if (previous == null || previous.cohortSize() < SMALL_SAMPLE_THRESHOLD) {
            return value;
        }

        return value + " " + pill(percentPointChange(currentPercent, previous.rate() * 100));
    }
}
