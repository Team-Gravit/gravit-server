package gravit.code.interview.dto.request;

import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewLevel;
import gravit.code.interview.domain.InterviewMode;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "면접 세션 생성 Request")
public record InterviewSessionCreateRequest(

        @Schema(
                description = "면접 모드",
                example = "JOB_SPECIFIC",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull
        InterviewMode mode,

        @Schema(
                description = "답변 입력 방식. 현재는 TEXT만 지원합니다",
                example = "TEXT",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull
        InterviewInputType inputType,

        @Schema(
                description = "세션 레벨",
                example = "MEDIUM",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull
        InterviewLevel level,

        @Schema(
                description = "기술 스택 아이디. 직무별 모드에서만 보냅니다",
                example = "1"
        )
        Long techStackId
) {
}
