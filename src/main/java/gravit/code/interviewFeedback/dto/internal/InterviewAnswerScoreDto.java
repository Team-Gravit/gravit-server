package gravit.code.interviewFeedback.dto.internal;

import gravit.code.interviewQuestion.domain.InterviewTopic;

public record InterviewAnswerScoreDto(
        int displayOrder,

        InterviewTopic topic,

        long unitId,

        int accuracyScore,

        int structureScore,

        int clarityScore
) {
    public int earnedScore() {
        return accuracyScore + structureScore + clarityScore;
    }
}
