package gravit.code.notice.dto.event;

public record NoticeCreatedEvent(
        long noticeId,

        String title
) {
}
