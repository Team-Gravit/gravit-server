package gravit.code.admin.dto.response;

import gravit.code.notice.domain.Notice;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record AdminNoticeDetailResponse(
        long noticeId,
        String title,
        String contents,
        String authorName,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        LocalDateTime publishedAt,
        String noticeType,
        boolean pinned
) {
    public static AdminNoticeDetailResponse from(Notice notice) {
        return AdminNoticeDetailResponse.builder()
                .noticeId(notice.getId())
                .title(notice.getTitle())
                .contents(notice.getContent())
                .authorName(notice.getAuthor().getNickname())
                .createdAt(notice.getCreatedAt())
                .updatedAt(notice.getUpdatedAt())
                .publishedAt(notice.getPublishedAt())
                .noticeType(notice.getStatus().name())
                .pinned(notice.isPinned())
                .build();
    }
}
