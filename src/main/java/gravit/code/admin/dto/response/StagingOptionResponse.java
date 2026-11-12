package gravit.code.admin.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.admin.domain.staging.OptionStaging;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record StagingOptionResponse(

        long optionId,

        String content,

        String explanation,

        @JsonProperty("isAnswer")
        boolean isAnswer
) {
    public static StagingOptionResponse from(OptionStaging option) {
        return StagingOptionResponse.builder()
                .optionId(option.getId())
                .content(option.getContent())
                .explanation(option.getExplanation())
                .isAnswer(option.isAnswer())
                .build();
    }
}
