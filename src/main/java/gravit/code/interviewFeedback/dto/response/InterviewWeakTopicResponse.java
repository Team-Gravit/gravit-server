package gravit.code.interviewFeedback.dto.response;

import gravit.code.interviewQuestion.domain.InterviewTopic;
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
                description = "약점 문항의 주제",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewTopicResponse topic
) {
    public static InterviewWeakTopicResponse of(
            long unitId,
            InterviewTopic topic
    ) {
        return InterviewWeakTopicResponse.builder()
                .unitId(unitId)
                .topic(InterviewTopicResponse.from(topic))
                .build();
    }
}
