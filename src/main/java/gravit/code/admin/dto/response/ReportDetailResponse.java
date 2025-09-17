package gravit.code.admin.dto.response;

import gravit.code.report.domain.ReportType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "신고 상세 조회 Response")
public record ReportDetailResponse(

        @Schema(
                description = "신고 ID",
                example = "1"
        )
        Long reportId,

        @Schema(
                description = "신고 유형"
        )
        ReportType reportType,

        @Schema(
                description = "문제 ID",
                example = "123"
        )
        Long problemId,

        @Schema(
                description = "신고 내용",
                example = "문제에 오타가 있습니다."
        )
        String content,

        @Schema(
                description = "해결 여부",
                example = "false"
        )
        Boolean isResolved,

        @Schema(
                description = "신고 접수 시간"
        )
        LocalDateTime submittedAt
) {
}
