package gravit.code.metricReport.dto.internal;

import gravit.code.metricReport.domain.MetricPeriod;

import java.time.LocalDateTime;

public record ServiceMetricReportDto(

        MetricPeriod period,

        ServiceMetricSnapshotDto current,

        ServiceMetricSnapshotDto previous,

        ReportInquiryMetricDto reportsAndInquiries,

        LocalDateTime generatedAt
) {
    public static ServiceMetricReportDto of(
            MetricPeriod period,
            ServiceMetricSnapshotDto current,
            ServiceMetricSnapshotDto previous,
            ReportInquiryMetricDto reportsAndInquiries,
            LocalDateTime generatedAt
    ) {
        return new ServiceMetricReportDto(
                period,
                current,
                previous,
                reportsAndInquiries,
                generatedAt
        );
    }

    public boolean hasPrevious() {
        return previous != null;
    }
}
