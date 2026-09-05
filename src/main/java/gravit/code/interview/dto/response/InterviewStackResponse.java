package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewStack;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewStackResponse(

        @Schema(
                description = "스택 값",
                example = "JAVA_SPRING_BOOT",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewStack stack,

        @Schema(
                description = "스택 표시명",
                example = "Java + Spring Boot",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String displayName
) {
    public static InterviewStackResponse from(InterviewStack stack) {
        return InterviewStackResponse.builder()
                .stack(stack)
                .displayName(stack.getDisplayName())
                .build();
    }
}
