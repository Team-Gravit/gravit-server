package gravit.code.admin.dto.response;

import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Schema(name = "AdminNoticeDetailResponse")
@Builder(access = AccessLevel.PRIVATE)
public record NoticeDetailResponse(

        long noticeId,

        String title,

        String summary,

        String content,

        NoticeStatus status,

        boolean pinned,

        LocalDateTime publishedAt,

        LocalDateTime createdAt
) {
    public static NoticeDetailResponse from(Notice notice) {
        return NoticeDetailResponse.builder()
                .noticeId(notice.getId())
                .title(notice.getTitle())
                .summary(notice.getSummary())
                .content(notice.getContent())
                .status(notice.getStatus())
                .pinned(notice.isPinned())
                .publishedAt(notice.getPublishedAt())
                .createdAt(notice.getCreatedAt())
                .build();
    }
}
