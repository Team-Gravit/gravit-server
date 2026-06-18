package gravit.code.inquiry.dto.response;

import gravit.code.inquiry.domain.InquiryAnswer;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

public record InquiryAnswerResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String content,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime answeredAt
) {
    public static InquiryAnswerResponse from(InquiryAnswer answer) {
        return new InquiryAnswerResponse(
                answer.getContent(),
                answer.getCreatedAt()
        );
    }
}
