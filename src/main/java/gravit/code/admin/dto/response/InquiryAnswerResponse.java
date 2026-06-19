package gravit.code.admin.dto.response;

import gravit.code.inquiry.domain.InquiryAnswer;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(name = "AdminInquiryAnswerResponse")
public record InquiryAnswerResponse(

        long answerId,

        String content,

        @Schema(description = "답변을 작성한 관리자 ID")
        long adminId,

        LocalDateTime answeredAt,

        LocalDateTime updatedAt
) {
    public static InquiryAnswerResponse from(InquiryAnswer answer) {
        return new InquiryAnswerResponse(
                answer.getId(),
                answer.getContent(),
                answer.getAdminId(),
                answer.getCreatedAt(),
                answer.getUpdatedAt()
        );
    }
}
