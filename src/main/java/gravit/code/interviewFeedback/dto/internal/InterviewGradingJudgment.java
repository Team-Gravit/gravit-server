package gravit.code.interviewFeedback.dto.internal;

import java.util.List;

public record InterviewGradingJudgment(

        List<ConceptJudgment> conceptJudgments,

        List<WrongStatement> wrongStatements,

        boolean conclusionFirst,

        int irrelevantStatementCount,

        String improvementSuggestion
) {
    public record ConceptJudgment(

            String conceptName,

            boolean covered,

            String quote,

            String missingFeedbackText
    ) {
    }

    public record WrongStatement(

            String quotedText,

            String correctionText
    ) {
    }
}
