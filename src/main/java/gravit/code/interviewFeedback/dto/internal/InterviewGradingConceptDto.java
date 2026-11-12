package gravit.code.interviewFeedback.dto.internal;

import gravit.code.interviewQuestion.domain.InterviewConceptType;

public record InterviewGradingConceptDto(

        String name,

        InterviewConceptType type
) {
}
