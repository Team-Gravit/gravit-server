package gravit.code.interviewFeedback.dto.internal;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewGradedAnswerDto(

        long answerId,

        InterviewScoreDto score
) {
    public static InterviewGradedAnswerDto of(
            long answerId,
            InterviewScoreDto score
    ) {
        return InterviewGradedAnswerDto.builder()
                .answerId(answerId)
                .score(score)
                .build();
    }
}
