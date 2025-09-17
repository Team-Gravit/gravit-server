package gravit.code.admin.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "옵션 수정 Request")
public record OptionUpdateRequest(

        @Schema(
                description = "옵션 id",
                example = "1"
        )
        @NotNull(message = "옵션 아이디가 비어있습니다.")
        Long optionId,

        @Schema(
                description = "내용",
                example = "tail 포인터가 더 빠른 접근을 제공"
        )
        @NotBlank(message = "내용이 비어있습니다.")
        String content,

        @Schema(
                description = "설명",
                example = "실제로 tail 포인터를 활용했을 때 속도가 더 빠르다."
        )
        @NotBlank(message = "설명이 비어있습니다.")
        String explanation,

        @Schema(
                description = "정답 여부",
                example = "true"
        )
        @NotNull(message = "정답 여부가 비어있습니다.")
        Boolean isAnswer
) {
}
