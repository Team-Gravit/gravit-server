package gravit.code.admin.dto.response;

import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryAnswer;
import gravit.code.user.domain.User;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Schema(name = "AdminInquiryDetailResponse")
@Builder(access = AccessLevel.PRIVATE)
public record InquiryDetailResponse(

        long inquiryId,

        String title,

        String type,

        String content,

        String status,

        long submitterId,

        @Schema(
                description = "작성자 닉네임 (탈퇴한 사용자면 null)",
                nullable = true
        )
        String submitterNickname,

        @Schema(
                description = "작성자 이메일 (탈퇴한 사용자면 null)",
                nullable = true
        )
        String submitterEmail,

        LocalDateTime createdAt,

        LocalDateTime updatedAt,

        @Schema(
                description = "관리자 답변 (없으면 null)",
                nullable = true
        )
        InquiryAnswerResponse answer
) {
    public static InquiryDetailResponse of(
            Inquiry inquiry,
            User submitter,
            InquiryAnswer answer
    ) {
        return InquiryDetailResponse.builder()
                .inquiryId(inquiry.getId())
                .title(inquiry.getTitle())
                .type(inquiry.getType().name())
                .content(inquiry.getContent())
                .status(inquiry.getStatus().name())
                .submitterId(inquiry.getUserId())
                .submitterNickname(submitter == null ? null : submitter.getNickname())
                .submitterEmail(submitter == null ? null : submitter.getEmail())
                .createdAt(inquiry.getCreatedAt())
                .updatedAt(inquiry.getUpdatedAt())
                .answer(answer == null ? null : InquiryAnswerResponse.from(answer))
                .build();
    }
}
