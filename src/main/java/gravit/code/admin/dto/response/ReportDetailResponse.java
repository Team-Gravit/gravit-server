package gravit.code.admin.dto.response;

import gravit.code.report.domain.ReportType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "신고 상세 조회 Response")
public record ReportDetailResponse(
        Long reportId,
        ReportType reportType,
        Long problemId,
        String content,
        Boolean isResolved,
        LocalDateTime submittedAt
) {
}
