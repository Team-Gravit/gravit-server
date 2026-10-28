package gravit.code.interviewFeedback.dto.response;

import gravit.code.interviewFeedback.dto.internal.InterviewAnswerScoreDto;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewWeakTopicResponse(

        @Schema(
                description = "학습 이동 대상 유닛 ID",
                example = "7",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long unitId,

        @Schema(
                description = "학습 이동 대상 유닛 제목",
                example = "정렬",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String unitTitle,

        @Schema(
                description = "약점 문항의 주제",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewTopicResponse topic
) {
    public static InterviewWeakTopicResponse from(InterviewAnswerScoreDto score) {
        return InterviewWeakTopicResponse.builder()
                .unitId(score.unitId())
                .unitTitle(score.unitTitle())
                .topic(InterviewTopicResponse.from(score.topic()))
                .build();
    }
}
