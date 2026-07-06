package gravit.code.global.event;

public record InquiryAnsweredEvent(
        long inquiryId,
        long userId,
        String title
) {
}
