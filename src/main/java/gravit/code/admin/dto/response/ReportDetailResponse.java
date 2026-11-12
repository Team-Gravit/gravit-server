package gravit.code.admin.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record ReportDetailResponse(

        long reportId,

        ReportType reportType,

        long problemId,

        String content,

        @JsonProperty("isResolved")
        boolean isResolved,

        LocalDateTime submittedAt
) {
    public static ReportDetailResponse from(Report report) {
        return ReportDetailResponse.builder()
                .reportId(report.getId())
                .reportType(report.getReportType())
                .problemId(report.getProblemId())
                .content(report.getContent())
                .isResolved(report.isResolved())
                .submittedAt(report.getSubmittedAt())
                .build();
    }
}
