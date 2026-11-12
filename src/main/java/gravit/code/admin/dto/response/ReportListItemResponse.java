package gravit.code.admin.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record ReportListItemResponse(

        long reportId,

        ReportType reportType,

        long problemId,

        @JsonProperty("isResolved")
        boolean isResolved,

        LocalDateTime submittedAt
) {
    public static ReportListItemResponse from(Report report) {
        return ReportListItemResponse.builder()
                .reportId(report.getId())
                .reportType(report.getReportType())
                .problemId(report.getProblemId())
                .isResolved(report.isResolved())
                .submittedAt(report.getSubmittedAt())
                .build();
    }
}
