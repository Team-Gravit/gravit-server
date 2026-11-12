package gravit.code.admin.dto.response;

import gravit.code.admin.domain.staging.AnswerStaging;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record StagingAnswerResponse(

        long answerId,

        String content,

        String explanation
) {
    public static StagingAnswerResponse from(AnswerStaging answer) {
        return StagingAnswerResponse.builder()
                .answerId(answer.getId())
                .content(answer.getContent())
                .explanation(answer.getExplanation())
                .build();
    }
}
