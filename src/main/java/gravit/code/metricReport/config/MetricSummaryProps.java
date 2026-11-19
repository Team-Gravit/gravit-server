package gravit.code.metricReport.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

@ConfigurationProperties(prefix = "metric-report.summary")
public record MetricSummaryProps(
        boolean enabled,
        String model,
        Duration timeout
) {
}
