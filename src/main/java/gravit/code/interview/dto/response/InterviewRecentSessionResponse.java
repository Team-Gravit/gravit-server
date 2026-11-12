package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewSession;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewRecentSessionResponse(

        @Schema(
                description = "세션 ID",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "시도 차수",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sequence,

        @Schema(
                description = "세션 정확도 점수",
                example = "52",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int accuracyScore,

        @Schema(
                description = "세션 전달력 점수 (구조성 + 명료성)",
                example = "24",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int deliveryScore
) {
    public static InterviewRecentSessionResponse from(InterviewSession session) {
        return InterviewRecentSessionResponse.builder()
                .sessionId(session.getId())
                .sequence(session.getAttemptCount())
                .accuracyScore(session.getAccuracyScore())
                .deliveryScore(session.getDeliveryScore())
                .build();
    }
}
