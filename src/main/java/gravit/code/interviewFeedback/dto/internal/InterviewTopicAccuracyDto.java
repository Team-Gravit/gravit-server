package gravit.code.interviewFeedback.dto.internal;

import gravit.code.global.util.DecimalRounding;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interviewQuestion.domain.InterviewTopic;

public record InterviewTopicAccuracyDto(
        InterviewTopic topic,

        Long accuracyScoreSum,

        Long accuracyMaxScoreSum
) {
    private static final int PERCENT = 100;

    public double accuracyRate() {
        double questionAccuracyMaxScoreSum = (double) accuracyMaxScoreSum / InterviewSession.QUESTION_COUNT;
        return DecimalRounding.roundToFirstDecimal(accuracyScoreSum * PERCENT / questionAccuracyMaxScoreSum);
    }
}
