package gravit.code.interviewTechStack.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "면접 기술 스택 Response")
public record InterviewTechStackResponse(

        @Schema(
                description = "기술 스택 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long techStackId,

        @Schema(
                description = "기술 스택 코드",
                example = "SPRING",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String code,

        @Schema(
                description = "기술 스택 노출명",
                example = "Spring",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String displayName
) {
}
