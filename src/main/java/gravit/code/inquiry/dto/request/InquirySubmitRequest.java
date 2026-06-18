package gravit.code.inquiry.dto.request;

import gravit.code.global.annotation.EnumValidation;
import gravit.code.inquiry.domain.InquiryType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "문의 제출 request")
public record InquirySubmitRequest(

        @Schema(
                description = "문의 제목",
                example = "특정 화면에서 앱이 종료돼요"
        )
        @NotBlank(message = "문의 제목이 비어있습니다.")
        String title,

        @Schema(
                description = "문의 유형",
                example = "BUG_REPORT/CONTENT_ERROR/FEATURE_SUGGESTION/OTHER"
        )
        @NotBlank(message = "문의 유형이 비어있습니다.")
        @EnumValidation(target = InquiryType.class, message = "유효하지 않은 문의 유형입니다.")
        String type,

        @Schema(
                description = "문의 내용",
                example = "오답노트 화면에 진입하면 앱이 강제 종료됩니다."
        )
        @NotBlank(message = "문의 내용이 비어있습니다.")
        String content

) {
}
