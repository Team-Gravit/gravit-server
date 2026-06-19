package gravit.code.admin.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "문의 답변 수정 request")
public record InquiryAnswerUpdateRequest(

        @Schema(description = "수정할 답변 내용", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank
        String content
) {
}
