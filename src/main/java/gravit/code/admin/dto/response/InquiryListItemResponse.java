package gravit.code.admin.dto.response;

import gravit.code.inquiry.domain.Inquiry;
import gravit.code.user.domain.User;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Schema(name = "AdminInquiryListItemResponse")
@Builder(access = AccessLevel.PRIVATE)
public record InquiryListItemResponse(

        long inquiryId,

        String title,

        String type,

        String status,

        long submitterId,

        @Schema(
                description = "작성자 닉네임 (탈퇴한 사용자면 null)",
                nullable = true
        )
        String submitterNickname,

        LocalDateTime createdAt
) {
    public static InquiryListItemResponse of(
            Inquiry inquiry,
            User submitter
    ) {
        return InquiryListItemResponse.builder()
                .inquiryId(inquiry.getId())
                .title(inquiry.getTitle())
                .type(inquiry.getType().name())
                .status(inquiry.getStatus().name())
                .submitterId(inquiry.getUserId())
                .submitterNickname(submitter == null ? null : submitter.getNickname())
                .createdAt(inquiry.getCreatedAt())
                .build();
    }
}
