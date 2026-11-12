package gravit.code.inquiry.dto.response;

import gravit.code.inquiry.domain.Inquiry;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

public record InquirySummaryResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long id,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String title,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String type,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String status,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime createdAt
) {
    public static InquirySummaryResponse from(Inquiry inquiry) {
        return new InquirySummaryResponse(
                inquiry.getId(),
                inquiry.getTitle(),
                inquiry.getType().name(),
                inquiry.getStatus().name(),
                inquiry.getCreatedAt()
        );
    }
}
