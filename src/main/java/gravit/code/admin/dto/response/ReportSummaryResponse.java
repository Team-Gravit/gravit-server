package gravit.code.admin.dto.response;

import gravit.code.report.domain.ReportType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "신고 조회 Response")
public record ReportSummaryResponse(
        Long reportId,
        ReportType reportType,
        Long problemId,
        Boolean isResolved,
        LocalDateTime submittedAt
) {
}
