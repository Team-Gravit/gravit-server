package gravit.code.report.dto.request;

import gravit.code.global.enums.Enum;
import gravit.code.report.domain.ReportType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ProblemReportSubmitRequest(

        @Schema(
                description = "신고 유형",
                example = "TYPO_ERROR/CONTENT_ERROR/ANSWER_ERROR/OTHER_ERROR"
        )
        @NotNull(message = "신고 유형이 비어있습니다.")
        @Enum(target = ReportType.class, message = "유효하지 않은 신고 타입입니다.")
        ReportType reportType,

        @Schema(
                description = "신고 사유(입력이 없을 경우 \"-\" 이렇게 보내주세요.)",
                example = "문제에 오타가 있어요."
        )
        @NotBlank(message = "신고 사유가 비어있습니다.")
        String content,

        @Schema(
                description = "챕터 아이디" ,
                example = "1L"
        )
        @NotNull(message = "챕터 아이디가 비어있습니다.")
        Long chapterId,

        @Schema(
                description = "유닛 아이디",
                example = "1L"
        )
        @NotNull(message = "유닛 아이디가 비어있습니다.")
        Long unitId,

        @Schema(
                description = "레슨 아이디",
                example = "1L"
        )
        @NotNull(message = "레슨 아이디가 비어있습니다.")
        Long lessonId,

        @Schema(
                description = "문제 아이디",
                example = "1L"
        )
        @NotNull(message = "문제 아이디가 비어있습니다.")
        Long problemId

) {
}
