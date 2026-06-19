package gravit.code.admin.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "문의 답변 등록 request")
public record InquiryAnswerCreateRequest(

        @Schema(description = "답변 내용", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank
        String content
) {
}
