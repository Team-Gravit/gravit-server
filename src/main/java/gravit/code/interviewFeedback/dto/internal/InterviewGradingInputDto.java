package gravit.code.interviewFeedback.dto.internal;

import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;

import java.util.List;

public record InterviewGradingInputDto(

        String questionContent,

        String modelAnswer,

        List<InterviewGradingConceptDto> concepts,

        String answerContent
) {
    public static InterviewGradingInputDto of(
            InterviewQuestion question,
            List<InterviewQuestionConcept> concepts,
            String answerContent
    ) {
        List<InterviewGradingConceptDto> inputConcepts = concepts.stream()
                .map(concept -> new InterviewGradingConceptDto(concept.getName(), concept.getType()))
                .toList();

        return new InterviewGradingInputDto(
                question.getContent(),
                question.getModelAnswer(),
                inputConcepts,
                answerContent
        );
    }
}
