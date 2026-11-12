package gravit.code.admin.dto.response;

import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record NoticeListItemResponse(

        long noticeId,

        String title,

        NoticeStatus status,

        boolean pinned,

        LocalDateTime publishedAt,

        LocalDateTime createdAt
) {
    public static NoticeListItemResponse from(Notice notice) {
        return NoticeListItemResponse.builder()
                .noticeId(notice.getId())
                .title(notice.getTitle())
                .status(notice.getStatus())
                .pinned(notice.isPinned())
                .publishedAt(notice.getPublishedAt())
                .createdAt(notice.getCreatedAt())
                .build();
    }
}
