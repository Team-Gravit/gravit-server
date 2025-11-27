package gravit.code.notice.dto.response;

import gravit.code.notice.domain.Notice;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record NoticeDetailResponse(

        long id,
        @NotNull
        String title,
        @NotNull
        String content,
        @NotNull
        String authorName,
        @NotNull
        LocalDateTime createdAt,
        @NotNull
        LocalDateTime updatedAt,
        @NotNull
        String status,
        boolean pinned,
        @NotNull
        LocalDateTime publishedAt
) {
    public static NoticeDetailResponse from(Notice notice) {
        return NoticeDetailResponse.builder()
                .id(notice.getId())
                .title(notice.getTitle())
                .content(notice.getContent())
                .authorName(notice.getAuthor().getNickname())
                .createdAt(notice.getCreatedAt())
                .updatedAt(notice.getUpdatedAt())
                .publishedAt(notice.getPublishedAt())
                .status(notice.getStatus().name())
                .pinned(notice.isPinned())
                .build();
    }
}
