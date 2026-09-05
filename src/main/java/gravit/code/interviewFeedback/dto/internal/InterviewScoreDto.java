package gravit.code.interviewFeedback.dto.internal;

import lombok.AccessLevel;
import lombok.Builder;

import java.math.BigDecimal;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewScoreDto(

        int accuracyScore,

        int structureScore,

        int clarityScore,

        BigDecimal accuracyBaseRatio,

        BigDecimal accuracyMultiplier,

        Integer irrelevantStatementCount,

        String improvementSuggestion
) {
    private static final int NO_RESPONSE_SCORE = 0;

    public static InterviewScoreDto of(
            int accuracyScore,
            int structureScore,
            int clarityScore,
            BigDecimal accuracyBaseRatio,
            BigDecimal accuracyMultiplier,
            Integer irrelevantStatementCount,
            String improvementSuggestion
    ) {
        return InterviewScoreDto.builder()
                .accuracyScore(accuracyScore)
                .structureScore(structureScore)
                .clarityScore(clarityScore)
                .accuracyBaseRatio(accuracyBaseRatio)
                .accuracyMultiplier(accuracyMultiplier)
                .irrelevantStatementCount(irrelevantStatementCount)
                .improvementSuggestion(improvementSuggestion)
                .build();
    }

    public static InterviewScoreDto noResponse() {
        return InterviewScoreDto.builder()
                .accuracyScore(NO_RESPONSE_SCORE)
                .structureScore(NO_RESPONSE_SCORE)
                .clarityScore(NO_RESPONSE_SCORE)
                .accuracyBaseRatio(null)
                .accuracyMultiplier(null)
                .irrelevantStatementCount(null)
                .improvementSuggestion(null)
                .build();
    }

    public int getDeliveryScore() {
        return structureScore + clarityScore;
    }
}
