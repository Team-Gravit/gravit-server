package gravit.code.interviewFeedback.dto.internal;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionScoreDto(

        int accuracyScore,

        int deliveryScore
) {
    public static InterviewSessionScoreDto of(
            int accuracyScore,
            int deliveryScore
    ) {
        return InterviewSessionScoreDto.builder()
                .accuracyScore(accuracyScore)
                .deliveryScore(deliveryScore)
                .build();
    }
}
