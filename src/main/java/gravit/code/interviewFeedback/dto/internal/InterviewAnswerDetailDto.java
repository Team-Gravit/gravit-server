package gravit.code.interviewFeedback.dto.internal;

import gravit.code.interviewQuestion.domain.InterviewTopic;

public record InterviewAnswerDetailDto(
        int displayOrder,

        long questionId,

        InterviewTopic topic,

        String questionContent,

        String answerContent,

        String audioKey,

        String modelAnswer,

        String improvementSuggestion,

        int accuracyScore,

        int structureScore,

        int clarityScore
) {
}
