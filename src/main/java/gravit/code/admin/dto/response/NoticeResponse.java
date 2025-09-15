package gravit.code.admin.dto.response;

import gravit.code.notice.domain.Notice;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record NoticeResponse(
        Long noticeId,
        String title,
        String contents,
        String authorName,
        LocalDateTime updatedAt,
        LocalDateTime publishedAt,
        String noticeType,
        boolean pinned
) {
    public static NoticeResponse from(Notice notice) {
        return NoticeResponse.builder()
                .noticeId(notice.getId())
                .title(notice.getTitle())
                .contents(notice.getContent())
                .authorName(notice.getAuthor().getNickname())
                .updatedAt(notice.getUpdatedAt())
                .publishedAt(notice.getPublishedAt())
                .noticeType(notice.getStatus().name())
                .pinned(notice.isPinned())
                .build();
    }
}
