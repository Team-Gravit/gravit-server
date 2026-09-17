package gravit.code.admin.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.option.domain.Option;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ProblemOptionResponse(

        long optionId,

        String content,

        String explanation,

        @JsonProperty("isAnswer")
        boolean isAnswer
) {
    public static ProblemOptionResponse from(Option option) {
        return ProblemOptionResponse.builder()
                .optionId(option.getId())
                .content(option.getContent())
                .explanation(option.getExplanation())
                .isAnswer(option.isAnswer())
                .build();
    }
}
