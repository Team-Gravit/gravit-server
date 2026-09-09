package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewStackGroup;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewStackGroupResponse(

        @Schema(
                description = "직군 그룹 값",
                example = "SERVER",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewStackGroup stackGroup,

        @Schema(
                description = "직군 그룹 표시명",
                example = "Server",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String displayName
) {
    public static InterviewStackGroupResponse from(InterviewStackGroup stackGroup) {
        return InterviewStackGroupResponse.builder()
                .stackGroup(stackGroup)
                .displayName(stackGroup.getDisplayName())
                .build();
    }
}
