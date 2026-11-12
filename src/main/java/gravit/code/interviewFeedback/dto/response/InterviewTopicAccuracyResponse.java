package gravit.code.interviewFeedback.dto.response;

import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewTopicAccuracyResponse(

        @Schema(
                description = "주제",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewTopicResponse topic,

        @Schema(
                description = "주제별 정확도율 (0~100, 소수점 첫째 자리). 완료 세션 문항의 정확도 점수 합 / 문항 정확도 만점 합 x 100",
                example = "42.9",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        double accuracyRate
) {
    public static InterviewTopicAccuracyResponse of(
            InterviewTopic topic,
            double accuracyRate
    ) {
        return InterviewTopicAccuracyResponse.builder()
                .topic(InterviewTopicResponse.from(topic))
                .accuracyRate(accuracyRate)
                .build();
    }
}
