package gravit.code.inquiry.dto.event;

public record InquiryAnsweredEvent(
        long inquiryId,

        long userId,

        String title
) {
}
