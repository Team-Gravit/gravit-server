package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewAnswerStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "면접 답변 제출 Response")
public record InterviewAnswerSubmitResponse(

        @Schema(
                description = "답변 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long answerId,

        @Schema(
                description = "답변 상태",
                example = "ANSWERED",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewAnswerStatus status
) {
    public static InterviewAnswerSubmitResponse create(
            long answerId,
            InterviewAnswerStatus status
    ) {
        return InterviewAnswerSubmitResponse.builder()
                .answerId(answerId)
                .status(status)
                .build();
    }
}
