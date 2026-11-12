package gravit.code.interviewQuestion.dto.response;

import gravit.code.interviewQuestion.domain.InterviewTopic;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewTopicResponse(

        @Schema(
                description = "주제 태그",
                example = "DATA_STRUCTURE",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewTopic topic,

        @Schema(
                description = "주제 표시명",
                example = "자료구조",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String displayName
) {
    public static InterviewTopicResponse from(InterviewTopic topic) {
        return InterviewTopicResponse.builder()
                .topic(topic)
                .displayName(topic.getDisplayName())
                .build();
    }
}
