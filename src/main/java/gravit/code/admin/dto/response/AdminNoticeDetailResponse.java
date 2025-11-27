package gravit.code.admin.dto.response;

import gravit.code.notice.domain.Notice;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record AdminNoticeDetailResponse(

        long noticeId,
        @NotNull
        String title,
        @NotNull
        String contents,
        @NotNull
        String authorName,
        @NotNull
        LocalDateTime createdAt,
        @NotNull
        LocalDateTime updatedAt,
        @NotNull
        String noticeType,
        boolean pinned,
        LocalDateTime publishedAt
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
