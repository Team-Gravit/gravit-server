package gravit.code.metricReport.dto.internal;

import java.util.List;

public record ReportInquiryMetricDto(

        List<TypeCountDto> newReportCounts,

        long unresolvedReportCount,

        List<ReportItemDto> newReports,

        List<TypeCountDto> newInquiryCounts,

        long pendingInquiryCount,

        List<InquiryItemDto> newInquiries
) {
    public static ReportInquiryMetricDto of(
            List<TypeCountDto> newReportCounts,
            long unresolvedReportCount,
            List<ReportItemDto> newReports,
            List<TypeCountDto> newInquiryCounts,
            long pendingInquiryCount,
            List<InquiryItemDto> newInquiries
    ) {
        return new ReportInquiryMetricDto(
                newReportCounts,
                unresolvedReportCount,
                newReports,
                newInquiryCounts,
                pendingInquiryCount,
                newInquiries
        );
    }

    public long newReportTotal() {
        return newReportCounts.stream()
                .mapToLong(TypeCountDto::count)
                .sum();
    }

    public long newInquiryTotal() {
        return newInquiryCounts.stream()
                .mapToLong(TypeCountDto::count)
                .sum();
    }
}
