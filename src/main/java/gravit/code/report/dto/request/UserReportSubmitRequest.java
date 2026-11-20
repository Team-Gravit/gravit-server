package gravit.code.report.dto.request;

import gravit.code.global.annotation.EnumValidation;
import gravit.code.report.domain.UserReportType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Schema(description = "사용자 신고 제출 request")
public record UserReportSubmitRequest(

        @Schema(
                description = "신고할 사용자 아이디",
                example = "2"
        )
        @NotNull(message = "신고할 사용자 아이디가 비어있습니다.")
        Long targetUserId,

        @Schema(
                description = "신고 유형",
                example = "INAPPROPRIATE_NICKNAME/OTHER"
        )
        @NotBlank(message = "신고 유형이 비어있습니다.")
        @EnumValidation(target = UserReportType.class, message = "유효하지 않은 신고 유형입니다.")
        String reportType,

        @Schema(
                description = "신고 사유 (선택, 500자 이하)",
                example = "닉네임에 욕설이 들어 있어요."
        )
        @Size(max = 500, message = "신고 사유는 500자 이하여야 합니다.")
        String content
) {
}
