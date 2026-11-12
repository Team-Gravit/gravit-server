package gravit.code.interviewFeedback.dto.response;

import gravit.code.interview.domain.InterviewSession;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;
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
                description = "세션 시작 시각",
                example = "2026-09-04T10:15:30",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        LocalDateTime startedAt,

        @Schema(
                description = "문항별 상세 (문항 순서대로)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewAnswerDetailResponse> answers
) {
    public static InterviewSessionAnswersResponse of(
            InterviewSession session,
            List<InterviewAnswerDetailResponse> answers
    ) {
        return InterviewSessionAnswersResponse.builder()
                .sessionId(session.getId())
                .startedAt(session.getStartedAt())
                .answers(answers)
                .build();
    }
}
