package gravit.code.inquiry.dto.response;

import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryAnswer;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record InquiryDetailResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long id,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String title,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String type,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String content,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String status,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime createdAt,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime updatedAt,

        @Schema(
                description = "어드민 답변 (없으면 null)",
                nullable = true
        )
        InquiryAnswerResponse answer
) {
    public static InquiryDetailResponse of(
            Inquiry inquiry,
            InquiryAnswer answer
    ) {
        return InquiryDetailResponse.builder()
                .id(inquiry.getId())
                .title(inquiry.getTitle())
                .type(inquiry.getType().name())
                .content(inquiry.getContent())
                .status(inquiry.getStatus().name())
                .createdAt(inquiry.getCreatedAt())
                .updatedAt(inquiry.getUpdatedAt())
                .answer(answer == null ? null : InquiryAnswerResponse.from(answer))
                .build();
    }
}
