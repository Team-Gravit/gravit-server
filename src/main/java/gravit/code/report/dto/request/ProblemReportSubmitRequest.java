package gravit.code.report.dto.request;

import gravit.code.global.enums.Enum;
import gravit.code.report.domain.ReportType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "문제 신고 제출 request")
public record ProblemReportSubmitRequest(

        @Schema(
                description = "신고 유형",
                example = "TYPO_ERROR/CONTENT_ERROR/ANSWER_ERROR/OTHER_ERROR"
        )
        @NotBlank(message = "신고 유형이 비어있습니다.")
        @Enum(target = ReportType.class, message = "유효하지 않은 신고 유형입니다.")
        String reportType,

        @Schema(
                description = "신고 사유",
                example = "문제에 오타가 있어요."
        )
        @NotNull
        String content,

        @Schema(
                description = "문제 아이디",
                example = "1L"
        )
        @NotNull(message = "문제 아이디가 비어있습니다.")
        Long problemId

) {
}
