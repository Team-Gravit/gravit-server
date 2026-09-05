package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewSessionStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionStatusResponse(

        @Schema(
                description = "면접 세션 ID",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "세션 상태. IN_PROGRESS(진행 중) | GRADING(채점 중) | GRADING_FAILED(채점 실패) | COMPLETED(완료) | ABANDONED(취소)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewSessionStatus status
) {
    public static InterviewSessionStatusResponse of(
            long sessionId,
            InterviewSessionStatus status
    ) {
        return InterviewSessionStatusResponse.builder()
                .sessionId(sessionId)
                .status(status)
                .build();
    }
}
