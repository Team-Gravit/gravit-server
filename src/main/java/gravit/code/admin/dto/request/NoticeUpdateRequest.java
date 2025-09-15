package gravit.code.admin.dto.request;

import gravit.code.notice.domain.NoticeStatus;

public record NoticeUpdateRequest(
        String title,
        String content,
        NoticeStatus noticeStatus,
        boolean pinned
) {
}
