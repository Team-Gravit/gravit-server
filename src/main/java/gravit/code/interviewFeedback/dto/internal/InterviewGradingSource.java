package gravit.code.interviewFeedback.dto.internal;

import gravit.code.interviewQuestion.domain.InterviewConceptType;

import java.util.List;

public record InterviewGradingSource(

        String question,

        List<Concept> concepts,

        String answer
) {
    public record Concept(

            String name,

            InterviewConceptType type
    ) {
    }
}
