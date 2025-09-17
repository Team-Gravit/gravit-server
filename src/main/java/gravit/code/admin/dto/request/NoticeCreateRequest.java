package gravit.code.admin.dto.request;

import gravit.code.notice.domain.NoticeStatus;

public record NoticeCreateRequest(
        String title,
        String content,
        NoticeStatus status,
        boolean pinned
) {
}
