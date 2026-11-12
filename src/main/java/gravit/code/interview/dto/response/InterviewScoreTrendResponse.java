package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewSession;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewScoreTrendResponse(

        @Schema(
                description = "시도 차수",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sequence,

        @Schema(
                description = "세션 총점",
                example = "78",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int score
) {
    public static InterviewScoreTrendResponse from(InterviewSession session) {
        return InterviewScoreTrendResponse.builder()
                .sequence(session.getAttemptCount())
                .score(session.getScore())
                .build();
    }
}
