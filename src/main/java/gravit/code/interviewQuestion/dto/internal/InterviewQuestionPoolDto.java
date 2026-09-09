package gravit.code.interviewQuestion.dto.internal;

import gravit.code.interviewQuestion.domain.InterviewTopic;

public record InterviewQuestionPoolDto(

        InterviewTopic topic,

        Long questionId
) {
}
