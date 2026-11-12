package gravit.code.admin.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;

public record StagingOptionUpdateRequest(

        String content,

        String explanation,

        @JsonProperty("isAnswer")
        Boolean isAnswer
) {
}
