package gravit.code.admin.dto.response;

import gravit.code.answer.domain.Answer;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ProblemAnswerResponse(

        long answerId,

        String content,

        String explanation
) {
    public static ProblemAnswerResponse from(Answer answer) {
        return ProblemAnswerResponse.builder()
                .answerId(answer.getId())
                .content(answer.getContent())
                .explanation(answer.getExplanation())
                .build();
    }
}
