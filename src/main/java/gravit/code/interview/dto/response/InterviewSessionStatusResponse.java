package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewSessionStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "면접 세션 상태 Response")
public record InterviewSessionStatusResponse(

        @Schema(
                description = "세션 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "세션 상태",
                example = "GRADING",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewSessionStatus status
) {
    public static InterviewSessionStatusResponse create(
            long sessionId,
            InterviewSessionStatus status
    ) {
        return InterviewSessionStatusResponse.builder()
                .sessionId(sessionId)
                .status(status)
                .build();
    }
}
