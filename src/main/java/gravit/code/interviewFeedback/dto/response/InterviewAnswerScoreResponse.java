package gravit.code.interviewFeedback.dto.response;

import gravit.code.interviewFeedback.dto.internal.InterviewAnswerScoreDto;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewAnswerScoreResponse(

        @Schema(
                description = "문항 순서 (1~5)",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "문항 주제",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewTopicResponse topic,

        @Schema(
                description = "문항 정확도 점수 (만점 14)",
                example = "12",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int accuracyScore,

        @Schema(
                description = "문항 전달력 점수 (구조성 + 명료성, 만점 6)",
                example = "5",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int deliveryScore
) {
    public static InterviewAnswerScoreResponse from(InterviewAnswerScoreDto score) {
        return InterviewAnswerScoreResponse.builder()
                .displayOrder(score.displayOrder())
                .topic(InterviewTopicResponse.from(score.topic()))
                .accuracyScore(score.accuracyScore())
                .deliveryScore(score.structureScore() + score.clarityScore())
                .build();
    }
}
