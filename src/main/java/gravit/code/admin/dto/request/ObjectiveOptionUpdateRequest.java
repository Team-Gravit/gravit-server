package gravit.code.admin.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ObjectiveOptionUpdateRequest(

        @NotNull(message = "optionId 는 필수입니다.")
        Long optionId,

        @NotBlank(message = "옵션 내용은 비어있을 수 없습니다.")
        String content,

        @NotBlank(message = "옵션 해설은 비어있을 수 없습니다.")
        String explanation,

        @JsonProperty("isAnswer")
        @NotNull(message = "isAnswer 는 필수입니다.")
        Boolean isAnswer
) {
}
