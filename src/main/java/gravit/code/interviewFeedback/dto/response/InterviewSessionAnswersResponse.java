package gravit.code.interviewFeedback.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionAnswersResponse(

        @Schema(
                description = "세션 ID",
                example = "12",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "문항별 상세 (문항 순서대로)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewAnswerDetailResponse> answers
) {
    public static InterviewSessionAnswersResponse of(
            long sessionId,
            List<InterviewAnswerDetailResponse> answers
    ) {
        return InterviewSessionAnswersResponse.builder()
                .sessionId(sessionId)
                .answers(answers)
                .build();
    }
}
