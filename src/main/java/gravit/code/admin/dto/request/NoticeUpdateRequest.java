package gravit.code.admin.dto.request;

import gravit.code.notice.domain.NoticeStatus;

public record NoticeUpdateRequest(
        Long noticeId,
        String title,
        String content,
        NoticeStatus status,
        boolean pinned
) {
}
